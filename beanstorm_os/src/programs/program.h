#pragma once

#include <peripherals/peripherals.h>

struct Program
{
    virtual ~Program () = default;

    virtual void Enter () = 0;
    virtual void Leave () = 0;
    virtual void Loop (const Peripherals::SensorState & sensor_state) = 0;
};