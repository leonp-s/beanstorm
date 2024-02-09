#pragma once

#include <ADS1X15.h>

class PressureSensor
{
public:
    PressureSensor () = default;
    void Setup ();
    float ReadPressure ();
    bool HasError ();

private:
    ADS1115 ads_;

    float previous_pressure_ {};
    float current_pressure_ {};
};
