#pragma once


class ProgramController
{
public:
    enum class Program
    {
        kIdle
    };

    ProgramController () = default;
    void LoadProgram (Program program);

private:
};
