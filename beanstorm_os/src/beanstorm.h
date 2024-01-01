#pragma once

#include <peripherals/pindef.h>
#include <peripherals/pressure_sensor.h>
#include <peripherals/thermocouple.h>

class Beanstorm
{
public:
    Beanstorm ();
    void Setup ();

private:
    static void SetPinsToDefaultState ();
    static void SetupPins ();

    void SetupSensors ();

    PressureSensor pressure_sensor_;
    Thermocouple thermocouple_{
        Pindef::Sensors::kThermocoupleSpiCsPin,
        Pindef::Sensors::kThermocoupleSpiDiPin,
        Pindef::Sensors::kThermocoupleSpiDoPin,
        Pindef::Sensors::kThermocoupleSpiClkPin
    };
};
