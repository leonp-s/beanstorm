#include "event_bridge.h"

void NotificationBridge::UpdateModel (const Model & model)
{
    notification_queue_.Push (Event {.type = Event::Type::kUpdateModel, .data = {model}});
}

void NotificationBridge::Loop ()
{
    while (const auto event = notification_queue_.Pop ())
    {
        switch (event->type)
        {
            case Event::Type::kUpdateModel:
                OnModelUpdated (event->data.model);
                break;
        }
    }
}

void EventBridge::StartShot ()
{
    event_queue_.Push (Event {.type = Event::Type::kStartShot, .data = {}});
}

void EventBridge::CancelShot ()
{
    event_queue_.Push (Event {.type = Event::Type::kCancelShot, .data = {}});
}

void EventBridge::Loop ()
{
    while (const auto event = event_queue_.Pop ())
    {
        switch (event->type)
        {
            case Event::Type::kStartShot:
                OnStartShot ();
                break;
            case Event::Type::kCancelShot:
                OnCancelShot ();
                break;
        }
    }
}