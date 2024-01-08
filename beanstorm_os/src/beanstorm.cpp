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

    // SetupPeripherals ();
    SetPinsToDefaultState ();

    beanstorm_ble_.Setup ();
}
