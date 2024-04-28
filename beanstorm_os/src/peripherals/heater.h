#pragma once

#include "os_preferences.h"

#include <QuickPID.h>
#include <peripherals/peripherals.h>

class Heater
{
public:
    void Start ();
    void Stop ();
    void SetTunings (const PIDConstants & pid_constants);

    void SetTarget (float set_point);

    void Loop (const Peripherals::SensorState & sensor_state);

private:
    bool is_heating = false;
    float set_point_ {};
    float input_ {};
    float output_ {};
    int window_size_ = 1000;
    unsigned long window_start_time_ {};
    QuickPID pid_ {&input_, &output_, &set_point_, 0.0f, 0.0f, 0.0f, QuickPID::Action::direct};
};