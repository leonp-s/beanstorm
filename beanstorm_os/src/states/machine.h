#pragma once

#include <hfsm2/machine.hpp>
#include <iostream>

#define FSM_STATE(s) struct s

struct Context
{
    Pump & pump;
    HeaterProgram & heater_program;
};

using M = hfsm2::MachineT<hfsm2::Config::ManualActivation::ContextT<Context>>;
using FSM = M::PeerRoot<FSM_STATE (Idle), FSM_STATE (Brew)>;

struct Idle : FSM::State
{
    void enter (Control & control)
    {
        auto & context = control.context ();
        context.heater_program.SetTarget (86.0f);
        context.heater_program.StartHeater ();
    }

    void exit (Control & control)
    {
        auto & context = control.context ();
        context.heater_program.StopHeater ();
    }
};

struct Brew : FSM::State
{
public:
    static float SmoothedValue (float value_to_smooth, float target)
    {
        auto delta = 0.2f;
        auto step = (target - value_to_smooth) * delta;
        return value_to_smooth + step;
    }

    void enter (Control & control)
    {
        auto & context = control.context ();

        smoothed_pump_speed_normalised_ = 0.0f;
        shot_start_time_ = millis ();

        context.pump.SetOff ();
        context.heater_program.SetTarget (94.0f);
        context.heater_program.StartHeater ();
        Peripherals::SetValveOpened ();
    }

    void exit (Control & control)
    {
        auto & context = control.context ();
        context.pump.SetOff ();
        context.heater_program.StopHeater ();
        Peripherals::SetValveClosed ();
    }

    void update (FullControl & control)
    {
        auto & context = control.context ();

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
                smoothed_pump_speed_normalised_ =
                    SmoothedValue (smoothed_pump_speed_normalised_, 0.0f);
            }
            else
            {
                Serial.println ("Infuse");
                smoothed_pump_speed_normalised_ =
                    SmoothedValue (smoothed_pump_speed_normalised_, 0.7f);
            }

            Serial.println (smoothed_pump_speed_normalised_);
            context.pump.SetSpeed (std::round (smoothed_pump_speed_normalised_ * 200.f));
        }
        else
        {
            control.changeTo<Idle> ();
        }
    }

private:
    float smoothed_pump_speed_normalised_ = 0.f;
    unsigned long shot_start_time_ = 0;
};