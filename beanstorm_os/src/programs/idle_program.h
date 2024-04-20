#pragma once

#include "program.h"

#include <peripherals/heater.h>
#include <peripherals/peripherals.h>

class IdleProgram : public Program
{
public:
    explicit IdleProgram (Heater & heater);
    ~IdleProgram () override = default;

    void Enter () override;
    void Leave () override;
    void Loop (const Peripherals::SensorState & sensor_state) override;

private:
    Heater & heater_;
};