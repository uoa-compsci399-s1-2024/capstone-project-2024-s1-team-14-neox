#include <stdint.h>
#include <ArduinoBLE.h>
#include <SHA256.h>
#include <algorithm>
#include "eeprom.h"
#include "rtc.h"
#include "ble.h"
#include "sensor_sample.h"


const uint32_t maxDataPerCharacteristic = 512;
const uint32_t dataPerCharacteristic = maxDataPerCharacteristic / sizeof(SensorSample) * sizeof(SensorSample);
const uint32_t maxData = dataPerCharacteristic * 5;
uint32_t currentSampleBufferIndex = 0;
uint32_t sentData = 0;

BLEService sensorSamplesService("ba5c0000-243e-4f78-ac25-69688a1669b4");

/*
 * Data will be sent 5 BLE characteristics at a time. These characteristics will be updated dynamically (depending on how much data must be sent).
 */
BLECharacteristic samples_1("42b25f8f-0000-43de-92b8-47891c706106", BLERead, maxDataPerCharacteristic);
BLECharacteristic samples_2("5c5ef115-0001-431d-8c23-52ff6ad1e467", BLERead, maxDataPerCharacteristic);
BLECharacteristic samples_3("1fc0372f-0002-43f3-8cfc-1a5611b88062", BLERead, maxDataPerCharacteristic);
BLECharacteristic samples_4("ff3d9730-0003-4aac-84e2-0861c1d000a6", BLERead, maxDataPerCharacteristic);
BLECharacteristic samples_5("6eea8c3b-0004-4ec0-a842-6ed292e598dd", BLERead, maxDataPerCharacteristic);

/*
 *   BLE Characteristic for receiving acknowledgement from app that data has been processed and sample characteristics can be updated
 */
BLEStringCharacteristic update("f06c06bb-0005-4f4c-b6b4-a146eff5ab15", BLEWrite, 8);

/*
 * Characteristic to recieve last sent timestamp from app. If this characteristic has been written to, the device sends data after that timestamp. If not,
 * the device sends the full sample buffer 
 */
BLECharacteristic ts("f06c06bb-0006-4f4c-b6b4-a146eff5ab15", BLEWrite, 4);

/*
 * Characteristic showing how many samples are to be sent
 */
BLECharacteristic progress("f06c06bb-0007-4f4c-b6b4-a146eff5ab15", BLERead, 8);

/*
 * Byte arrays for buffers that will be used to update characteristic values. Eeprom will be read
 * and values will be placed in a numbered buffer. Once the numbered buffer is full, its value will be written to the corresponding numbered
 * characteristic. Buffers are only added to if there are enough timestamps. If there are not enough, they remain empty.
 */
byte buffer_1[maxDataPerCharacteristic];
byte buffer_2[maxDataPerCharacteristic];
byte buffer_3[maxDataPerCharacteristic];
byte buffer_4[maxDataPerCharacteristic];
byte buffer_5[maxDataPerCharacteristic];

/*
 * Authentication properties
 */
static const int unpaddedAuthKeyLen = 10;
static const int authKeyLen = 32;

static BLECharacteristic authChallengeFromPeripheral("9ab7d3df-a7b4-4858-8060-84a9adcf1420", BLERead, 32, true);
static BLECharacteristic authResponseFromCentral    ("a90aa9a2-b186-4717-bc8d-f169eead75da", BLEWrite | BLEEncryption, 32, true);
static BLECharacteristic authChallengeFromCentral   ("c03b7267-dcfa-4525-8521-1bc31c08c312", BLEWrite, 32, true);
static BLECharacteristic authResponseFromPeripheral ("750d5d43-96c4-4f5c-8ce1-fdb44a150336", BLERead | BLEWrite | BLEEncryption, 32, true);
static BLECharacteristic centralAuthenticated       ("776edbca-a020-4d86-a5e8-25eb87e82554", BLERead, 1, true);

static uint32_t authKey;
static bool authenticated;

static uint32_t sha256(uint32_t data); // Input and output as 32 byte little endian.
static uint32_t generateRandom();
static void onConnection(BLEDevice central);
static void onAuthResponseFromCentral(BLEDevice central, BLECharacteristic characteristic);
static void onAuthChallengeFromCentral(BLEDevice central, BLECharacteristic characteristic);

