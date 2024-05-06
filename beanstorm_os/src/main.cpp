#include "beanstorm.h"
#include "ble/beanstorm_ble.h"
#include "event_bridge/event_bridge.h"
#include "os_preferences.h"

#include <UMS3.h>

static constexpr auto kBaudRate = 9600;

UMS3 ums3;

NotificationBridge notification_bridge;
EventBridge event_bridge;

OsPreferences os_preferences;
DataService data_service {event_bridge, os_preferences};
BeanstormBLE beanstorm_ble {data_service};

Beanstorm beanstorm {data_service, event_bridge};

void setup ()
{
    Serial.begin (kBaudRate);
    ums3.begin ();

    beanstorm.Setup ();
    Serial.println ("Setup - Beanstorm");

    beanstorm_ble.Setup ();
    Serial.println ("Setup - BLE");

    os_preferences.Setup ();
    Serial.println ("Setup - OS Preferences");

    auto heater_pid_constants = os_preferences.LoadHeaterPID ();
    auto pump_pid_constants = os_preferences.LoadPumpPID ();
    auto brew_profile = os_preferences.LoadBrewProfile ();

    Serial.println ("Setup - Preferences Loaded");

    data_service.HeaterPIDUpdated (heater_pid_constants);
    data_service.PumpPIDUpdated (pump_pid_constants);
}

void loop ()
{
    beanstorm.Loop ();
}
