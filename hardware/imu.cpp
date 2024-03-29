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
    float sum;
    uint8_t scaled_sum = 0;
    if (IMU.accelerationAvailable())
    {
        IMU.readAcceleration(x, y, z);
        sum = abs(x) + abs(y) + abs(z);
    }
    scaled_sum = 255 * (sum / 12);
    return scaled_sum;
}
