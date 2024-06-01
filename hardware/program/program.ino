#include <Wire.h>
#include "sensor_sample.h"
#include "eeprom.h"
#include "imu.h"
#include "rtc.h"
#include "ble.h"
#include "tcs.h"

static const int SERIAL_BAUD_RATE = 9600;
static const uint32_t POLL_INTERVAL_MS = (uint32_t)2 * 1000; // 1 minute
static const uint8_t UV_SENSOR_PIN = A6;

// Read all sensors and save them to the EEPROM
static void readSample();

void setup()
{
  pinMode(A0, OUTPUT);
  pinMode(A1, OUTPUT);
  digitalWrite(A0, LOW);
  digitalWrite(A1, HIGH);
  
  Serial.begin(SERIAL_BAUD_RATE);
  delay(1000);

  Wire.begin();
  eepromBegin();
  initializeBLE();
  initializeIMU();
  initializeRTC();
  initializeTCS();
  // uint8_t key[32] = "0123456789";
  // eepromFactoryReset(key);
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
  sample.acceleration = readIMU();
  sample.tcsData = readTCS();
  Serial.println();
  eepromPushSample(&sample);
}
