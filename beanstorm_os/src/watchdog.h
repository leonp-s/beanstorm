#pragma once

#include <FreeRTOS.h>
#include <task.h>

class TaskWatchdog
{
public:
    static bool SetupWatchdog (int timeout);
    static bool AddTask (TaskHandle_t task);
    static bool RemoveTask (TaskHandle_t task);
    static void Reset ();
    static bool IsBootReasonReset ();
};
