#include "brew_program.h"

BrewProgram::BrewProgram (Pump & pump, Heater & heater)
    : pump_ (pump)
    , heater_ (heater)
{
}

void BrewProgram::Enter ()
{
    Peripherals::SetBoilerOff ();
    Peripherals::SetValveOpened ();
    pump_.SetOff ();

    heater_.SetTarget (92.0f);
    heater_.Start ();

    shot_start_time_ = millis ();
    smoothed_pump_speed_normalised_ = 0.f;
}

void BrewProgram::Leave ()
{
    pump_.SetOff ();
    Peripherals::SetValveClosed ();
    heater_.Stop ();
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

    Serial.println (now - shot_start_time_);
    auto shot_time = now - shot_start_time_;
    if (shot_time < 42000)
    {
        if (shot_time < 10000)
        {
            Serial.println ("Pre-infuse");
            smoothed_pump_speed_normalised_ =
                SmoothedValue (smoothed_pump_speed_normalised_, 0.48f);
        }
        else if (shot_time < 20000)
        {
            Serial.println ("Soak");
            smoothed_pump_speed_normalised_ = SmoothedValue (smoothed_pump_speed_normalised_, 0.0f);
        }
        else
        {
            Serial.println ("Infuse");
            smoothed_pump_speed_normalised_ = SmoothedValue (smoothed_pump_speed_normalised_, 0.7f);
        }

        Serial.println (smoothed_pump_speed_normalised_);
        pump_.SetSpeed (std::round (smoothed_pump_speed_normalised_ * 200.f));
    }
    else
    {
        Peripherals::SetValveClosed ();
        pump_.SetOff ();
        OnShotEnded ();
    }
}
