#ifndef _TCS_H
#define _TCS_H

#include <array>

// Initialise TCS, prints an error to serial if initialisation fails
void initializeTCS();

// Returns an array containing red, green, blue and clear channel values from the colour light sensor. Also returns brightness in lux and colour temperature in kelvin
std::array<uint16_t, 5> readTCS();

#endif
