#include "heater_program.h"

void HeaterProgram::Loop (const Peripherals::SensorState & sensor_state)
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

void HeaterProgram::StartHeater ()
{
    Peripherals::SetBoilerOff ();

    window_start_time_ = millis ();
    set_point_ = 82.0;

    pid_.SetOutputLimits (0, window_size_);
    pid_.SetMode (AUTOMATIC);

    is_heating = true;
}

void HeaterProgram::StopHeater ()
{
    is_heating = false;

    SetTarget (0.0f);
    Peripherals::SetBoilerOff ();
}

void HeaterProgram::SetTarget (float set_point)
{
    set_point_ = static_cast<double> (set_point);
}
