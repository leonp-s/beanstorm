#include "beanstorm.h"
#include "peripherals/peripherals.h"

Beanstorm::Beanstorm (ViewDelegate & view_delegate)
    : view_delegate_ (view_delegate)
{
}

void Beanstorm::Setup ()
{
    SetupPins ();
    SetupSensors ();

    view_delegate_.Setup ();
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

void Beanstorm::SetupViewListeners ()
{
    view_delegate_.OnProfileDidLoad = []
    {
    };
}
