#pragma once

#include "ble/beanstorm_ble.h"
#include "peripherals/pindef.h"
#include "peripherals/pressure_sensor.h"
#include "peripherals/pump.h"
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

    BeanstormBLE & beanstorm_ble_;
    ProgramController program_controller_;

    Pump pump_ {{.motor_pin_1 = Pindef::Control::kPumpMotorPinOne,
                 .motor_pin_2 = Pindef::Control::kPumpMotorPinTwo}};
    Thermocouple thermocouple_ {{.spi_pin_cs = Pindef::Sensors::kThermocoupleSpiCsPin,
                                 .spi_pin_di = Pindef::Sensors::kThermocoupleSpiDiPin,
                                 .spi_pin_do = Pindef::Sensors::kThermocoupleSpiDoPin,
                                 .spi_pin_clk = Pindef::Sensors::kThermocoupleSpiClkPin}};
    PressureSensor pressure_sensor_;
};
