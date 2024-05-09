#include <Wire.h>
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

std::array<uint16_t, 5> readTCS() {
  uint16_t r, g, b, c, colorTemp, lux;

  tcs.getRawData(&r, &g, &b, &c);
  colorTemp = tcs.calculateColorTemperature_dn40(r, g, b, c); 
  lux = tcs.calculateLux(r, g, b);

  std::array<uint16_t, 5> output = {r, g, b, colorTemp, lux};
  return output;
}
