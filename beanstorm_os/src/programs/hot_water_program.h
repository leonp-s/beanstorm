#pragma once

#include "program.h"

#include <QuickPID.h>
#include <brew_profile.h>
#include <peripherals/heater.h>
#include <peripherals/peripherals.h>
#include <peripherals/pump.h>

class HotWaterProgram : public Program
{
public:
    HotWaterProgram (Pump & pump, Heater & heater, const BrewProfile & brew_profile);
    ~HotWaterProgram () override = default;

    void Enter () override;
    void Leave () override;
    void Loop (const Peripherals::SensorState & sensor_state) override;

private:
    Pump & pump_;
    Heater & heater_;
    const BrewProfile & brew_profile_;
};
