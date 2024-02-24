#include "idle_program.h"

void IdleProgram::Enter ()
{
    Serial.println ("Enter Idle Program");
    Peripherals::SetBoilerOff ();

    window_start_time_ = millis ();
    set_point_ = 82.0;

    pid_.SetOutputLimits (0, window_size_);
    pid_.SetMode (AUTOMATIC);
}

void IdleProgram::Leave ()
{
    Serial.println ("Leave Idle Program");
    Peripherals::SetBoilerOff ();
}

void IdleProgram::Loop (const Peripherals::SensorState & sensor_state)
{
    input_ = sensor_state.temperature;
    pid_.Compute ();

    const auto now = millis ();
    if (now - window_start_time_ > window_size_)
        window_start_time_ += window_size_;

    if (output_ > now - window_start_time_)
        Peripherals::SetBoilerOn ();
    else
        Peripherals::SetBoilerOff ();

    Serial.print ("Temperature: ");
    Serial.println (sensor_state.temperature);
}