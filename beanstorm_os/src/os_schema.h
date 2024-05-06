#pragma once

#include "brew_profile.h"
#include "schemas/beanstorm_schema.pb.h"

#include <pb_decode.h>
#include <pb_encode.h>

struct PIDConstants
{
    float kp;
    float ki;
    float kd;
};

struct PIDSchema
{
    bool Encode (const PIDConstants & pid_constants, std::size_t & bytes_written);
    void Decode (PIDConstants & pid_constants, std::size_t size) const;

    pb_byte_t buffer [PPID_size];
};

struct BrewProfileSchema
{
    bool Encode (const BrewProfile & brew_profile, std::size_t & bytes_written);
    void Decode (BrewProfile & brew_profile, std::size_t size);

    pb_byte_t buffer [PBrewProfile_size];
};
