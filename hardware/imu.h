#include <cmath>
#include <stdint.h>
#include <Arduino_LSM6DS3.h>

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
    
    if (IMU.accelerationAvailable())
    {
        IMU.readAcceleration(x, y, z);
        sum = abs(x) + abs(y) + abs(z);
    }
    uint8_t acceleration = sum;
    return acceleration;
}