#include <stdint.h>
#include <ArduinoBLE.h>
#include <algorithm>
#include "eeprom.h"
#include "rtc.h"
#include "ble.h"
#include "sensor_sample.h"


const uint32_t maxDataPerCharacteristic = 512;
const uint32_t dataPerCharacteristic = maxDataPerCharacteristic / sizeof(SensorSample) * sizeof(SensorSample);
const uint32_t maxData = dataPerCharacteristic * 5;

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
 * Byte arrays for initial value set to each characteristic and buffers that will be used to update characteristic values. Eeprom will be read
 * and values will be placed in a numbered buffer. Once the numbered buffer is full, its value will be written to the corresponding numbered
 * characteristic. Buffers are only added to if there are enough timestamps. If there are not enough, they remain empty.
 */
byte buffer_1[maxDataPerCharacteristic];
byte buffer_2[maxDataPerCharacteristic];
byte buffer_3[maxDataPerCharacteristic];
byte buffer_4[maxDataPerCharacteristic];
byte buffer_5[maxDataPerCharacteristic];

void initializeBLE() {
    if (!BLE.begin()) 
    {
        Serial.println("BLE failed to initiate");
        delay(500);
        while(1);
    }

    BLE.setLocalName("Neox Sens 1.0");

    sensorSamplesService.addCharacteristic(samples_1);
    sensorSamplesService.addCharacteristic(samples_2);
    sensorSamplesService.addCharacteristic(samples_3);
    sensorSamplesService.addCharacteristic(samples_4);
    sensorSamplesService.addCharacteristic(samples_5);
    sensorSamplesService.addCharacteristic(update);

    BLE.addService(sensorSamplesService);
    BLE.advertise();
    
}

void checkConnection() {
    BLEDevice central = BLE.central();
    while (central.connected())
    {
        updateValues();
        
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

void fillBuffers(uint32_t& currentSampleBufferIndex, uint32_t& sentData) {
    uint32_t bufferIndex = currentSampleBufferIndex;
    uint32_t sent = sentData;
    uint32_t bytesToSend = eepromGetSampleBufferLength() * sizeof(SensorSample) - sent;
    uint32_t bytesInBuffers = 0;
    uint32_t index = 0;

    
    if (bytesToSend == 0)
    {
        sentData = 0;
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
    }
    
    eepromUnlockSampleBuffer();
    sentData = sent;
    currentSampleBufferIndex = bufferIndex;
    
}

void updateValues() {
    static uint32_t currentSampleBufferIndex = 0;
    static uint32_t sentData = 0;
    if (update.written())
    {
    fillBuffers(currentSampleBufferIndex, sentData);
    fillCharacteristics();
    emptyBuffers();
    }
}



