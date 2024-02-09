#include "pressure_sensor.h"

void PressureSensor::Setup ()
{
    ads_.begin ();
    ads_.setGain (0);
    ads_.setDataRate (4);
    ads_.setMode (0);
    ads_.readADC (0);
}

float PressureSensor::ReadPressure ()
{
    return static_cast<float> ((ads_.getValue () - 2666)) / 1777.8f;
}

bool PressureSensor::HasError ()
{
    static constexpr auto kNoErrorCode = 0;
    static constexpr auto kInvalidVoltageErrorCode = -100;
    static constexpr auto kInvalidGainErrorCode = 255;
    static constexpr auto kInvalidModeErrorCode = 254;

    const auto error_result = ads_.getError ();

    if (error_result == kNoErrorCode)
        return false;

    // if (error_result == kInvalidVoltageErrorCode)
    //     error = Error::kInvalidVoltage;
    // if (error_result == kInvalidGainErrorCode)
    //     error = Error::kInvalidGain;
    // if (error_result == kInvalidModeErrorCode)
    //     error = Error::kInvalidMode;

    return true;
}