#ifndef _SENSOR_SAMPLE_H
#define _SENSOR_SAMPLE_H

#include "imu.h"
#include <array>

/*
 * The uv and light fields store the output of analogRead().
 * To convert this value to a voltage, see
 * https://www.arduino.cc/reference/en/language/functions/analog-io/analogread/
 * 
 * Acceleration is in (0x7fff/4)*g units.
 */

struct SensorSample {
  std::array<uint8_t, 4> timestamp;
  uint16_t uv;
  uint16_t light;
  Acceleration acceleration;
  std::array<uint16_t, 5> color;
};

//static_assert(sizeof(SensorSample) == 24, "SensorSample struct layout assertion failed.");

#endif
