#ifndef _SENSOR_SAMPLE_H
#define _SENSOR_SAMPLE_H

#include "rtc.h"

/*
 * The uv and light fields store the output of analogRead().
 * To convert this value to a voltage, see
 * https://www.arduino.cc/reference/en/language/functions/analog-io/analogread/
 */

struct SensorSample {
  time timestamp;
  uint16_t uv;
  uint16_t light;
  uint8_t acceleration;
} __attribute__((packed));

#endif
