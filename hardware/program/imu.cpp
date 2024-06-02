#include <cmath>
#include <stdint.h>
#include <Arduino_LSM6DS3.h>
#include "imu.h"
#include "error.h"

void initializeIMU() {
    if (!IMU.begin())
    {
        showError(ERROR_IMU_BEGIN);
    }
}

Acceleration readIMU() {
    float x = 0.0f;
    float y = 0.0f;
    float z = -1.0f;
    if (IMU.accelerationAvailable())
    {
        IMU.readAcceleration(x, y, z);
    }

    Acceleration acc;
    acc.x = (int16_t)(x / 4.0f * 0x7FFF);
    acc.y = (int16_t)(y / 4.0f * 0x7FFF);
    acc.z = (int16_t)(z / 4.0f * 0x7FFF);
    // Serial.print(acc.x);
    // Serial.print(",");
    // Serial.print(acc.y);
    // Serial.print(",");
    // Serial.print(acc.z);
    // Serial.print(",");
    return acc;
}
