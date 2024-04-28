#include "brew_program.h"

BrewProgram::BrewProgram (Pump & pump, Heater & heater, const BrewProfile & brew_profile)
    : pump_ (pump)
    , heater_ (heater)
    , brew_profile_ (brew_profile)
{
}

void BrewProgram::SetPumpTunings (const PIDConstants & pid_constants)
{
    Serial.print ("Pump Tunings Set: ");
    Serial.print (pid_constants.kp);
    Serial.print (" | ");
    Serial.print (pid_constants.ki);
    Serial.print (" | ");
    Serial.println (pid_constants.kd);

    pid_.SetTunings (pid_constants.kp, pid_constants.ki, pid_constants.kd);
}

void BrewProgram::Enter ()
{
    Peripherals::SetBoilerOff ();
    Peripherals::SetValveOpened ();
    pump_.SetOff ();

    heater_.SetTarget (brew_profile_.temperature);
    heater_.Start ();

    const auto & control_points = brew_profile_.control_points;
    auto num_control_points = control_points.size ();

    if (num_control_points < 2)
        shot_duration_ = 0.0f;
    else
        shot_duration_ = control_points.back ().time;

    shot_start_time_ = millis ();

    target_pressure_ = 0.0;

    input_ = 0.f;
    output_ = 0.f;
    target_pressure_ = 0.f;
    
    pid_.SetOutputLimits (0.0f, 1.0f);
    pid_.SetMode (QuickPID::Control::automatic);
}

void BrewProgram::Leave ()
{
    pump_.SetOff ();
    Peripherals::SetValveClosed ();
    heater_.Stop ();
    pid_.Initialize ();
}

/**
 * Adapted from : https://github.com/luisllamasbinaburo/Arduino-Interpolation
 */
float SmoothStep (const ControlPoint * control_points, int num_points, float point_x, bool trim)
{
    if (trim)
    {
        if (point_x <= control_points [0].time)
            return control_points [0].value;
        if (point_x >= control_points [num_points - 1].time)
            return control_points [num_points - 1].value;
    }

    auto i = 0;
    if (point_x <= control_points [0].time)
        i = 0;
    else if (point_x >= control_points [num_points - 1].time)
        i = num_points - 1;
    else
        while (point_x >= control_points [i + 1].time)
            i++;
    if (point_x == control_points [i + 1].time)
        return control_points [i + 1].value;

    auto t = (point_x - control_points [i].time) /
             (control_points [i + 1].time - control_points [i].time);
    t = t * t * (3 - 2 * t);
    return control_points [i].value * (1 - t) + control_points [i + 1].value * t;
}

float BrewProgram::GetTargetValue (float shot_time) const
{
    const auto & control_points = brew_profile_.control_points;
    auto num_control_points = control_points.size ();

    if (num_control_points == 0)
        return 0.0f;

    return SmoothStep (
        control_points.data (), static_cast<int> (control_points.size ()), shot_time, true);
}

float SmoothedValue (float value_to_smooth, float target)
{
    auto delta = 0.2f;
    auto step = (target - value_to_smooth) * delta;
    return value_to_smooth + step;
}

void BrewProgram::Loop (const Peripherals::SensorState & sensor_state)
{
    const auto now = millis ();
    auto shot_time_ms = now - shot_start_time_;
    auto shot_time = static_cast<float> ((shot_time_ms / 1000));

    heater_.SetTarget (brew_profile_.temperature);

    if (shot_time < shot_duration_)
    {
        auto target_value = GetTargetValue (shot_time);

        if (brew_profile_.control_type == ControlType::kPressure)
            target_pressure_ = target_value;
        input_ = sensor_state.pressure;
        pid_.Compute ();

        pump_.SetSpeed (output_ * 255.0f);

        Serial.print ("Pressure: ");
        Serial.println (sensor_state.pressure);

        Serial.print ("Target: ");
        Serial.println (target_value);

        Serial.print ("Output: ");
        Serial.println (output_);

        Serial.println ("----------");
    }
    else
    {
        Peripherals::SetValveClosed ();
        pump_.SetOff ();
        OnShotEnded ();
    }
}