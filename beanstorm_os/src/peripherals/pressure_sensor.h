#pragma once

#include <Adafruit_ADS1X15.h>

class PressureSensor
{
public:
    PressureSensor () = default;
    void Setup ();
    float ReadPressure ();

private:
    Adafruit_ADS1115 ads_;
};
