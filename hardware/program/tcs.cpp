#include <Adafruit_TCS34725.h>
#include "tcs.h"

Adafruit_TCS34725 tcs(101);

void initializeTCS() {
  if (!tcs.begin())
  {
    Serial.print("TCS not found ... Check connection");
    while (1);
  }
  // Save power
  tcs.disable();
}

TCSData readTCS() {
  TCSData data = { 0 };
  tcs.getRawDataOneShot(&data.red, &data.green, &data.blue, &data.clear);
  return data;
}
