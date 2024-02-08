#pragma once

#include <ADS1X15.h>
#include <Arduino.h>
#include <memory>

class PressureSensor
{
public:
    PressureSensor () = default;
    void Setup ();
    float ReadPressure ();

private:
    ADS1115 ads_;

    float previous_pressure_ {};
    float current_pressure_ {};
};