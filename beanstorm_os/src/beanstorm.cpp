#include "beanstorm.h"

#include "peripherals/peripherals.h"

#include <esp_task_wdt.h>

Beanstorm::Beanstorm (BeanstormBLE & beanstorm_ble)
    : beanstorm_ble_ (beanstorm_ble)
{
}

void Beanstorm::SetupPeripherals ()
{
    pressure_sensor_.Setup ();
    thermocouple_.Setup ();

    pump_.Setup ();
    pump_.SetOff ();
}

void Beanstorm::SetPinsToDefaultState ()
{
    Peripherals::SetBoilerOff ();
    Peripherals::SetValveClosed ();
}

void Beanstorm::Setup ()
{
    Peripherals::SetupPins ();
    SetPinsToDefaultState ();

    SetupPeripherals ();
    program_controller_.LoadProgram (&idle_program_);

    esp_task_wdt_init (kWatchdogTimeout, true);
    esp_task_wdt_add (nullptr);

    const auto boot_reason = esp_reset_reason ();
    if (boot_reason == 1)
        Serial.println ("Reboot was because of Power-On!!");

    if (boot_reason == 6)
        Serial.println ("Reboot was because of WDT!!");

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
}

void Beanstorm::Loop ()
{
    esp_task_wdt_reset ();

    PerformHealthCheck ();

    const Peripherals::SensorState sensor_state {
        .temperature = thermocouple_.ReadTemperature (),
        .pressure = pressure_sensor_.ReadPressure (),
    };

    HandleSwitchEvents ();
    program_controller_.Loop (sensor_state);

    delay (kServiceIntervalMs);
}
