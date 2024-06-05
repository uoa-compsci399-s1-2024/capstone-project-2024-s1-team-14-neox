#ifndef _BLE_H_
#define _BLE_H_

/* 
 * Initialise BLE and print an error if BLE fails to initialise. Adds sample characteristics and update characteristic to service. Adds the service to the BLE
 * and begins advertising.
 */
void initializeBLE();

/*
 * Called by the microcontrollers loop function. Checks if a BLE device is connected or not before calling updateValues().
 */
void checkConnection();

/*
 * Called to find the index of the last timestamp sent to the app
 */
void findTSIndex(uint32_t timestamp, uint32_t& currentSampleBufferIndex);

/*
 * Adds a sample to one of the five buffers which will be written to a characteristic.
 */
void addSample(byte arr[512], uint32_t& index, SensorSample sample);

/*
 * Empties all 5  buffers.
 */
void emptyBuffers();

/*
 * Writes the value of the 5 buffers to a characteristic each.
 */
void fillCharacteristics();

/*
 * Fills the amount of buffers needed to transmit all data on the eeprom.
 */
void fillBuffers(uint32_t& currentSampleBufferIndex);

/*
 * Keeps track of the current index in the sample buffer and the amount of data sent so far. If the update characteristic is written to, calls fillBuffers
 * and fillCharacteristics.
 */
void updateValues(uint32_t& currentSampleBufferIndex);

/*
 * Reload the BLE authentication key from EEPROM. This is only needed if the key has changed since initialisation.
 */
void loadBLEAuthKey();

#endif
