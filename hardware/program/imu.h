#ifndef _IMU_H_
#define _IMU_H_

struct Acceleration {
    int16_t x;
    int16_t y;
    int16_t z;
};

/*Initialise the IMU. Prints an error message to serial if failed to initialise.*/
void initializeIMU();

/*Returns the acceleration from IMU. Used to determine if user is wearing the device*/
Acceleration readIMU();

#endif
