#include <UMS3.h>

UMS3 ums3;
static constexpr auto kBaudRate = 9600;

int color = 0;

void setup ()
{
    Serial.begin (kBaudRate);
    ums3.begin ();
    ums3.setPixelBrightness (255 / 3);
}

void loop ()
{
    ums3.setPixelColor (UMS3::colorWheel (color));
    color++;
    delay (400);
}
