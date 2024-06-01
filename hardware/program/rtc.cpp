#include <RTCZero.h>
#include "rtc.h"
#include "eeprom.h"

static RTCZero rtc;

void initializeRTC() {
    rtc.begin();
    rtc.setEpoch(eepromLoadRTCTime());
}

std::array<uint8_t, 4> readRTC() {
    uint32_t epoch = rtc.getEpoch();
    eepromSaveRTCTime(epoch);
    Serial.print(epoch);
    Serial.print(",");

    uint8_t first_bytes = epoch & 0x00ff;
    uint8_t second_bytes = epoch >> 8;
    uint8_t third_bytes = epoch >> 16;
    uint8_t fourth_bytes = epoch >> 24;
    std::array<uint8_t, 4> output = {first_bytes, second_bytes, third_bytes, fourth_bytes};
    return output;
}
