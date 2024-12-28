#include "steam_program.h"

SteamProgram::SteamProgram (Pump & pump, Heater & heater)
    : pump_ (pump)
    , heater_ (heater)
{
}

void SteamProgram::Enter ()
{
    Peripherals::SetBoilerOff ();
    Peripherals::SetValveClosed ();

    pump_.SetOff ();
    heater_.SetTarget (kSteamTemperature);
    heater_.Start ();
}

void SteamProgram::Leave ()
{
    Peripherals::SetBoilerOff ();
    pump_.SetOff ();
    Peripherals::SetValveClosed ();
    heater_.Stop ();
}

void SteamProgram::Loop (const Peripherals::SensorState & sensor_state)
{
    heater_.SetTarget (kSteamTemperature);
}