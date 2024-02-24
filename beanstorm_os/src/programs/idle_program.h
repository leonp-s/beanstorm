#pragma once

#include "program.h"

#include <PID_v1.h>
#include <peripherals/peripherals.h>

class IdleProgram : public Program
{
public:
    ~IdleProgram () override = default;

    void Enter () override;
    void Leave () override;
    void Loop (const Peripherals::SensorState & sensor_state) override;

private:
    double set_point_ {};
    double input_ {};
    double output_ {};
    int window_size_ = 1000;
    unsigned long window_start_time_ {};
    PID pid_ {&input_, &output_, &set_point_, kKp, kKi, kKd, DIRECT};
};