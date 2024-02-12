#include "beanstorm.h"
#include "ble/beanstorm_ble.h"

#include <UMS3.h>

static constexpr auto kBaudRate = 9600;

UMS3 ums3;

DataService data_service;
BeanstormBLE beanstorm_ble {data_service};
Beanstorm beanstorm {data_service};

void setup ()
{
    Serial.begin (kBaudRate);
    Wire.begin (SDA, SCL);
    ums3.begin ();
    beanstorm.Setup ();
    beanstorm_ble.Setup ();
}

void loop ()
{
    beanstorm.Loop ();
}
