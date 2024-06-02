#include <stdint.h>
#include <ArduinoBLE.h>
#include <SHA256.h>
#include <algorithm>
#include "eeprom.h"
#include "rtc.h"
#include "ble.h"
#include "sensor_sample.h"
#include "error.h"

const uint32_t MAX_UNAUTH_TIME = 10 * 1000;
const uint32_t maxDataPerCharacteristic = 512;
const uint32_t dataPerCharacteristic = maxDataPerCharacteristic / sizeof(SensorSample) * sizeof(SensorSample);
const uint32_t maxData = dataPerCharacteristic * 5;
uint32_t currentSampleBufferIndex = 0;

BLEService sensorSamplesService("ba5c0000-243e-4f78-ac25-69688a1669b4");

#define BLEEncryption 0
/*
 * Data will be sent 5 BLE characteristics at a time. These characteristics will be updated dynamically (depending on how much data must be sent).
 */
BLECharacteristic samples_1("42b25f8f-0000-43de-92b8-47891c706106", BLERead | BLEEncryption, maxDataPerCharacteristic);
BLECharacteristic samples_2("5c5ef115-0001-431d-8c23-52ff6ad1e467", BLERead | BLEEncryption, maxDataPerCharacteristic);
BLECharacteristic samples_3("1fc0372f-0002-43f3-8cfc-1a5611b88062", BLERead | BLEEncryption, maxDataPerCharacteristic);
BLECharacteristic samples_4("ff3d9730-0003-4aac-84e2-0861c1d000a6", BLERead | BLEEncryption, maxDataPerCharacteristic);
BLECharacteristic samples_5("6eea8c3b-0004-4ec0-a842-6ed292e598dd", BLERead | BLEEncryption, maxDataPerCharacteristic);

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
static uint8_t authKey[32];
static bool authenticated = false;
static uint32_t connectTime = 0;

static BLECharacteristic authChallengeFromPeripheral("9ab7d3df-a7b4-4858-8060-84a9adcf1420", BLERead, 32, true);
static BLECharacteristic authResponseFromCentral    ("a90aa9a2-b186-4717-bc8d-f169eead75da", BLEWrite | BLEEncryption, 32, true);
static BLECharacteristic authChallengeFromCentral   ("c03b7267-dcfa-4525-8521-1bc31c08c312", BLEWrite | BLEEncryption, 32, true);
static BLECharacteristic authResponseFromPeripheral ("750d5d43-96c4-4f5c-8ce1-fdb44a150336", BLERead | BLEWrite | BLEEncryption, 32, true);
static BLECharacteristic centralAuthenticated       ("776edbca-a020-4d86-a5e8-25eb87e82554", BLERead, 1, true);

static void getBLEAddress(uint8_t* address); // Returns a 6 byte array
static void sha256(const uint8_t* value, uint8_t* hash); // Takes and returns a 32 byte array
static void generateRandom(uint8_t* value); // Returns 32 byte array
static void solveAuthChallenge(const uint8_t* challenge, uint8_t* solution);
static void onConnection(BLEDevice central);
static void onAuthResponseFromCentral(BLEDevice central, BLECharacteristic characteristic);
static void onAuthChallengeFromCentral(BLEDevice central, BLECharacteristic characteristic);

