#pragma once

#include "program.h"

#include <QuickPID.h>
#include <brew_profile.h>
#include <peripherals/heater.h>
#include <peripherals/peripherals.h>
#include <peripherals/pump.h>

class SteamProgram : public Program
{
public:
    SteamProgram (Pump & pump, Heater & heater);
    ~SteamProgram () override = default;

    void Enter () override;
    void Leave () override;
    void Loop (const Peripherals::SensorState & sensor_state) override;

private:
    Pump & pump_;
    Heater & heater_;

    static constexpr float kSteamTemperature = 130.f;
};
