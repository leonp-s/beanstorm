#include <UMS3.h>
#include "beanstorm.h"

static constexpr auto kBaudRate = 9600;

UMS3 ums3;
Beanstorm beanstorm;

void setup ()
{
    Serial.begin (kBaudRate);
    ums3.begin ();
    beanstorm.Setup ();
}

void loop ()
{
}
