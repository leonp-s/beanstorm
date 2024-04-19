#pragma once

struct Model
{
    enum ProgramState
    {
        kIdle = 0,
        kBrew = 1,
        kError = 2
    };

    ProgramState program_state;
};