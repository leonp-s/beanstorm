#include "pressure_sensor.h"

void PressureSensor::Setup ()
{
    ads_.begin ();
    ads_.setGain (0);
    ads_.setDataRate (4);
    ads_.setMode (0);
    ads_.readADC (0);
}

float PressureSensor::ReadPressure ()
{
    //    getAdsError ();
    return static_cast<float> ((ads_.getValue () - 2666)) / 1777.8f;
}
