#ifndef _RTC_H_
#define _RTC_H_
#include <stdint.h>


/*Struct to hold hour and minutes values returned by readRTC() function*/
struct time {
    uint8_t hour;
    uint8_t minute;
};

/*Initialises the RTC with parameters hour and minute*/
void initializeRTC(int hour, int minute);

/*Returns time struct with current values of time and hour. Used to keep timestamps for other sensor readings*/
time readRTC();

#endif
