#include "beanstorm.h"

#include "peripherals/peripherals.h"
#include "watchdog.h"

Beanstorm::Beanstorm (BeanstormBLE & beanstorm_ble)
    : beanstorm_ble_ (beanstorm_ble)
{
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
}

void Beanstorm::Setup ()
{
    Peripherals::SetupPins ();
    SetPeripheralsToDefaultState ();
    SetupPeripherals ();

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

    program_controller_.LoadProgram (&idle_program_);
    // beanstorm_ble_.Setup ();
}

void Beanstorm::HandleSwitchEvents ()
{
    const auto switch_state = Peripherals::ReadSwitchState ();

    if (last_switch_state_.brew != switch_state.brew)
    {
        if (switch_state.brew)
            program_controller_.LoadProgram (&brew_program_);
        else
            program_controller_.LoadProgram (&idle_program_);
    }

    last_switch_state_ = switch_state;
}

void Beanstorm::PerformHealthCheck ()
{
    if (pressure_sensor_.HasError ())
    {
        Serial.println ("Oh no... Pressure");
    }

    if (temperature_sensor_.HasError ())
    {
        Serial.println ("Oh no... Temperature");
    }
}

void Beanstorm::Loop ()
{
    TaskWatchdog::Reset ();
    PerformHealthCheck ();

    const Peripherals::SensorState sensor_state {
        .temperature = temperature_sensor_.ReadTemperature (),
        .pressure = pressure_sensor_.ReadPressure (),
    };

    HandleSwitchEvents ();
    program_controller_.Loop (sensor_state);

    delay (kServiceIntervalMs);
}
