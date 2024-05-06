#pragma once

#include "ble/data_service.h"
#include "brew_profile.h"
#include "event_bridge/event_bridge.h"
#include "peripherals/heater.h"
#include "peripherals/peripherals.h"
#include "peripherals/pindef.h"
#include "peripherals/pressure_sensor.h"
#include "peripherals/pump.h"
#include "peripherals/temperature_sensor.h"
#include "programs/brew_program.h"
#include "programs/idle_program.h"
#include "programs/program_controller.h"

class Beanstorm
{
public:
    explicit Beanstorm (DataService & data_service, EventBridge & event_bridge);
    void Setup ();
    void Loop ();

private:
    void SetPeripheralsToDefaultState ();
    void SetupPeripherals ();
    void HandleSwitchEvents ();

    void PerformHealthCheck ();

    void HandleStartShot ();
    void HandleEndShot ();

    static constexpr int kWatchdogTimeout = 1;
    static constexpr int kServiceIntervalMs = 100;

    unsigned long last_service_ = 0;

    OsPreferences os_preferences_;

    BrewProfile brew_profile_ {.uuid = "5791f6ba-45db-4900-912e-8fe65af0bc05",
                               .temperature = 86.0f,
                               .control_type = ControlType::kPressure,
                               .control_points = {ControlPoint {.time = 0.0f, .value = 6.0f},
                                                  ControlPoint {.time = 10.0f, .value = 6.0f},
                                                  ControlPoint {.time = 10.0f, .value = 3.0f},
                                                  ControlPoint {.time = 20.0f, .value = 3.0f},
                                                  ControlPoint {.time = 20.0f, .value = 6.0f},
                                                  ControlPoint {.time = 30.0f, .value = 6.0f}}};

    Peripherals::SwitchState last_switch_state_ {.steam = false, .brew = false, .water = false};

    Pump pump_ {{.motor_pin_1 = Pindef::Control::kPumpMotorPinOne,
                 .motor_pin_2 = Pindef::Control::kPumpMotorPinTwo}};
    TemperatureSensor temperature_sensor_ {
        {.spi_pin_cs = Pindef::Sensors::kTemperatureSensorSpiCsPin,
         .spi_pin_di = Pindef::Sensors::kTemperatureSensorSpiDiPin,
         .spi_pin_do = Pindef::Sensors::kTemperatureSensorSpiDoPin,
         .spi_pin_clk = Pindef::Sensors::kTemperatureSensorSpiClkPin}};
    PressureSensor pressure_sensor_;
    Heater heater_;

    ProgramController program_controller_;
    IdleProgram idle_program_ {heater_, brew_profile_};
    BrewProgram brew_program_ {pump_, heater_, brew_profile_};

    DataService & data_service_;
    EventBridge & event_bridge_;
};
