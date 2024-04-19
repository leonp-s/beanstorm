#include "beanstorm.h"
#include "ble/beanstorm_ble.h"
#include "event_bridge/event_bridge.h"

#include <UMS3.h>

static constexpr auto kBaudRate = 9600;

UMS3 ums3;

NotificationBridge notification_bridge;
EventBridge event_bridge;

DataService data_service {event_bridge};
BeanstormBLE beanstorm_ble {data_service};

Beanstorm beanstorm {data_service, event_bridge, notification_bridge};

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
