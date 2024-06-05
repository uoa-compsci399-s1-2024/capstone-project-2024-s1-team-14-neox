#ifndef _SENSOR_SAMPLE_H
#define _SENSOR_SAMPLE_H

#include "imu.h"
#include "tcs.h"
#include <array>

/*
 * The uv and light fields store the output of analogRead().
 * To convert this value to a voltage, see
 * https://www.arduino.cc/reference/en/language/functions/analog-io/analogread/
 * 
 * Acceleration is in (9.8 * 4 / 0x7fff) ms^-2 units.
 */

struct SensorSample {
  std::array<uint8_t, 4> timestamp; // Use uint8_t array instead of uint32_t to avoid aligning to 4 bytes
  uint16_t uv;
  Acceleration acceleration;
  TCSData tcsData;
};

static_assert(sizeof(SensorSample) == 20, "SensorSample struct layout assertion failed.");

#endif