void initializeBLE() {
    if (!BLE.begin()) 
    {
        Serial.println("BLE failed to initiate");
        delay(500);
        while(1);
    }

    EEPROMAddress authKeyBuffer = eepromAllocate(authKeyLen);
    // Use the following to set the authentication key:
    //uint8_t buf[authKeyLen] = "secure pwd";
    //eepromWrite(authKeyBuffer, buf, sizeof(buf));
    eepromRead(authKeyBuffer, (uint8_t*)&authKey, sizeof(authKey));

    authResponseFromCentral.setEventHandler(BLEWrite, onAuthResponseFromCentral);
    authChallengeFromCentral.setEventHandler(BLEWrite, onAuthChallengeFromCentral);

    BLE.setLocalName("Neox Sens 1.0");
    ts.setValue(0);
    sensorSamplesService.addCharacteristic(samples_1);
    sensorSamplesService.addCharacteristic(samples_2);
    sensorSamplesService.addCharacteristic(samples_3);
    sensorSamplesService.addCharacteristic(samples_4);
    sensorSamplesService.addCharacteristic(samples_5);
    sensorSamplesService.addCharacteristic(update);
    sensorSamplesService.addCharacteristic(authChallengeFromPeripheral);
    sensorSamplesService.addCharacteristic(authResponseFromCentral);
    sensorSamplesService.addCharacteristic(authChallengeFromCentral);
    sensorSamplesService.addCharacteristic(authResponseFromPeripheral);
    sensorSamplesService.addCharacteristic(centralAuthenticated);
    sensorSamplesService.addCharacteristic(ts);
    sensorSamplesService.addCharacteristic(progress);
    
    BLE.addService(sensorSamplesService);
    BLE.advertise();
    
}

void checkConnection() {
    BLEDevice central = BLE.central();
    while (central.connected())
    {
        uint8_t authenticated;
        centralAuthenticated.readValue(authenticated);
        if (authenticated) {
            updateValues();
        }
    }
    currentSampleBufferIndex = 0;
    sentData = 0;
}

void findTSIndex(uint32_t timestamp, uint32_t& currentSampleBufferIndex) {
  uint32_t left = 0;
  uint32_t right = eepromGetSampleBufferLength() - 1;
  while (left <= right) {
    uint32_t mid = left + (right - left) / 2;

    SensorSample sample; 
    eepromReadSample(mid, &sample);
    uint32_t ts = sample.timestamp[3] << 24;
    ts += sample.timestamp[2] << 16;
    ts += sample.timestamp[1] << 8;
    ts += sample.timestamp[0];
    
    if (ts == timestamp)
    {
      currentSampleBufferIndex = mid;
      return;
    }
    if (ts < timestamp)
    {
      left = mid + 1;
    }
    else
    {
      right = mid - 1;
    }
  }
  return;
}

void addSample(byte arr[maxDataPerCharacteristic], uint32_t& index, SensorSample sample) {
    memcpy(&arr[index], &sample, sizeof(SensorSample));
    index += sizeof(SensorSample);
}

void emptyBuffers() {
    std::fill(buffer_1, buffer_1 + dataPerCharacteristic, 0);
    std::fill(buffer_2, buffer_2 + dataPerCharacteristic, 0);
    std::fill(buffer_3, buffer_3 + dataPerCharacteristic, 0);
    std::fill(buffer_4, buffer_4 + dataPerCharacteristic, 0);
    std::fill(buffer_5, buffer_5 + dataPerCharacteristic, 0);
}

void fillCharacteristics() {
    samples_1.writeValue(buffer_1, maxDataPerCharacteristic);
    samples_2.writeValue(buffer_2, maxDataPerCharacteristic);
    samples_3.writeValue(buffer_3, maxDataPerCharacteristic);
    samples_4.writeValue(buffer_4, maxDataPerCharacteristic);
    samples_5.writeValue(buffer_5, maxDataPerCharacteristic);
}

