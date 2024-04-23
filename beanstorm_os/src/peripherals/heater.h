#pragma once

#include "os_preferences.h"

#include <PID_v1.h>
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
    double set_point_ {};
    double input_ {};
    double output_ {};
    int window_size_ = 1000;
    unsigned long window_start_time_ {};
    PID pid_ {&input_, &output_, &set_point_, 0.0, 0.0, 0.0, DIRECT};
};