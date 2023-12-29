#include "pump.h"

Pump::Pump (u_char sense_pin, u_char control_pin, uint range, int mode)
    : psm_ (sense_pin, control_pin, range, mode, kDivider, kInterruptMinTimeDiff)
{
}
