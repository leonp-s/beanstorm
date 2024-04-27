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
