#include "os_preferences.h"

#include "schemas/beanstorm_schema.pb.h"

#include <pb_decode.h>
#include <pb_encode.h>

bool SavePID (const PIDConstants & pid, Preferences & preferences, const char * key)
{
    PIDSchema pid_schema {};
    if (pid_schema.Encode (pid))
        return preferences.putBytes (key, &pid_schema.buffer, PPID_size);
    return false;
}

PIDConstants LoadPID (Preferences & preferences, const char * key)
{
    PIDSchema pid_schema {};
    preferences.getBytes (key, &pid_schema.buffer, PPID_size);
    return pid_schema.Decode ();
}

void OsPreferences::Setup ()
{
    preferences_.begin ("beanstorm_os", false);
}

bool OsPreferences::SaveHeaterPID (const PIDConstants & pid)
{
    return SavePID (pid, preferences_, "heater_pid");
}

bool OsPreferences::SavePumpPID (const PIDConstants & pid)
{
    return SavePID (pid, preferences_, "pump_pid");
}

PIDConstants OsPreferences::LoadHeaterPID ()
{
    return LoadPID (preferences_, "heater_pid");
}

PIDConstants OsPreferences::LoadPumpPID ()
{
    return LoadPID (preferences_, "pump_pid");
}

bool OsPreferences::SaveBrewProfile (const BrewProfile & brew_profile)
{
    if (brew_profile.control_points.size () > kMaxNumControlPoints)
        return false;

    BrewProfileSchema brew_profile_schema {};
    std::size_t bytes_written;

    if (brew_profile_schema.Encode (brew_profile, bytes_written))
        return preferences_.putBytes ("brew_profile", &brew_profile_schema.buffer, bytes_written);

    return false;
}

BrewProfile OsPreferences::LoadBrewProfile ()
{
    BrewProfileSchema brew_profile_schema {};

    auto profile_size = preferences_.getBytesLength ("brew_profile");
    preferences_.getBytes ("brew_profile", &brew_profile_schema.buffer, profile_size);

    BrewProfile brew_profile;

    brew_profile_schema.Decode (brew_profile, profile_size);
    return brew_profile;
}
