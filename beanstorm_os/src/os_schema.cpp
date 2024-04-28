#include "os_schema.h"

bool PIDSchema::Encode (const PIDConstants & pid_constants)
{
    PPID p_pid = PPID_init_zero;
    p_pid.kp = pid_constants.kp;
    p_pid.ki = pid_constants.ki;
    p_pid.kd = pid_constants.kd;

    pb_ostream_t stream = pb_ostream_from_buffer (buffer, sizeof (buffer));
    return pb_encode (&stream, PPID_fields, &p_pid);
}

PIDConstants PIDSchema::Decode () const
{
    PPID p_pid = PPID_init_zero;
    pb_istream_t stream = pb_istream_from_buffer (buffer, PPID_size);
    auto status = pb_decode (&stream, PPID_fields, &p_pid);
    if (! status)
        return {.kp = 0.0f, .ki = 0.0f, .kd = 0.0f};
    else
        return {.kp = p_pid.kp, .ki = p_pid.ki, .kd = p_pid.kd};
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

bool BrewProfileSchema::Encode (const BrewProfile & brew_profile, std::size_t & bytes_written)
{
    PBrewProfile p_brew_profile = PBrewProfile_init_zero;

    brew_profile.uuid.copy (p_brew_profile.uuid, 36);
    p_brew_profile.temperature = brew_profile.temperature;
    p_brew_profile.control_type = ConvertControlType (brew_profile.control_type);

    auto num_control_points = brew_profile.control_points.size ();
    p_brew_profile.control_points_count = num_control_points;
    for (auto i = 0; i < num_control_points; ++i)
    {
        auto & control_point = brew_profile.control_points [i];
        p_brew_profile.control_points [i] = {.time = control_point.time,
                                             .value = control_point.value};
    }

    pb_ostream_t stream = pb_ostream_from_buffer (buffer, PBrewProfile_size);
    auto status = pb_encode (&stream, PBrewProfile_fields, &p_brew_profile);
    bytes_written = stream.bytes_written;
    return status;
}

void BrewProfileSchema::Decode (BrewProfile & brew_profile, std::size_t profile_size)
{
    pb_istream_t stream = pb_istream_from_buffer (buffer, profile_size);
    PBrewProfile p_brew_profile = PBrewProfile_init_zero;
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
        brew_profile.uuid = std::string (p_brew_profile.uuid);
        brew_profile.temperature = p_brew_profile.temperature;
        brew_profile.control_type = ConvertPControlType (p_brew_profile.control_type);

        for (auto i = 0; i < p_brew_profile.control_points_count; ++i)
        {
            auto & p_control_point = p_brew_profile.control_points [i];
            brew_profile.control_points.push_back (
                {.time = p_control_point.time, .value = p_control_point.value});
        }
    }
}
