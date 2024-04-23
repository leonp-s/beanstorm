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
DataService data_service {event_bridge};
BeanstormBLE beanstorm_ble {data_service};

Beanstorm beanstorm {data_service, event_bridge};

//    os_preferences_.SaveHeaterPID ({.kp = 16.16, .ki = 0.14, .kd = 480.10});
//    os_preferences_.SavePumpPID ({.kp = 0.1, .ki = 0.0, .kd = 0.0});
//    BrewProfile default_profile {.uuid = "5791f6ba-45db-4900-912e-8fe65af0bc05",
//                                 .temperature = 86.0f,
//                                 .control_type = ControlType::kFlow,
//                                 .control_points = {ControlPoint {.time = 0.0f, .value
//                                 = 6.0f},
//                                                    ControlPoint {.time = 10.0f, .value
//                                                    = 6.0f}, ControlPoint {.time = 10.0f,
//                                                    .value = 3.0f}, ControlPoint {.time
//                                                    = 20.0f, .value = 3.0f}, ControlPoint
//                                                    {.time = 20.0f, .value = 6.0f},
//                                                    ControlPoint {.time = 30.0f, .value
//                                                    = 6.0f}}};
//    os_preferences_.SaveBrewProfile (default_profile);

void setup ()
{
    Serial.begin (kBaudRate);
    Wire.begin (SDA, SCL);
    ums3.begin ();

    os_preferences.Setup ();

    auto heater_pid_constants = os_preferences.LoadHeaterPID ();
    auto pump_pid_constants = os_preferences.LoadPumpPID ();
    auto brew_profile = os_preferences.LoadBrewProfile ();

    event_bridge.UpdateHeaterPID (heater_pid_constants);
    event_bridge.UpdatePumpPID (pump_pid_constants);

    beanstorm.Setup ();
    beanstorm_ble.Setup ();
}

void loop ()
{
    beanstorm.Loop ();
}
