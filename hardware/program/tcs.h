#ifndef _TCS_H
#define _TCS_H

struct TCSData {
    uint16_t red;
    uint16_t green;
    uint16_t blue;
    uint16_t clear;
};

// Initialise TCS, prints an error to serial if initialisation fails
void initializeTCS();

TCSData readTCS();

#endif
