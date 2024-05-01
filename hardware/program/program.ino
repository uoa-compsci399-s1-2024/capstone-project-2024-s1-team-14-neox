#include <Wire.h>
#include "sensor_sample.h"
#include "eeprom.h"
#include "imu.h"
#include "rtc.h"
#include "ble.h"
#include "tcs.h"

static const int SERIAL_BAUD_RATE = 9600;
static const uint32_t POLL_INTERVAL_MS = (uint32_t)1000 * 60; // 1 minute
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
  delay(1000);

  Wire.begin();
  eepromBegin();
  initializeBLE();
  initializeIMU();
  initializeRTC();
  initializeTCS();
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
  sample.light = analogRead(LIGHT_SENSOR_PIN);
  Serial.print("UV: ");Serial.print(sample.uv); Serial.print(", ");
  Serial.print("light: ");Serial.print(sample.light); Serial.print(", ");
  sample.acceleration = readIMU();
  sample.color = readTCS();
  eepromPushSample(&sample);
}
