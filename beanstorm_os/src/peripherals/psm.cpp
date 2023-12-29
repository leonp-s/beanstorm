#include "psm.h"

Psm::Psm (unsigned char sense_pin,
          unsigned char control_pin,
          unsigned int range,
          int mode,
          unsigned char divider,
          unsigned char interrupt_min_time_diff,
          timer_group_t timer_group,
          timer_idx_t timer_idx)
    : timer_group_ (timer_group)
    , timer_idx_ (timer_idx)
{
    pinMode (sense_pin, INPUT_PULLUP);
    sense_pin_ = sense_pin;

    pinMode (control_pin, OUTPUT);
    control_pin_ = control_pin;

    divider_ = divider > 0 ? divider : 1;

    uint32_t interrupt_num = digitalPinToInterrupt (sense_pin_);
    if (interrupt_num != NOT_AN_INTERRUPT)
        attachInterruptArg (interrupt_num, Psm::OnZCInterrupt, this, mode);

    range_ = range;
    interrupt_min_time_diff_ = interrupt_min_time_diff;
}

void Psm::InitTimer (uint16_t delay)
{
    uint32_t us = delay > 1000u ? delay : delay > 55u ? 5500u : 6600u;
    timer_config_t config = {.divider = us,
                             .counter_dir = TIMER_COUNT_UP,
                             .counter_en = TIMER_PAUSE,
                             .alarm_en = TIMER_ALARM_DIS,
                             .auto_reload = TIMER_AUTORELOAD_EN};

    timer_init (timer_group_, timer_idx_, &config);
    timer_set_counter_value (timer_group_, timer_idx_, 0);
    timer_enable_intr (timer_group_, timer_idx_);
    timer_isr_callback_add (timer_group_, timer_idx_, OnPsmTimerInterrupt, this, 0);
    timer_start (timer_group_, timer_idx_);

    psm_interval_timer_initialized_ = true;
}

void Psm::OnZCInterrupt (void * args)
{
    auto psm = reinterpret_cast<Psm *> (args);

    if (psm->interrupt_min_time_diff_ > 0 &&
        millis () - psm->interrupt_min_time_diff_ < psm->last_millis_ &&
        millis () >= psm->last_millis_)
        return;

    psm->last_millis_ = millis ();

    psm->CalculateSkipFromZc ();

    if (psm->psm_interval_timer_initialized_)
    {
        timer_set_counter_value (psm->timer_group_, psm->timer_idx_, 0);
        timer_start (psm->timer_group_, psm->timer_idx_);
    }
}

bool Psm::OnPsmTimerInterrupt (void * args)
{
    auto psm = reinterpret_cast<Psm *> (args);

    timer_pause (psm->timer_group_, psm->timer_idx_);
    psm->UpdateControl (true);

    return true;
}

void Psm::Set (unsigned int value)
{
    if (value < range_)
        value_ = value;
    else
        value_ = range_;
}

long Psm::GetCounter ()
{
    return counter_;
}

void Psm::ResetCounter ()
{
    counter_ = 0;
}

void Psm::StopAfter (long counter)
{
    stop_after_ = counter;
}

void Psm::CalculateSkipFromZc ()
{
    if (divider_counter_ >= divider_)
    {
        divider_counter_ -= divider_;
        CalculateSkip ();
    }
    else
    {
        divider_counter_++;
    }

    UpdateControl (false);
}

void Psm::CalculateSkip ()
{
    a_ += value_;

    if (a_ >= range_)
    {
        a_ -= range_;
        skip_ = false;
    }
    else
    {
        skip_ = true;
    }

    if (a_ > range_)
    {
        a_ = 0;
        skip_ = false;
    }

    if (! skip_)
        counter_++;

    if (! skip_ && stop_after_ > 0 && counter_ > stop_after_)
        skip_ = true;
}

void Psm::UpdateControl (bool force_disable)
{
    if (force_disable || skip_)
        digitalWrite (control_pin_, LOW);
    else
        digitalWrite (control_pin_, HIGH);
}

unsigned int Psm::CPS ()
{
    unsigned int range = range_;
    unsigned int value = value_;
    unsigned char divider = divider_;

    range_ = 0xFFFF;
    value_ = 1;
    a_ = 0;
    divider_ = 1;
    skip_ = true;

    unsigned long stopAt = millis () + 1000;

    while (millis () < stopAt)
    {
        delay (0);
    }

    unsigned int result = a_;

    range_ = range;
    value_ = value;
    a_ = 0;
    divider_ = divider;

    return result;
}

unsigned long Psm::GetLastMillis () const
{
    return last_millis_;
}

unsigned char Psm::GetDivider () const
{
    return divider_;
}

void Psm::SetDivider (unsigned char divider)
{
    divider_ = divider > 0 ? divider : 1;
}

void Psm::ShiftDividerCounter (char value)
{
    divider_counter_ += value;
}