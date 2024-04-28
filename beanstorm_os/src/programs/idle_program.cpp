#include "idle_program.h"

IdleProgram::IdleProgram (Heater & heater, const BrewProfile & brew_profile)
    : heater_ (heater)
    , brew_profile_ (brew_profile)
{
}

void IdleProgram::Enter ()
{
    heater_.SetTarget (brew_profile_.temperature);
    heater_.Start ();
}

void IdleProgram::Leave ()
{
    heater_.Stop ();
}

void IdleProgram::Loop (const Peripherals::SensorState & sensor_state)
{
    Serial.print ("Temperature: ");
    Serial.println (sensor_state.temperature);
    heater_.SetTarget (brew_profile_.temperature);
}