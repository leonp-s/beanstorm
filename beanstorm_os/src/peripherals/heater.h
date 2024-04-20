#pragma once

#include <PID_v1.h>
#include <peripherals/peripherals.h>

class Heater
{
public:
    void Start ();
    void Stop ();

    void SetTarget (float set_point);

    void Loop (const Peripherals::SensorState & sensor_state);

private:
    static constexpr double kKp = 16.16;
    static constexpr double kKi = 0.14;
    static constexpr double kKd = 480.10;

    bool is_heating = false;
    double set_point_ {};
    double input_ {};
    double output_ {};
    int window_size_ = 1000;
    unsigned long window_start_time_ {};
    PID pid_ {&input_, &output_, &set_point_, kKp, kKi, kKd, DIRECT};
};