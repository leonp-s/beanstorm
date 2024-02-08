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
    uint8_t fault = thermocouple_.readFault ();

    if (fault)
    {
        Serial.print ("Fault 0x");
        Serial.println (fault, HEX);
        if (fault & MAX31865_FAULT_HIGHTHRESH)
        {
            Serial.println ("RTD High Threshold");
        }
        if (fault & MAX31865_FAULT_LOWTHRESH)
        {
            Serial.println ("RTD Low Threshold");
        }
        if (fault & MAX31865_FAULT_REFINLOW)
        {
            Serial.println ("REFIN- > 0.85 x Bias");
        }
        if (fault & MAX31865_FAULT_REFINHIGH)
        {
            Serial.println ("REFIN- < 0.85 x Bias - FORCE- open");
        }
        if (fault & MAX31865_FAULT_RTDINLOW)
        {
            Serial.println ("RTDIN- < 0.85 x Bias - FORCE- open");
        }
        if (fault & MAX31865_FAULT_OVUV)
        {
            Serial.println ("Under/Over voltage");
        }

        thermocouple_.clearFault ();
    }

    return thermocouple_.temperature (kRNominal, kRRef);
}
