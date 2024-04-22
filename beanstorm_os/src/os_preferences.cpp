#include "os_preferences.h"

#include "schemas/beanstorm_schema.pb.h"

#include <pb_decode.h>
#include <pb_encode.h>

bool SavePID (const PIDConstants & pid, Preferences & preferences, const char * key)
{
    PPID p_pid = PPID_init_zero;
    p_pid.kp = pid.kp;
    p_pid.ki = pid.ki;
    p_pid.kd = pid.kd;

    pb_byte_t buffer [PPID_size];
    pb_ostream_t stream = pb_ostream_from_buffer (buffer, sizeof (buffer));

    auto status = pb_encode (&stream, PPID_fields, &p_pid);
    if (status)
        return preferences.putBytes (key, &buffer, PPID_size);

    return false;
}

PIDConstants LoadPID (Preferences & preferences, const char * key)
{
    PPID p_pid = PPID_init_zero;

    pb_byte_t buffer [PPID_size];
    preferences.getBytes (key, &buffer, PPID_size);

    pb_istream_t stream = pb_istream_from_buffer (buffer, PPID_size);
    auto status = pb_decode (&stream, PPID_fields, &p_pid);

    if (! status)
        return {.kp = 0.0f, .ki = 0.0f, .kd = 0.0f};
    else
        return {.kp = p_pid.kp, .ki = p_pid.ki, .kd = p_pid.kd};
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

PControlType ConvertControlType (ControlType control_type)
{
    switch (control_type)
    {
        case ControlType::kPressure:
            return PControlType_pressure;
        case ControlType::kFlow:
            return PControlType_flow;
    }

    return PControlType_pressure;
}

ControlType ConvertPControlType (PControlType p_control_type)
{
    switch (p_control_type)
    {
        case PControlType_pressure:
            return ControlType::kPressure;
        case PControlType_flow:
            return ControlType::kFlow;
    }

    return ControlType::kPressure;
}

bool EncodeString (pb_ostream_t * stream, const pb_field_t * field, void * const * arg)
{
    const char * str = (const char *) (*arg);
    if (! pb_encode_tag_for_field (stream, field))
        return false;
    return pb_encode_string (stream, (uint8_t *) str, strlen (str));
}

bool DecodeString (pb_istream_t * stream, const pb_field_t * field, void ** arg)
{
    auto * str = (std::string *) *arg;
    str->reserve (stream->bytes_left);

    if (! pb_read (stream, (uint8_t *) &str [0], stream->bytes_left))
        return false;

    Serial.println ("Decoding String: ");
    Serial.println (stream->bytes_left);
    Serial.println (str->c_str ());
    Serial.println (str->size ());

    return true;
}

bool EncodeControlPoints (pb_ostream_t * stream, const pb_field_t * field, void * const * arg)
{
    auto * control_points = (std::vector<ControlPoint> *) *arg;

    for (int i = 0; i < control_points->size (); i++)
    {
        if (! pb_encode_tag_for_field (stream, field))
            return false;

        if (! pb_encode (stream, PControlPoint_fields, &control_points [i]))
            return false;
    }

    return true;
}

bool DecodeControlPoints (pb_istream_t * istream, const pb_field_t * field, void ** arg)
{
    auto * control_points = (std::vector<ControlPoint> *) *arg;

    PControlPoint p_control_point;
    if (! pb_decode (istream, PControlPoint_fields, &p_control_point))
        return false;

    control_points->push_back ({.time = p_control_point.time, .value = p_control_point.value});
    return true;
}

bool OsPreferences::SaveBrewProfile (const BrewProfile & brew_profile)
{
    if (brew_profile.control_points.size () > kMaxNumControlPoints)
        return false;

    PBrewProfile p_brew_profile = PBrewProfile_init_zero;

    char * str = "Hello world!";

    p_brew_profile.uuid.funcs.encode = &EncodeString;
    p_brew_profile.uuid.arg = str;

    //    p_brew_profile.control_points.funcs.encode = &EncodeControlPoints;
    //    p_brew_profile.control_points.arg =
    //        const_cast<std::vector<ControlPoint> *> (&brew_profile.control_points);

    p_brew_profile.temperature = brew_profile.temperature;
    p_brew_profile.control_type = ConvertControlType (brew_profile.control_type);

    pb_byte_t buffer [256];
    pb_ostream_t stream = pb_ostream_from_buffer (buffer, sizeof (buffer));

    auto status = pb_encode (&stream, PBrewProfile_fields, &p_brew_profile);

    Serial.print ("Bytes written to disk: ");
    Serial.println (stream.bytes_written);

    if (status)
        return preferences_.putBytes ("brew_profile", &buffer, stream.bytes_written);

    return false;
}

BrewProfile OsPreferences::LoadBrewProfile ()
{
    BrewProfile brew_profile;

    PBrewProfile p_brew_profile = PBrewProfile_init_zero;

    p_brew_profile.uuid.funcs.decode = &DecodeString;
    p_brew_profile.uuid.arg = &brew_profile.uuid;

    //    p_brew_profile.control_points.funcs.decode = &DecodeControlPoints;
    //    p_brew_profile.control_points.arg = &brew_profile.control_points;

    pb_byte_t buffer [256];
    auto profile_size = preferences_.getBytesLength ("brew_profile");

    Serial.print ("Profile Size On Disk: ");
    Serial.println (profile_size);

    preferences_.getBytes ("brew_profile", &buffer, profile_size);

    pb_istream_t stream = pb_istream_from_buffer (buffer, sizeof (buffer));
    auto status = pb_decode (&stream, PBrewProfile_fields, &p_brew_profile);

    if (! status)
    {
        brew_profile.temperature = 0.0f;
        brew_profile.control_type = ControlType::kPressure;

        brew_profile.uuid = "";
        brew_profile.control_points.clear ();
    }
    else
    {
        brew_profile.temperature = p_brew_profile.temperature;
        brew_profile.control_type = ConvertPControlType (p_brew_profile.control_type);
    }

    return brew_profile;
}
