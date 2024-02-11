#include "program_controller.h"

void ProgramController::LoadProgram (Program * program)
{
    if (current_program_ != nullptr)
        current_program_->Leave ();

    program->Enter ();
    current_program_ = program;
}

void ProgramController::Loop (const Peripherals::SensorState & sensor_state)
{
    if (current_program_ != nullptr)
        current_program_->Loop (sensor_state);
}

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
    {
        window_start_time_ += window_size_;
    }

    if (output_ > now - window_start_time_)
    {
        Serial.println ("Boiler On");
        Peripherals::SetBoilerOn ();
    }
    else
    {
        Serial.println ("Boiler Off");
        Peripherals::SetBoilerOff ();
    }

    Serial.print ("Temperature: ");
    Serial.println (sensor_state.temperature);
}

BrewProgram::BrewProgram (Pump & pump)
    : pump_ (pump)
{
}

void BrewProgram::Enter ()
{
    Serial.println ("Enter Brew Program");
    Peripherals::SetBoilerOff ();

    window_start_time_ = millis ();
    shot_start_time_ = millis ();
    set_point_ = 82.0;

    pid_.SetOutputLimits (0, window_size_);
    pid_.SetMode (AUTOMATIC);

    Peripherals::SetValveOpened ();

    pump_.SetOff ();
    smoothed_pump_speed_normalised_ = 0.f;
}

void BrewProgram::Leave ()
{
    Serial.println ("Leave Brew Program");
    Peripherals::SetBoilerOff ();
    Peripherals::SetValveClosed ();
    pump_.SetOff ();
}

float SmoothedValue (float value_to_smooth, float target)
{
    auto delta = 0.2f;
    auto step = (target - value_to_smooth) * delta;
    return value_to_smooth + step;
}

void BrewProgram::Loop (const Peripherals::SensorState & sensor_state)
{
    input_ = sensor_state.temperature;
    pid_.Compute ();

    const auto now = millis ();
    if (now - window_start_time_ > window_size_)
    {
        window_start_time_ += window_size_;
    }

    if (output_ > now - window_start_time_)
    {
        Serial.println ("Boiler On");
        Peripherals::SetBoilerOn ();
    }
    else
    {
        Serial.println ("Boiler Off");
        Peripherals::SetBoilerOff ();
    }

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
        Serial.println ("Shot finished");
        Peripherals::SetValveClosed ();
        pump_.SetOff ();
    }

    Serial.print ("Temperature: ");
    Serial.println (sensor_state.temperature);

    Serial.print ("Pressure: ");
    Serial.println (sensor_state.pressure);
}