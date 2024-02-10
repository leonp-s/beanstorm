#include "watchdog.h"

#include <esp_task_wdt.h>

bool TaskWatchdog::SetupWatchdog (int timeout)
{
    auto result = esp_task_wdt_init (timeout, true);
    return result != ESP_OK;
}

bool TaskWatchdog::AddTask (TaskHandle_t task)
{
    auto result = esp_task_wdt_add (task);
    return result != ESP_OK;
}

bool TaskWatchdog::RemoveTask (TaskHandle_t task)
{
    auto result = esp_task_wdt_delete (task);
    return result != ESP_OK;
}

void TaskWatchdog::Reset ()
{
    esp_task_wdt_reset ();
}

bool TaskWatchdog::IsBootReasonReset ()
{
    static constexpr auto kWDTBootReason = 6;
    const auto boot_reason = esp_reset_reason ();
    return boot_reason == kWDTBootReason;
}