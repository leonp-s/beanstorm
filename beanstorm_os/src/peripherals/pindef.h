#pragma once
#include <Arduino.h>

namespace Pindef
{
namespace Switches
{
static constexpr auto kSteamSwitchPin = A0;
static constexpr auto kBrewSwitchPin = A1;
static constexpr auto kWaterSwitchPin = A2;
}

namespace Control
{
static constexpr auto kValvePin = A3;
static constexpr auto kBoilerRelayPin = A4;
}

namespace Sensors
{
static constexpr auto kThermocoupleSpiCsPin = A5;
static constexpr auto kThermocoupleSpiDiPin = A6;
static constexpr auto kThermocoupleSpiDoPin = A7;
static constexpr auto kThermocoupleSpiClkPin = A8;
}
}
