#include "beanstorm.h"

#include "peripherals/peripherals.h"

Beanstorm::Beanstorm (BeanstormBLE & beanstorm_ble)
    : beanstorm_ble_ (beanstorm_ble)
{
}

void Beanstorm::SetupPeripherals ()
{
    pressure_sensor_.Setup ();
    thermocouple_.Setup ();
    pump_.Setup ();
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

void Beanstorm::Loop ()
{
    HandleSwitchEvents ();
    const Peripherals::SensorState sensor_state {
        .temperature = thermocouple_.ReadTemperature (),
        .pressure = pressure_sensor_.ReadPressure (),
    };
    program_controller_.Loop (sensor_state);

    // if (switch_state.brew)
    //     Peripherals::SetBoilerOn ();
    // else
    //     Peripherals::SetBoilerOff ();
    //
    // if (switch_state.water)
    // {
    //     auto speed = std::sin (pump_time_ * 0.1f);
    //     speed = speed + 1.f;
    //     speed = speed / 2.f;
    //     speed = speed * 200.f;
    //
    //     pump_.SetSpeed (static_cast<int> (std::round (speed)));
    // }
    // else
    // {
    //     pump_.SetPumpOff ();
    // }
    //
    // if (switch_state.steam)
    //     Peripherals::SetValveOpened ();
    // else
    //     Peripherals::SetValveClosed ();
    //
    // Serial.print ("Temperature: ");
    // Serial.println (thermocouple_.ReadTemperature ());
    //
    // Serial.print ("Pressure: ");
    // Serial.println (pressure_sensor_.ReadPressure ());

    delay (200);
}
