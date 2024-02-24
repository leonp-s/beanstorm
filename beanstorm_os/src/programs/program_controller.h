#pragma once

#include "program.h"

#include <peripherals/peripherals.h>

class ProgramController
{
public:
    ProgramController () = default;

    void LoadProgram (Program * program);
    void Loop (const Peripherals::SensorState & sensor_state);

private:
    Program * current_program_ = nullptr;
};
