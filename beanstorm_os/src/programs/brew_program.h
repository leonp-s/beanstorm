#pragma once

#include "program.h"

#include <PID_v1.h>
#include <peripherals/peripherals.h>
#include <peripherals/pump.h>

class BrewProgram : public Program
{
public:
    BrewProgram (Pump & pump);
    ~BrewProgram () override = default;

    void Enter () override;
    void Leave () override;
    void Loop (const Peripherals::SensorState & sensor_state) override;

private:
    Pump & pump_;
    float smoothed_pump_speed_normalised_ = 0.f;

    double set_point_ {};
    double input_ {};
    double output_ {};
    int window_size_ = 1000;
    unsigned long window_start_time_ {};
    unsigned long shot_start_time_ = 0;
    PID pid_ {&input_, &output_, &set_point_, kKp, kKi, kKd, DIRECT};
};