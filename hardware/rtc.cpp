#include <RTCZero.h>
#include "rtc.h"

static RTCZero rtc;

void initializeRTC(int hour, int minute) {
    rtc.begin();
    rtc.setHours(hour);
    rtc.setMinutes(minute);
}

time readRTC() {
    time output;
    output.hour = rtc.getHours();
    output.minute = rtc.getMinutes();
    return output;
}
