#include "heater.h"

void Heater::SetTunings (const PIDConstants & pid_constants)
{
    pid_.SetTunings (pid_constants.kp, pid_constants.ki, pid_constants.kd);
}

void Heater::Loop (const Peripherals::SensorState & sensor_state)
{
    if (is_heating)
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
    }
}

void Heater::Start ()
{
    Peripherals::SetBoilerOff ();

    window_start_time_ = millis ();
    set_point_ = 82.0;

    pid_.SetOutputLimits (0.f, static_cast<float> (window_size_));
    pid_.SetMode (QuickPID::Control::automatic);

    is_heating = true;
}

void Heater::Stop ()
{
    is_heating = false;

    SetTarget (0.0f);
    Peripherals::SetBoilerOff ();
}

void Heater::SetTarget (float set_point)
{
    set_point_ = set_point;
}
