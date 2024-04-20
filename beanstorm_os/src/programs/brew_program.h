#pragma once

#include "program.h"

#include <peripherals/heater.h>
#include <peripherals/peripherals.h>
#include <peripherals/pump.h>

class BrewProgram : public Program
{
public:
    BrewProgram (Pump & pump, Heater & heater);
    ~BrewProgram () override = default;

    void Enter () override;
    void Leave () override;
    void Loop (const Peripherals::SensorState & sensor_state) override;

    std::function<void ()> OnShotEnded;

private:
    Pump & pump_;
    Heater & heater_;
    float smoothed_pump_speed_normalised_ = 0.f;
    unsigned long shot_start_time_ = 0;
};