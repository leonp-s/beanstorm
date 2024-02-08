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
    Peripherals::CloseValve ();
}

void Beanstorm::Setup ()
{
    Peripherals::SetupPins ();

    SetupPeripherals ();
    SetPinsToDefaultState ();

    beanstorm_ble_.Setup ();
}

void Beanstorm::Loop ()
{
    pump_time_++;

    auto switch_state = Peripherals::ReadSwitchState ();

    Serial.println ("---- Reading Switch States ----");

    Serial.print ("Brew: ");
    Serial.println (switch_state.brew);

    Serial.print ("Water: ");
    Serial.println (switch_state.water);

    Serial.print ("Steam: ");
    Serial.println (switch_state.steam);

    if (switch_state.brew)
        Peripherals::SetBoilerOn ();
    else
        Peripherals::SetBoilerOff ();

    if (switch_state.water)
    {
        auto speed = std::sin (pump_time_ * 0.1f);
        speed = speed + 1.f;
        speed = speed / 2.f;
        speed = speed * 200.f;

        pump_.SetSpeed (static_cast<int> (std::round (speed)));
    }
    else
    {
        pump_.SetPumpOff ();
    }

    if (switch_state.steam)
        Peripherals::OpenValve ();
    else
        Peripherals::CloseValve ();

    Serial.print ("Temperature: ");
    Serial.println (thermocouple_.ReadTemperature ());

    Serial.print ("Pressure: ");
    Serial.println (pressure_sensor_.ReadPressure ());

    delay (200);
}
