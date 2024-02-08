#pragma once

#include "pindef.h"

namespace Peripherals
{
struct SwitchState
{
    bool steam;
    bool brew;
    bool water;
};

inline void SetupSwitchPins ()
{
    pinMode (Pindef::Switches::kBrewSwitchPin, INPUT_PULLUP);
    pinMode (Pindef::Switches::kSteamSwitchPin, INPUT_PULLUP);
    pinMode (Pindef::Switches::kWaterSwitchPin, INPUT_PULLUP);
}

inline void SetupControlPins ()
{
    pinMode (Pindef::Control::kValvePin, OUTPUT);
    pinMode (Pindef::Control::kBoilerRelayPin, OUTPUT);
}

static void SetupPins ()
{
    SetupSwitchPins ();
    SetupControlPins ();
}

static SwitchState ReadSwitchState ()
{
    return {.steam = digitalRead (Pindef::Switches::kSteamSwitchPin) == HIGH,
            .brew = digitalRead (Pindef::Switches::kBrewSwitchPin) == HIGH,
            .water = digitalRead (Pindef::Switches::kWaterSwitchPin) == HIGH};
}

static void OpenValve ()
{
    digitalWrite (Pindef::Control::kValvePin, LOW);
}

static void CloseValve ()
{
    digitalWrite (Pindef::Control::kValvePin, HIGH);
}

static void SetBoilerOn ()
{
    digitalWrite (Pindef::Control::kBoilerRelayPin, HIGH);
}

static inline void SetBoilerOff ()
{
    digitalWrite (Pindef::Control::kBoilerRelayPin, LOW);
}
}
