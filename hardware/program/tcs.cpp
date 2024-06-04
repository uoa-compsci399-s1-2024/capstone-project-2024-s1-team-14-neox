#include <Adafruit_TCS34725.h>
#include "tcs.h"
#include "error.h"

Adafruit_TCS34725 tcs(101);

void initializeTCS() {
  if (!tcs.begin())
  {
    showError(ERROR_TCS_BEGIN);
  }
}

TCSData readTCS() {
  TCSData data = { 0 };
  // uint16_t colorTemp, lux;
  tcs.getRawData(&data.red, &data.green, &data.blue, &data.clear);
  // colorTemp = tcs.calculateColorTemperature_dn40(data.red, data.green, data.blue, data.clear); 
  // lux = tcs.calculateLux(data.red, data.green, data.blue);
  // Serial.print(data.red);
  // Serial.print(",");
  // Serial.print(data.green);
  // Serial.print(",");
  // Serial.print(data.blue);
  // Serial.print(",");
  // Serial.print(data.clear);
  // Serial.print(",");
  // Serial.print(colorTemp);
  // Serial.print(",");
  // Serial.print(lux);
  return data;
}