void fillBuffers(uint32_t& currentSampleBufferIndex, uint32_t& sentData) {
    uint32_t bufferIndex = currentSampleBufferIndex;
    uint32_t sent = sentData;
    uint32_t bytesToSend = eepromGetSampleBufferLength() * sizeof(SensorSample) - sent;
    uint32_t bytesInBuffers = 0;
    uint32_t index = 0;

    
    if (bytesToSend == 0)
    {
        return;
    }
    if (bytesToSend > maxData)
    {
        bytesToSend = maxData;
    }
    uint32_t samplesToSend = bytesToSend / sizeof(SensorSample);
    eepromLockSampleBuffer();

    for (uint32_t i = 0; i < samplesToSend; i++) {
        SensorSample sample;
        eepromReadSample(bufferIndex, &sample);
        
        
        if (index == dataPerCharacteristic) 
        {
            index = 0;
        }

        if (bytesInBuffers < dataPerCharacteristic)
        {
            addSample(buffer_1, index, sample);
        }

        else if (bytesInBuffers >= dataPerCharacteristic && bytesInBuffers < dataPerCharacteristic * 2 )
        {
            addSample(buffer_2, index, sample);
        }

        else if (bytesInBuffers >= dataPerCharacteristic * 2 && bytesInBuffers < dataPerCharacteristic * 3 )
        {
            addSample(buffer_3, index, sample);
        }

        else if (bytesInBuffers >= dataPerCharacteristic * 3 && bytesInBuffers < dataPerCharacteristic * 4 )
        {
            addSample(buffer_4, index, sample);
        }

        else
        {
            addSample(buffer_5, index, sample);
        }

        sent += sizeof(SensorSample);
        bytesInBuffers += sizeof(SensorSample);
        bufferIndex++;
    }
    
    eepromUnlockSampleBuffer();
    sentData = sent;
    currentSampleBufferIndex = bufferIndex;
    
}

void updateValues() {
    uint32_t samplesToSend = eepromGetSampleBufferLength();
    if (ts.written()) 
    {
      uint32_t timestamp;
      ts.readValue(timestamp);
      findTSIndex(timestamp, currentSampleBufferIndex);
    }
    if (update.written())
    {
        samplesToSend -= currentSampleBufferIndex;
        progress.writeValue(samplesToSend);
        fillBuffers(currentSampleBufferIndex, sentData);
        fillCharacteristics();
        emptyBuffers();
    }
}

static uint32_t sha256(uint32_t data) {
  SHA256 hasher;
  hasher.update(&data, sizeof(data));

  uint32_t hash;
  hasher.finalize(&hash, sizeof(hash));
  return hash;
}

static uint32_t generateRandom() {
  uint32_t value = 0;
  for (int i = 0; i < 7; i++) {
    value |= (analogRead(A0 + i) & 0xF) << (4 * i);
  }
  return sha256(value);
}

static void onConnection(BLEDevice central) {
  authenticated = false;

  uint8_t falsy = 0;
  centralAuthenticated.setValue(&falsy, sizeof(falsy));

  uint32_t challengeFromPeripheral = generateRandom();
  authChallengeFromPeripheral.setValue((const uint8_t*)&challengeFromPeripheral, sizeof(challengeFromPeripheral));
}

static void onAuthResponseFromCentral(BLEDevice central, BLECharacteristic characteristic) {
  uint32_t response;
  authResponseFromCentral.readValue(response);

  uint32_t challenge;
  authChallengeFromPeripheral.readValue(challenge);

  uint32_t expected = sha256(authKey ^ challenge);
  if (response == expected) {
    uint8_t truthy = 1;
    centralAuthenticated.setValue(&truthy, sizeof(truthy));
    Serial.println("auth success");
  }
  Serial.println("auth failed");
  Serial.println(response);
  Serial.println(challenge);
  Serial.println(expected);
}

static void onAuthChallengeFromCentral(BLEDevice central, BLECharacteristic characteristic) {
  uint32_t challenge;
  authChallengeFromCentral.readValue(challenge);

  uint32_t response = sha256(authKey ^ challenge);
  authResponseFromPeripheral.setValue((const uint8_t*)&response, sizeof(response));
}


