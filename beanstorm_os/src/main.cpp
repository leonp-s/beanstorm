#include "beanstorm.h"
#include "ble/beanstorm_ble.h"

#include <UMS3.h>

static constexpr auto kBaudRate = 9600;

UMS3 ums3;

BeanstormBLE beanstorm_ble;
Beanstorm beanstorm {beanstorm_ble};

void setup ()
{
    Serial.begin (kBaudRate);
    ums3.begin ();
    beanstorm.Setup ();
}

void loop ()
{
}
