#include <Wire.h>
#include "sensor_sample.h"
#include "eeprom.h"
#include "imu.h"
#include "rtc.h"
#include "ble.h"

<<<<<<< Updated upstream:hardware/hardware.ino
static const unsigned int SERIAL_BAUD_RATE = 9600;
static const uint32_t POLL_INTERVAL_MS = (uint32_t)60 * 1000; // 1 minute
=======
static const int SERIAL_BAUD_RATE = 9600;
static const uint32_t POLL_INTERVAL_MS = (uint32_t)2 * 1000; // 1 minute
>>>>>>> Stashed changes:hardware/program/program.ino
static const uint8_t UV_SENSOR_PIN = A6;
static const uint8_t LIGHT_SENSOR_PIN = A7;

// Read all sensors and save them to the EEPROM
static void readSample();

void setup()
{
  pinMode(A0, OUTPUT);
  pinMode(A1, OUTPUT);
  digitalWrite(A0, LOW);
  digitalWrite(A1, HIGH);

  Serial.begin(SERIAL_BAUD_RATE);
  while (!Serial);
  Wire.begin();
  eepromBegin();
  initializeBLE();
  initializeIMU();
  initializeRTC();
  
  //uint8_t key[32] = "verysecure";
  //eepromFactoryReset(key);
}

void loop()
{
  static uint32_t lastSampleReadTime = 0;
  uint32_t now = millis();

  if (now - lastSampleReadTime >= POLL_INTERVAL_MS)
  {
    lastSampleReadTime += POLL_INTERVAL_MS;
    readSample();
  }
  checkConnection();


}

static void readSample()
{
  SensorSample sample = { 0 };
  sample.timestamp = readRTC();
  sample.uv = analogRead(UV_SENSOR_PIN);
  Serial.print(sample.uv);
  Serial.print(",");
  sample.light = analogRead(LIGHT_SENSOR_PIN);
<<<<<<< Updated upstream:hardware/hardware.ino
  sample.acceleration = readIMU();
=======
  Serial.print(sample.light);
  Serial.print(",");
  sample.acceleration = readIMU(); 
  sample.color = readTCS();
>>>>>>> Stashed changes:hardware/program/program.ino
  eepromPushSample(&sample);
  Serial.println(",");
}
