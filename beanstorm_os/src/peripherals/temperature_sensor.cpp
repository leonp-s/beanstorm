#include "temperature_sensor.h"

TemperatureSensor::TemperatureSensor (Pins pins)
    : rtd_ (pins.spi_pin_cs, pins.spi_pin_di, pins.spi_pin_do, pins.spi_pin_clk)
{
}

void TemperatureSensor::Setup ()
{
    rtd_.begin (MAX31865_2WIRE);
}

float TemperatureSensor::ReadTemperature ()
{
    return rtd_.temperature (kRNominal, kRRef);
}

bool TemperatureSensor::HasError ()
{
    const auto fault = rtd_.readFault ();
    rtd_.clearFault ();

    if (! fault)
        return false;

    return true;
}
