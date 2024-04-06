#include <cmath>
#include <stdint.h>
#include <Arduino_LSM6DS3.h>
#include "imu.h"

void initializeIMU() {
    if (!IMU.begin())
    {
        Serial.println("IMU failed to initialise");
        delay(500);
        while(1);
    }
}

uint8_t readIMU() {
    float x, y, z;
    float magnitude;
    uint8_t scaledMagnitude = 0;
    if (IMU.accelerationAvailable())
    {
        IMU.readAcceleration(x, y, z);
        magnitude = sqrt(x*x + y*y + z*z);
    }
    scaledMagnitude = 255 * (magnitude / 12);
    return scaledMagnitude;
}
