#pragma once

#include <ADS1X15.h>

class PressureSensor
{
public:
    PressureSensor () = default;
    void Setup ();
    float ReadPressure ();

private:
    ADS1115 ads_;

    void I2CResetState ();
    void GetAdsError ();

    float previous_pressure_ {};
    float current_pressure_ {};
};
