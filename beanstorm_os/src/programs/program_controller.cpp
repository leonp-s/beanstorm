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