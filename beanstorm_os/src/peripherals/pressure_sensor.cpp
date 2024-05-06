#include "pressure_sensor.h"

#include <Wire.h>

void PressureSensor::Setup ()
{
    ads_.begin ();
}

float PressureSensor::ReadPressure ()
{
    return std::max (static_cast<float> ((ads_.readADC_SingleEnded (0) - 2666)) / 1777.8f, 0.0f);
}