#include <Wire.h>
#include <Adafruit_TCS34725.h>
#include "tcs.h"

Adafruit_TCS34725 tcs(101);

void initializeTCS() {
  if (!tcs.begin())
  {
    Serial.print("TCS not found ... Check connection");
    while (1);
  }
}

std::array<uint16_t, 5> readTCS() {
  uint16_t r, g, b, c, colorTemp, lux;

  tcs.getRawData(&r, &g, &b, &c);
  colorTemp = tcs.calculateColorTemperature_dn40(r, g, b, c); 
  lux = tcs.calculateLux(r, g, b);

  std::array<uint16_t, 5> output = {r, g, b, colorTemp, lux};
  Serial.print("Red: ");Serial.print(r); Serial.print(", ");
  Serial.print("Green: ");Serial.print(g); Serial.print(", ");
  Serial.print("Blue: ");Serial.print(b); Serial.print(", ");
  Serial.print("Clear: ");Serial.print(c); Serial.print(", ");
  Serial.print("Temp: ");Serial.print(colorTemp); Serial.print(", ");
  Serial.print("Lux (Digital): ");Serial.println(lux); 
  return output;
}
