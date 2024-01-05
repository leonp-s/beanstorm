#pragma once

#include "peripherals/pindef.h"
#include "peripherals/pressure_sensor.h"
#include "peripherals/thermocouple.h"
#include "views/view_delegate.h"
#include "programs/ProgramController.h"

class Beanstorm
{
public:
    explicit Beanstorm (ViewDelegate & view_delegate);
    void Setup ();
    void Loop ();

private:
    static void SetPinsToDefaultState ();

    void SetupPeripherals ();
    void SetupSensors ();
    void SetupViewListeners ();

    ViewDelegate & view_delegate_;
    ProgramController program_controller_;

    PressureSensor pressure_sensor_;
    Thermocouple thermocouple_{
        Pindef::Sensors::kThermocoupleSpiCsPin,
        Pindef::Sensors::kThermocoupleSpiDiPin,
        Pindef::Sensors::kThermocoupleSpiDoPin,
        Pindef::Sensors::kThermocoupleSpiClkPin
    };
};
