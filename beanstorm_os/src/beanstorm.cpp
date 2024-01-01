#include "beanstorm.h"
#include "peripherals/peripherals.h"

Beanstorm::Beanstorm ()
{
}

void Beanstorm::Setup ()
{
    SetupPins ();
    SetupSensors ();
}

void Beanstorm::SetupPins ()
{
    Peripherals::SetupPins ();
    SetPinsToDefaultState ();
}

void Beanstorm::SetPinsToDefaultState ()
{
    Peripherals::SetBoilerOff ();
    Peripherals::CloseValve ();
}

void Beanstorm::SetupSensors ()
{
    pressure_sensor_.Setup ();
    thermocouple_.Setup ();
}
