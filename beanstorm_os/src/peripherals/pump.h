#pragma once

#include "CytronMotorDriver.h"

#include <PID_v1.h>

class Pump
{
public:
    struct Pins
    {
        uint8_t motor_pin_1;
        uint8_t motor_pin_2;
    };

    explicit Pump (const Pins & pins);
    void Setup ();
    void SetPumpOff ();

private:
    CytronMD motor_;

    double set_point_ {};
    double input_ {};
    double output_ {};
    double kp_ = 2.0;
    double ki_ = 5.0;
    double kd_ = 1.0;

    PID pid_ {&input_, &output_, &set_point_, kp_, ki_, kd_, DIRECT};
};
