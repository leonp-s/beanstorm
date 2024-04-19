#pragma once
#include "lock_free_queue.h"
#include "model.h"

#include <functional>

class NotificationBridge
{
public:
    void UpdateModel (const Model & model);
    std::function<void (Model)> OnModelUpdated;

    void Loop ();

private:
    struct Event
    {
        enum class Type
        {
            kUpdateModel,
        };

        union Data
        {
            Model model;
        };

        Type type;
        Data data;
    };

    LockFreeQueue<Event> notification_queue_;
};

class EventBridge
{
public:
    void StartShot ();
    void CancelShot ();

    std::function<void ()> OnStartShot;
    std::function<void ()> OnCancelShot;

    void Loop ();

private:
    struct Event
    {
        enum class Type
        {
            kStartShot,
            kCancelShot
        };

        union Data
        {
        };

        Type type;
        Data data;
    };

    LockFreeQueue<Event> event_queue_;
};
