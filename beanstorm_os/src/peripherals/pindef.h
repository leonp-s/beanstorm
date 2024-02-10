#pragma once
#include <Arduino.h>

namespace Pindef
{
namespace Switches
{
static constexpr auto kSteamSwitchPin = A13;
static constexpr auto kBrewSwitchPin = A15;
static constexpr auto kWaterSwitchPin = A14;
}

namespace Control
{
static constexpr auto kValvePin = A6;
static constexpr auto kBoilerRelayPin = A0;
static constexpr auto kPumpMotorPinOne = A12;
static constexpr auto kPumpMotorPinTwo = A11;
}

namespace Sensors
{
static constexpr auto kTemperatureSensorSpiCsPin = A1;
static constexpr auto kTemperatureSensorSpiDiPin = A2;
static constexpr auto kTemperatureSensorSpiDoPin = A3;
static constexpr auto kTemperatureSensorSpiClkPin = A4;
}
}
