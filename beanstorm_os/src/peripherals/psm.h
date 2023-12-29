#pragma once

#include <Arduino.h>
#include <driver/timer.h>

class Psm
{
public:
    Psm (unsigned char sense_pin,
         unsigned char control_pin,
         unsigned int range,
         int mode = RISING,
         unsigned char divider = 1,
         unsigned char interrupt_min_time_diff = 0,
         timer_group_t timer_group = TIMER_GROUP_0,
         timer_idx_t timer_idx = TIMER_0);

    void InitTimer (uint16_t delay);
    void Set (unsigned int value);
    long GetCounter () const;
    void ResetCounter ();
    void StopAfter (long counter);
    unsigned int CPS ();
    unsigned long GetLastMillis () const;
    unsigned char GetDivider () const;
    void SetDivider (unsigned char divider = 1);
    void ShiftDividerCounter (char value = 1);

private:
    static void OnZCInterrupt (void * args);
    static bool OnPsmTimerInterrupt (void * args);
    inline void CalculateSkipFromZc ();
    void CalculateSkip ();
    void UpdateControl (bool force_disable = true) const;

    const timer_group_t timer_group_;
    const timer_idx_t timer_idx_;

    unsigned char sense_pin_;
    unsigned char control_pin_;
    unsigned int range_;
    unsigned char divider_ = 1;
    unsigned char divider_counter_ = 1;
    unsigned char interrupt_min_time_diff_;
    volatile unsigned int value_ {};
    volatile unsigned int a_ {};
    volatile bool skip_ = true;
    volatile long counter_ {};
    volatile long stop_after_ {};
    volatile unsigned long last_millis_ = 0;

    bool psm_interval_timer_initialized_ = false;
    esp_timer_handle_t psm_interval_timer_ {};
};