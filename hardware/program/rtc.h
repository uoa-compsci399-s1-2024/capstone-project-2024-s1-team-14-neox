#ifndef _RTC_H_
#define _RTC_H_
#include <stdint.h>
#include <array>

/*Initialises the RTC with current epoch*/
void initializeRTC();

/*Returns current epoch. Used to keep timestamps for other sensor readings*/
std::array<uint8_t, 4> readRTC();

#endif
