#include "beanstorm.h"

#include "peripherals/peripherals.h"
#include "watchdog.h"

Beanstorm::Beanstorm (DataService & data_service, EventBridge & event_bridge)
    : data_service_ (data_service)
    , event_bridge_ (event_bridge)
{
    event_bridge_.OnStartShot = [&] { HandleStartShot (); };
    event_bridge_.OnCancelShot = [&] { HandleEndShot (); };

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

    os_preferences_.Setup ();

    //    os_preferences_.SaveHeaterPID ({.kp = 16.16, .ki = 0.14, .kd = 480.10});
    //    os_preferences_.SavePumpPID ({.kp = 0.1, .ki = 0.0, .kd = 0.0});

    heater_pid_constants_ = os_preferences_.LoadHeaterPID ();
    pump_pid_constants_ = os_preferences_.LoadPumpPID ();

    BrewProfile default_profile {.uuid = "test_profile_uuid",
                                 .temperature = 86.0f,
                                 .control_type = ControlType::kPressure,
                                 .control_points = {ControlPoint {.time = 0.0f, .value = 6.0f},
                                                    ControlPoint {.time = 10.0f, .value = 6.0f},
                                                    ControlPoint {.time = 10.0f, .value = 3.0f},
                                                    ControlPoint {.time = 20.0f, .value = 3.0f},
                                                    ControlPoint {.time = 20.0f, .value = 6.0f},
                                                    ControlPoint {.time = 30.0f, .value = 6.0f}}};

    auto save_result = os_preferences_.SaveBrewProfile (default_profile);
    if (! save_result)
        Serial.println ("Failed to save brew_profile");

    brew_profile_ = os_preferences_.LoadBrewProfile ();
    
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
    if (pressure_sensor_.HasError ())
        Serial.println ("Oh no... Pressure");

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

    delay (kServiceIntervalMs);
}
