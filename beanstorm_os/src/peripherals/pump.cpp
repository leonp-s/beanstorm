#include "pump.h"

Pump::Pump (const Pins & pins)
    : motor_ (PWM_DIR, pins.motor_pin_1, pins.motor_pin_2)
{
}

void Pump::Setup ()
{
    SetPumpOff ();

    set_point_ = 0;
    pid_.SetMode (AUTOMATIC);
}

void Pump::SetPumpOff ()
{
    motor_.setSpeed (0);
}

void Pump::SetSpeed (float speed)
{
    motor_.setSpeed (speed);
}
