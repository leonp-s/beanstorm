#pragma once

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
    bool Encode (const PIDConstants & pid_constants);
    PIDConstants Decode () const;

    pb_byte_t buffer [PPID_size];
};

struct BrewProfileSchema
{
    bool Encode (const PBrewProfile & brew_profile);
    PBrewProfile Decode () const;

    pb_byte_t buffer [PBrewProfile_size];
};

bool BrewProfileSchema::Encode (const PBrewProfile & brew_profile)
{
    return false;
}

PBrewProfile BrewProfileSchema::Decode () const
{
    return PBrewProfile ();
}
