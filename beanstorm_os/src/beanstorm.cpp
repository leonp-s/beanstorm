#include "beanstorm.h"

#include "peripherals/peripherals.h"
#include "watchdog.h"

Beanstorm::Beanstorm (DataService & data_service, EventBridge & event_bridge)
    : data_service_ (data_service)
    , event_bridge_ (event_bridge)
{
    event_bridge_.OnStartShot = [&] { HandleStartShot (); };
    event_bridge_.OnCancelShot = [&] { HandleEndShot (); };

    event_bridge_.OnHeaterPIDUpdated = [&] (const PIDConstants & pid_constants)
    { heater_.SetTunings (pid_constants); };

    event_bridge_.OnPumpPIDUpdated = [&] (const PIDConstants & pid_constants)
    { brew_program_.SetPumpTunings (pid_constants); };

    event_bridge_.OnBrewProfileUpdated = [&] (std::unique_ptr<BrewProfile> brew_profile)
    { brew_profile_ = *brew_profile; };

    brew_program_.OnShotEnded = [&] { HandleEndShot (); };
}

void Beanstorm::SetupPeripherals ()
{
    pressure_sensor_.Setup ();
    temperature_sensor_.Setup ();
    pump_.Setup ();
}

void Beanstorm::SetPeripheralsToDefaultState ()
{
    Peripherals::SetBoilerOff ();
    Peripherals::SetValveClosed ();
    pump_.SetOff ();
    heater_.Stop ();
}

void Beanstorm::Setup ()
{
    Peripherals::SetupPins ();
    SetupPeripherals ();
    SetPeripheralsToDefaultState ();

    last_switch_state_ = Peripherals::ReadSwitchState ();

    const auto setup_error = TaskWatchdog::SetupWatchdog (kWatchdogTimeout);
    const auto add_task_error = TaskWatchdog::AddTask (nullptr);

    if (setup_error || add_task_error)
    {
        static constexpr auto kErrorRestartDelayMs = 2000;
        delay (kErrorRestartDelayMs);
        esp_restart ();
    }

    if (TaskWatchdog::IsBootReasonReset ())
        Serial.println ("Reboot from WDT");

    event_bridge_.Loop ();
    program_controller_.LoadProgram (&idle_program_);
}

void Beanstorm::HandleSwitchEvents ()
{
    const auto switch_state = Peripherals::ReadSwitchState ();

    if (last_switch_state_.brew != switch_state.brew)
    {
        if (switch_state.brew)
            HandleStartShot ();
        else
            HandleEndShot ();
    }

    last_switch_state_ = switch_state;
}

void Beanstorm::PerformHealthCheck ()
{
    //    if (pressure_sensor_.HasError ())
    //        Serial.println ("Oh no... Pressure");

    if (temperature_sensor_.HasError ())
        Serial.println ("Oh no... Temperature");
}

void Beanstorm::HandleStartShot ()
{
    program_controller_.LoadProgram (&brew_program_);
}

void Beanstorm::HandleEndShot ()
{
    program_controller_.LoadProgram (&idle_program_);
}

void Beanstorm::Loop ()
{
    auto now = millis ();
    if (last_service_ - now > kServiceIntervalMs)
    {
        TaskWatchdog::Reset ();
        PerformHealthCheck ();

        const Peripherals::SensorState sensor_state {
            .temperature = temperature_sensor_.ReadTemperature (),
            .pressure = pressure_sensor_.ReadPressure (),
        };

        event_bridge_.Loop ();
        HandleSwitchEvents ();

        program_controller_.Loop (sensor_state);
        heater_.Loop (sensor_state);
        data_service_.SensorStateUpdated (sensor_state);

        last_service_ = now;
    }
}
