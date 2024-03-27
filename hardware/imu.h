/* Code to initialise and read the onboard inertial measurment unit. Initialising prints to serial if IMU fails to start. readIMU returns a uint8_t
   representing the overall acceleration, using the sum of the absolute values of each axis. */

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
    uint8_t sum = 0;
    
    if (IMU.accelerationAvailable())
    {
        IMU.readAcceleration(x, y, z);
        sum = abs(x) + abs(y) + abs(z);
    }
    else
    {
        Serial.println("Acceleration unavailable");
    }
    
    return sum;
}
