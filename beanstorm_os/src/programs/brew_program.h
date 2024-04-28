#pragma once

#include "program.h"

#include <QuickPID.h>
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

    float target_pressure_ {};
    float input_ {};
    float output_ {};

    QuickPID
        pid_ {&input_, &output_, &target_pressure_, 0.0f, 0.0f, 0.0f, QuickPID::Action::direct};
};
