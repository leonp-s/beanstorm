#pragma once
#include <PID_v1.h>
#include <peripherals/peripherals.h>
#include <peripherals/pump.h>

struct Program
{
    virtual ~Program () = default;

    virtual void Enter () = 0;
    virtual void Leave () = 0;
    virtual void Loop (const Peripherals::SensorState & sensor_state) = 0;
};

static constexpr double kKp = 16.16;
static constexpr double kKi = 0.14;
static constexpr double kKd = 480.10;

class IdleProgram : public Program
{
public:
    ~IdleProgram () override = default;

    void Enter () override;
    void Leave () override;
    void Loop (const Peripherals::SensorState & sensor_state) override;

private:
    double set_point_ {};
    double input_ {};
    double output_ {};
    int window_size_ = 1000;
    unsigned long window_start_time_ {};
    PID pid_ {&input_, &output_, &set_point_, kKp, kKi, kKd, DIRECT};
};

class BrewProgram : public Program
{
public:
    BrewProgram (Pump & pump);
    ~BrewProgram () override = default;

    void Enter () override;
    void Leave () override;
    void Loop (const Peripherals::SensorState & sensor_state) override;

private:
    Pump & pump_;
    float smoothed_pump_speed_normalised_ = 0.f;

    double set_point_ {};
    double input_ {};
    double output_ {};
    int window_size_ = 1000;
    unsigned long window_start_time_ {};
    unsigned long shot_start_time_ = 0;
    PID pid_ {&input_, &output_, &set_point_, kKp, kKi, kKd, DIRECT};
};

class ProgramController
{
public:
    ProgramController () = default;
    void LoadProgram (Program * program);
    void Loop (const Peripherals::SensorState & sensor_state);

private:
    Program * current_program_ = nullptr;
};
