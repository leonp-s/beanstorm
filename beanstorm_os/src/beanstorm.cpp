#include "beanstorm.h"

#include "peripherals/peripherals.h"

Beanstorm::Beanstorm (BeanstormBLE & beanstorm_ble)
    : beanstorm_ble_ (beanstorm_ble)
{
}

void Beanstorm::SetupPeripherals ()
{
    Peripherals::SetupPins ();
    pressure_sensor_.Setup ();
    thermocouple_.Setup ();
}

void Beanstorm::SetPinsToDefaultState ()
{
    Peripherals::SetBoilerOff ();
    Peripherals::CloseValve ();
}

void Beanstorm::Setup ()
{
    //    SetupPeripherals ();
    //    SetPinsToDefaultState ();

    SetupViewListeners ();
    beanstorm_ble_.Setup ();
}

void Beanstorm::SetupViewListeners ()
{
}