void initializeBLE() {
    if (!BLE.begin()) 
    {
        showError(ERROR_BLE_BEGIN);
    }

    eepromGetBLEAuthKey(authKey);

    authResponseFromCentral.setEventHandler(BLEWritten, onAuthResponseFromCentral);
    authChallengeFromCentral.setEventHandler(BLEWritten, onAuthChallengeFromCentral);
    BLE.setEventHandler(BLEConnected, onConnection);

    uint8_t manufacturerData[8] = { 0xFF, 0xFF }; // 0xFFFF is the company id used for testing
    getBLEAddress(manufacturerData + 2);
    BLE.setManufacturerData(manufacturerData, sizeof(manufacturerData));
    BLE.setAdvertisedService(sensorSamplesService);
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

void getBLEAddress(uint8_t* address) {
  String s = BLE.address();
  for (int i = 0; i < 18;) {
    if (s[i] <= '9') {
      *address = (s[i] - '0') * 16;
    } else {
      *address = (s[i] - 'a' + 10) * 16;
    }
    i++;
    
    if (s[i] <= '9') {
      *address |= (s[i] - '0');
    } else {
      *address |= (s[i] - 'a' + 10);
    }
    i += 2;
    address++;
  }
}
void checkConnection() {
    BLEDevice central = BLE.central();

    while (central.connected())
    {
        if (connectTime == 0) {
            connectTime = millis();
        }
        if (!authenticated && millis() - connectTime >= MAX_UNAUTH_TIME) {
            central.disconnect();
            break;
        }
        if (authenticated) {

            updateValues(currentSampleBufferIndex);
        }
    }
    currentSampleBufferIndex = 0;
    connectTime = 0;
}

void findTSIndex(uint32_t timestamp, uint32_t& currentSampleBufferIndex) {
  uint32_t search_ts = timestamp;
  uint32_t left = 0;
  uint32_t right = eepromGetSampleBufferLength() - 1;

  while (left < right) {

    uint32_t mid = left + (right - left) / 2;
    SensorSample sample; 
    eepromReadSample(mid, &sample);

    // Serial.print(left);
    // Serial.print(", ");
    // Serial.print(mid);
    // Serial.print(", ");
    // Serial.println(right);
    uint32_t ts = sample.timestamp[3] << 24;
    ts += sample.timestamp[2] << 16;
    ts += sample.timestamp[1] << 8;
    ts += sample.timestamp[0];

    if (ts == search_ts)
    {
      currentSampleBufferIndex = mid;

      return;
    }
    if (ts < search_ts)
    {
      left = mid + 1;
    }
    else
    {
      right = mid - 1;
    }
  }
  currentSampleBufferIndex = 0;
  // Serial.print("returned without finding");
  return; 
}

void updateValues(uint32_t& currentSampleBufferIndex) {
    uint32_t samplesToSend = eepromGetSampleBufferLength();
    if (ts.written())
    {

      uint32_t timestamp;
      ts.readValue(timestamp);


      if (timestamp == 0) {
        currentSampleBufferIndex = 0;

      } else {
        findTSIndex(timestamp, currentSampleBufferIndex);


      }
    }
    if (update.written()){
        samplesToSend -= currentSampleBufferIndex;

        progress.writeValue(samplesToSend);
        fillBuffers(currentSampleBufferIndex);
        fillCharacteristics();
        emptyBuffers();
      
    }
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

void fillBuffers(uint32_t& currentSampleBufferIndex) {
    uint32_t bufferIndex = currentSampleBufferIndex;
    uint32_t bytesToSend = (eepromGetSampleBufferLength() - currentSampleBufferIndex) * sizeof(SensorSample);
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

        bytesInBuffers += sizeof(SensorSample);
        bufferIndex++;
    }
    
    eepromUnlockSampleBuffer();
    currentSampleBufferIndex = bufferIndex;
    
}

static void sha256(const uint8_t* data, uint8_t* hash) {
  SHA256 hasher;
  hasher.update(data, 32);
  hasher.finalize(hash, 32);
}

static void generateRandom(uint8_t* value) {
  static const uint8_t pins[] = {
    A2, A3, A6, A7,
  };

  for (int i = 0; i < 32; i++) {
    value[i] |= analogRead(pins[i % sizeof(pins)]);
    if (i % sizeof(pins) == 0) {
      delay(50);
    }
  }
  sha256(value, value);
}

static void solveAuthChallenge(const uint8_t* challenge, uint8_t* solution) {
  uint8_t buffer[32];
  for (int i = 0; i < sizeof(buffer); i++) {
    buffer[i] = challenge[i] ^ authKey[i];
  }
  sha256(buffer, solution);
}

static void onConnection(BLEDevice central) {
  authenticated = false;

  uint8_t falsy = 0;
  centralAuthenticated.writeValue(&falsy, sizeof(falsy));

  uint8_t challengeFromPeripheral[32];
  generateRandom(challengeFromPeripheral);
  authChallengeFromPeripheral.writeValue(challengeFromPeripheral, sizeof(challengeFromPeripheral));
}

static void onAuthResponseFromCentral(BLEDevice central, BLECharacteristic characteristic) {
  uint8_t response[32];
  authResponseFromCentral.readValue(response, sizeof(response));

  uint8_t challenge[32];
  authChallengeFromPeripheral.readValue(challenge, sizeof(challenge));

  uint8_t expected[32];
  solveAuthChallenge(challenge, expected);
  if (memcmp(response, expected, sizeof(expected)) == 0) {
    uint8_t truthy = 1;
    centralAuthenticated.writeValue(&truthy, sizeof(truthy));
    authenticated = true;
  }

  // Serial.print("Authenticated status ");
  // Serial.println(authenticated);

  // auto print = [](uint8_t* arr) {
  //   for (int i = 0; i < 32; i++) {
  //     Serial.print(arr[i]);
  //     Serial.print(" ");
  //   }
  //   Serial.print("\n");
  // };

  print(authKey);
  print(challenge);
  print(response);
  print(expected);
}

static void onAuthChallengeFromCentral(BLEDevice central, BLECharacteristic characteristic) {
  uint8_t challenge[32];
  authChallengeFromCentral.readValue(challenge, sizeof(challenge));

  uint8_t response[32];
  solveAuthChallenge(challenge, response);
  authResponseFromPeripheral.writeValue(response, sizeof(response));
}


