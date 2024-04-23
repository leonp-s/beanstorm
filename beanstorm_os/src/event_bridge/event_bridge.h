#pragma once
#include "lock_free_queue.h"
#include "model.h"

#include <functional>
#include <os_preferences.h>

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
    std::function<void ()> OnStartShot;

    void CancelShot ();
    std::function<void ()> OnCancelShot;

    void UpdateHeaterPID (const PIDConstants & pid_constants);
    std::function<void (const PIDConstants & pid_constants)> OnHeaterPIDUpdated;

    void UpdatePumpPID (const PIDConstants & pid_constants);
    std::function<void (const PIDConstants & pid_constants)> OnPumpPIDUpdated;

    void Loop ();

private:
    struct Event
    {
        enum class Type
        {
            kStartShot,
            kCancelShot,
            kUpdateHeaterPID,
            kUpdatePumpPID,
        };

        union Data
        {
            PIDConstants pid_constants_;
        };

        Type type;
        Data data;
    };

    LockFreeQueue<Event> event_queue_;
};
