#pragma once

#include "brew_profile.h"

#include <Preferences.h>

struct PIDConstants
{
    float kp;
    float ki;
    float kd;
};

class OsPreferences
{
public:
    void Setup ();

    PIDConstants LoadHeaterPID ();
    PIDConstants LoadPumpPID ();
    BrewProfile LoadBrewProfile ();

    bool SaveHeaterPID (const PIDConstants & pid);
    bool SavePumpPID (const PIDConstants & pid);
    bool SaveBrewProfile (const BrewProfile & brew_profile);

private:
    static constexpr int kMaxNumControlPoints = 20;

    Preferences preferences_;
};
