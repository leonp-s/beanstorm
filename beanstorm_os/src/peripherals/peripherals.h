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

namespace
{
static inline void SetupSwitchPins ()
{
    pinMode (Pindef::Switches::kBrewSwitchPin, INPUT_PULLUP);
    pinMode (Pindef::Switches::kSteamSwitchPin, INPUT_PULLUP);
    pinMode (Pindef::Switches::kWaterSwitchPin, INPUT_PULLUP);
}

static inline void SetupControlPins ()
{
    pinMode (Pindef::Control::kValvePin, OUTPUT);
    pinMode (Pindef::Control::kBoilerRelayPin, OUTPUT);
}
}

static inline void SetupPins ()
{
    SetupSwitchPins ();
    SetupControlPins ();
}

static inline SwitchState ReadSwitchState ()
{
    return {.steam = digitalRead (Pindef::Switches::kSteamSwitchPin) == LOW,
            .brew = digitalRead (Pindef::Switches::kBrewSwitchPin) == LOW,
            .water = digitalRead (Pindef::Switches::kWaterSwitchPin) == LOW};
}

static inline void OpenValve ()
{
    digitalWrite (Pindef::Control::kValvePin, HIGH);
}

static inline void CloseValve ()
{
    digitalWrite (Pindef::Control::kValvePin, LOW);
}

static inline void SetBoilerOn ()
{
    digitalWrite (Pindef::Control::kBoilerRelayPin, HIGH);
}

static inline void SetBoilerOff ()
{
    digitalWrite (Pindef::Control::kBoilerRelayPin, LOW);
}

}