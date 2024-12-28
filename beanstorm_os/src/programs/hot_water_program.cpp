#include "hot_water_program.h"

HotWaterProgram::HotWaterProgram (Pump & pump, Heater & heater, const BrewProfile & brew_profile)
    : pump_ (pump)
    , heater_ (heater)
    , brew_profile_ (brew_profile)
{
}

void HotWaterProgram::Enter ()
{
    Peripherals::SetBoilerOff ();
    Peripherals::SetValveClosed ();
    pump_.SetOff ();

    heater_.SetTarget (brew_profile_.temperature);
    heater_.Start ();
}

void HotWaterProgram::Leave ()
{
    Peripherals::SetBoilerOff ();
    pump_.SetOff ();
    Peripherals::SetValveClosed ();
    heater_.Stop ();
}

void HotWaterProgram::Loop (const Peripherals::SensorState & sensor_state)
{
    heater_.SetTarget (brew_profile_.temperature);
    pump_.SetSpeed (200.f);
}