#include <Wire.h>
#include "eeprom.h"

void setup()
{
  Serial.begin(9600);
  Wire.begin();

  if (!eepromBegin()) {
    Serial.println("eepromBegin() failed.");
    while (true) { delay(1000); }
  }

  Serial.println("=== begin ===");
  SensorSample sample{};
  Serial.println(eepromGetSampleBufferLength());

  eepromPushSample(&sample);
  Serial.println(eepromGetSampleBufferLength());

  eepromLockSampleBuffer();
  for (int i = 0; i < 100; i++)
    eepromPushSample(&sample);
  Serial.println(eepromGetSampleBufferLength());
  
  eepromUnlockSampleBuffer();
  eepromPushSample(&sample);
  Serial.println(eepromGetSampleBufferLength());
}

void loop()
{

}
