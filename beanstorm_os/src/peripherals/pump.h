#pragma once

#include "CytronMotorDriver.h"

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

    void SetOff ();
    void SetSpeed (float speed);

private:
    CytronMD motor_;
};
