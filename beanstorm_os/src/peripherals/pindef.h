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
static constexpr auto kThermocoupleSpiCsPin = A1;
static constexpr auto kThermocoupleSpiDiPin = A2;
static constexpr auto kThermocoupleSpiDoPin = A3;
static constexpr auto kThermocoupleSpiClkPin = A4;
}
}
