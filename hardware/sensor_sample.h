#ifndef _SENSOR_SAMPLE_H
#define _SENSOR_SAMPLE_H

#include "rtc.h"
#include "imu.h"

/*
 * The uv and light fields store the output of analogRead().
 * To convert this value to a voltage, see
 * https://www.arduino.cc/reference/en/language/functions/analog-io/analogread/
 * 
 * Acceleration is in (0x7fff/4)*g units.
 */

struct SensorSample {
  time timestamp;
  uint16_t uv;
  uint16_t light;
  Acceleration acceleration;
};

static_assert(sizeof(SensorSample) == 12, "SensorSample struct layout assertion failed.");

#endif
