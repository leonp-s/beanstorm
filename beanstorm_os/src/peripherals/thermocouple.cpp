#include "thermocouple.h"

Thermocouple::Thermocouple (Pins pins)
    : thermocouple_ (pins.spi_pin_cs, pins.spi_pin_di, pins.spi_pin_do, pins.spi_pin_clk)
{
}

void Thermocouple::Setup ()
{
    thermocouple_.begin (MAX31865_2WIRE);
}

float Thermocouple::ReadTemperature ()
{
    return thermocouple_.temperature (kRNominal, kRRef);
}

bool Thermocouple::HasError ()
{
    const auto fault = thermocouple_.readFault ();
    thermocouple_.clearFault ();

    if (! fault)
        return false;

    return true;
}
