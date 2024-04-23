#pragma once

#include "program.h"

#include <PID_v1.h>
#include <brew_profile.h>
#include <peripherals/heater.h>
#include <peripherals/peripherals.h>
#include <peripherals/pump.h>

class BrewProgram : public Program
{
public:
    BrewProgram (Pump & pump, Heater & heater, const BrewProfile & brew_profile);
    ~BrewProgram () override = default;

    void SetPumpTunings (const PIDConstants & pid_constants);
    void Enter () override;
    void Leave () override;
    void Loop (const Peripherals::SensorState & sensor_state) override;

    std::function<void ()> OnShotEnded;

private:
    [[nodiscard]] float GetTargetValue (float shot_time) const;

    Pump & pump_;
    Heater & heater_;
    const BrewProfile & brew_profile_;
    float shot_duration_ = 0.0f;
    unsigned long shot_start_time_ = 0;

    double target_pressure_ {};
    double input_ {};
    double output_ {};
    PID pid_ {&input_, &output_, &target_pressure_, 0.0, 0.0, 0.0, DIRECT};
};
