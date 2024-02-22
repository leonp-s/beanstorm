#pragma once
#include "lock_free_queue.h"

#include <functional>

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
