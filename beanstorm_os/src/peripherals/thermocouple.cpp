#include "thermocouple.h"

Thermocouple::Thermocouple (int8_t spi_pin_cs,
                            int8_t spi_pin_di,
                            int8_t spi_pin_do,
                            int8_t spi_pin_clk)
    : thermocouple_ (spi_pin_cs, spi_pin_di, spi_pin_do, spi_pin_clk)
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
