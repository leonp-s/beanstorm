#pragma once

#include "ble/beanstorm_ble.h"
#include "peripherals/pindef.h"
#include "peripherals/pressure_sensor.h"
#include "peripherals/thermocouple.h"
#include "programs/ProgramController.h"

class Beanstorm
{
public:
    explicit Beanstorm (BeanstormBLE & beanstorm_ble);

    void Setup ();

    void Loop ();

private:
    static void SetPinsToDefaultState ();

    void SetupPeripherals ();

    void SetupSensors ();

    void SetupViewListeners ();

    BeanstormBLE & beanstorm_ble_;
    ProgramController program_controller_;

    PressureSensor pressure_sensor_;
    Thermocouple thermocouple_ {Pindef::Sensors::kThermocoupleSpiCsPin,
                                Pindef::Sensors::kThermocoupleSpiDiPin,
                                Pindef::Sensors::kThermocoupleSpiDoPin,
                                Pindef::Sensors::kThermocoupleSpiClkPin};
};
