#pragma once
#include "psm.h"

class Pump
{
public:
    Pump (u_char sense_pin, u_char control_pin, uint range, int mode);

private:
    static constexpr u_char kDivider = 1;
    static constexpr u_char kInterruptMinTimeDiff = 6;
    
    Psm psm_;
};
