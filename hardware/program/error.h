#ifndef _ERROR_H
#define _ERROR_H

#include <Arduino.h>

enum Error {
  ERROR_EEPROM_BEGIN,
  ERROR_EEPROM_READ,
  ERROR_EEPROM_WRITE,
  ERROR_EEPROM_ALLOC,
  ERROR_TCS_BEGIN,
  ERROR_BLE_BEGIN,
  ERROR_IMU_BEGIN,
};

inline void showError(Error error) {
  const char* message = "ERROR_UNKNOWN";
  switch (error) {
    case ERROR_EEPROM_BEGIN: message = "ERROR_EEPROM_BEGIN"; break;
    case ERROR_EEPROM_READ: message = "ERROR_EEPROM_READ"; break;
    case ERROR_EEPROM_WRITE: message = "ERROR_EEPROM_WRITE"; break;
    case ERROR_EEPROM_ALLOC: message = "ERROR_EEPROM_ALLOC"; break;
    case ERROR_TCS_BEGIN: message = "ERROR_TCS_BEGIN"; break;
    case ERROR_BLE_BEGIN: message = "ERROR_BLE_BEGIN"; break;
    case ERROR_IMU_BEGIN: message = "ERROR_IMU_BEGIN"; break;
  }
  Serial.println(message);

  pinMode(LED_BUILTIN, OUTPUT);
  while (true) {
    for (int i = 0; i < error; i++) {
      digitalWrite(LED_BUILTIN, HIGH);
      delay(250);
      digitalWrite(LED_BUILTIN, LOW);
      delay(250);
    }
    delay(3000);
  }
}

#endif