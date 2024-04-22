#pragma once

#include "program.h"

#include <brew_profile.h>
#include <peripherals/heater.h>
#include <peripherals/peripherals.h>

class IdleProgram : public Program
{
public:
    explicit IdleProgram (Heater & heater, const BrewProfile & brew_profile);
    ~IdleProgram () override = default;

    void Enter () override;
    void Leave () override;
    void Loop (const Peripherals::SensorState & sensor_state) override;

private:
    const BrewProfile & brew_profile_;
    Heater & heater_;
};