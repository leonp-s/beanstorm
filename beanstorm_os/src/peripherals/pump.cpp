#include "pump.h"

Pump::Pump (const Pins & pins)
    : motor_ (PWM_DIR, pins.motor_pin_1, pins.motor_pin_2)
{
}

void Pump::Setup ()
{
    SetOff ();
}

void Pump::SetOff ()
{
    motor_.setSpeed (0);
}

void Pump::SetSpeed (float speed)
{
    motor_.setSpeed (static_cast<int16_t> (std::round (speed)));
}
