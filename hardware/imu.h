#ifndef _IMU_H_
#define _IMU_H_

/*Initialise the IMU. Prints an error message to serial if failed to initialise.*/
void initializeIMU();

/*Returns the sum of all three axis' acceleration from IMU. Used to determine if user is wearing the device*/
uint8_t readIMU();

#endif
