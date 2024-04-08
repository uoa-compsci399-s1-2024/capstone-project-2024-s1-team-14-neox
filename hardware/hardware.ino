#include <Wire.h>
#include "sensor_sample.h"
#include "eeprom.h"
#include "imu.h"
#include "rtc.h"
#include "ble.h"

static const unsigned int SERIAL_BAUD_RATE = 9600;
static const uint32_t POLL_INTERVAL_MS = (uint32_t)60 * 1000; // 1 minute
static const uint8_t UV_SENSOR_PIN = A0;
static const uint8_t LIGHT_SENSOR_PIN = A1;

// Read all sensors and save them to the EEPROM
static void readSample();

void setup()
{
  Serial.begin(SERIAL_BAUD_RATE);
  while (!Serial);
  Wire.begin();
  initializeBLE();
  initializeIMU();
  initializeRTC();
  eepromBegin();
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
  sample.light = analogRead(LIGHT_SENSOR_PIN);
  sample.acceleration = readIMU();
  eepromPushSample(&sample);
}
