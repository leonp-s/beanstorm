#pragma once

#include <string>
#include <vector>

struct ControlPoint
{
    float time;
    float value;
};

enum class ControlType
{
    kPressure,
    kFlow
};

struct BrewProfile
{
    std::string uuid;
    float temperature;
    ControlType control_type;
    std::vector<ControlPoint> control_points;
};