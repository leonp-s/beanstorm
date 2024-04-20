#include "idle_program.h"

IdleProgram::IdleProgram (Heater & heater)
    : heater_ (heater)
{
}

void IdleProgram::Enter ()
{
    heater_.SetTarget (86.0f);
    heater_.Start ();
}

void IdleProgram::Leave ()
{
    heater_.Stop ();
}

void IdleProgram::Loop (const Peripherals::SensorState & sensor_state)
{
}