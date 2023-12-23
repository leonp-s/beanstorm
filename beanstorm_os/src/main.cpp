#include <UMS3.h>

UMS3 ums3;

static constexpr auto kBaudRate = 9600;

void setup() {
    Serial.begin(kBaudRate);

    ums3.begin();
    ums3.setPixelBrightness(255 / 3);
}

int color = 0;

void uptime()
{
    long days=0;
    long hours=0;
    long mins=0;
    long secs=0;
    secs = millis() / 1000; //convect milliseconds to seconds
    mins=secs/60; //convert seconds to minutes
    hours=mins/60; //convert minutes to hours
    days=hours/24; //convert hours to days
    secs=secs-(mins*60); //subtract the coverted seconds to minutes in order to display 59 secs max
    mins=mins-(hours*60); //subtract the coverted minutes to hours in order to display 59 minutes max
    hours=hours-(days*24); //subtract the coverted hours to days in order to display 23 hours max
    //Display results
    Serial.println("Running Time");
    Serial.println("------------");
    if (days>0) // days will displayed only if value is greater than zero
    {
        Serial.print(days);
        Serial.print(" days and :");
    }
    Serial.print(hours);
    Serial.print(":");
    Serial.print(mins);
    Serial.print(":");
    Serial.println(secs);
}

void loop() {
    ums3.setPixelColor(UMS3::colorWheel(color));
    color++;
    uptime();
    delay(400);
}