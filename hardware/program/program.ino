#include <Wire.h>
#include "sensor_sample.h"
#include "eeprom.h"
#include "imu.h"
#include "rtc.h"
#include "ble.h"
#include "tcs.h"

#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
Adafruit_SSD1306 display(128, 64, &Wire, -1);

static const int SERIAL_BAUD_RATE = 9600;
static const uint32_t POLL_INTERVAL_MS = (uint32_t)60 * 1000; // 1 minute
static const uint8_t UV_SENSOR_PIN = A6;

// Read all sensors and save them to the EEPROM
static void readSample();

extern "C" void HardFault_Handler() {
  Serial.println("crashed");
}

void setup()
{
  pinMode(A0, OUTPUT);
  pinMode(A1, OUTPUT);
  digitalWrite(A0, LOW);
  digitalWrite(A1, HIGH);
  pinMode(2, INPUT_PULLUP);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  
  Serial.begin(SERIAL_BAUD_RATE);
  delay(1000);
  
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  display.setTextColor(SSD1306_WHITE);

  Wire.begin();
  eepromBegin();
  // uint8_t key[32] = "verysecure";
  // uint8_t key[32] = "0123456789";
  // Serial.print("factory reset pressed");
  // eepromFactoryReset(key);
  initializeBLE();
  initializeIMU();
  initializeRTC();
  initializeTCS();
  
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  display.setTextColor(SSD1306_WHITE);
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

  if (digitalRead(2) == LOW) {
    digitalWrite(LED_BUILTIN, HIGH);
    uint8_t key[32] = "0123456789";
    eepromFactoryReset(key);
    setup();
  }

  auto uv = analogRead(UV_SENSOR_PIN);
  auto acceleration = readIMU();
  auto tcsData = readTCS();
  display.clearDisplay();
  display.setCursor(0, 0);
  display.print("  UV: "); display.println(uv);
  display.print("   R: "); display.println(tcsData.red);
  display.print("   G: "); display.println(tcsData.green);
  display.print("   B: "); display.println(tcsData.blue);
  display.print("   C: "); display.println(tcsData.clear);
  display.print("ACCX: "); display.println(acceleration.x);
  display.print("ACCY: "); display.println(acceleration.y);
  display.print("ACCZ: "); display.println(acceleration.z);
  display.display();
}

static void readSample()
{
  SensorSample sample = { 0 };
  sample.timestamp = readRTC();
  sample.uv = analogRead(UV_SENSOR_PIN);
  // Serial.print(sample.uv);
  // Serial.print(",");
  sample.acceleration = readIMU();
  sample.tcsData = readTCS();
  // Serial.println();
  eepromPushSample(&sample);
}
