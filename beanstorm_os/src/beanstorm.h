#pragma once

#include "peripherals/pindef.h"
#include "peripherals/pressure_sensor.h"
#include "peripherals/thermocouple.h"
#include "views/view_delegate.h"

class Beanstorm
{
public:
    explicit Beanstorm (ViewDelegate & view_delegate);
    void Setup ();

private:
    static void SetPinsToDefaultState ();
    static void SetupPins ();

    void SetupSensors ();
    void SetupViewListeners ();

    ViewDelegate & view_delegate_;

    PressureSensor pressure_sensor_;
    Thermocouple thermocouple_{
        Pindef::Sensors::kThermocoupleSpiCsPin,
        Pindef::Sensors::kThermocoupleSpiDiPin,
        Pindef::Sensors::kThermocoupleSpiDoPin,
        Pindef::Sensors::kThermocoupleSpiClkPin
    };
};
