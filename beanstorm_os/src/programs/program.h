#pragma once

#include <peripherals/peripherals.h>

static constexpr double kKp = 16.16;
static constexpr double kKi = 0.14;
static constexpr double kKd = 480.10;

struct Program
{
    virtual ~Program () = default;

    virtual void Enter () = 0;
    virtual void Leave () = 0;
    virtual void Loop (const Peripherals::SensorState & sensor_state) = 0;
};