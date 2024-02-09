#pragma once

#include <Adafruit_MAX31865.h>

class Thermocouple
{
public:
    struct Pins
    {
        int8_t spi_pin_cs;
        int8_t spi_pin_di;
        int8_t spi_pin_do;
        int8_t spi_pin_clk;
    };

    explicit Thermocouple (Pins pins);
    void Setup ();
    float ReadTemperature ();
    bool HasError ();

private:
    static constexpr float kRRef = 430.0f;
    static constexpr float kRNominal = 100.0f;

    Adafruit_MAX31865 thermocouple_;
};
