/*
Sensor Sample Storage and Locking

  Sensor samples are stored in a circular buffer with a fixed maximum size.
  Once the maximum size is reached, new samples will begin overwriting old samples.

  During a BLE transfer of sample data, no new samples can be written to the EEPROM.
  This is to simplify the process of ensuring the consistency of the transferred data.
  Before any transfer of sample data, call eepromLockSampleBuffer() to lock
  the sample buffer and prevent any changes. After all transfers have finished,
  call eepromUnlockSampleBuffer() to unlock the sample buffer.

  Any calls to eepromPushSample() while the sample buffer is locked will be
  buffered in RAM and flushed when eepromUnlockSampleBuffer() is called.
  If this buffer is full, new samples are dropped.

Atomic Writes

  To ensure critical values always remain valid in the EEPROM, 32-bit integer
  writes can be made atomic. This is done with the help of three registers
  which are stored on the EEPROM: address, value, and pending.

  When an atomic write is requested, the address and value of the write operation
  is saved to their corresponding registers. Then the pending register is
  set to true.

  The value is then written to the desired address.

  If the write succeeds, then the pending register is set to false, and the
  transaction is complete.

  If the power is lost halfway through the write, then the necessary information
  to resume the write remains in the registers. On boot, the pending register
  is checked to see if any write operation was in progress before the power loss.
*/

#ifndef _EEPROM_H
#define _EEPROM_H

#include <stdint.h>
#include "sensor_sample.h"

typedef uint32_t EEPROMAddress;

/*
 * Initialise the EEPROM. If initialisation fails,
 * an error message is printed and the program freezes.
 * Call Wire.begin() before calling this.
 */
void eepromBegin();

/*
 * Direct read/write functions.
 *
 * Writes are not guaranteed to be fully written if the
 * system loses power so corruption is possible.
 */
void eepromWrite(EEPROMAddress address, const uint8_t* buffer, uint32_t len);
void eepromWriteUint32(EEPROMAddress address, uint32_t value);
void eepromRead(EEPROMAddress address, uint8_t* buffer, uint32_t len);
uint32_t eepromReadUint32(EEPROMAddress address);

/*
 * Write with full guarantee that the value will either be fully written now
 * or fully written on the next boot if there was a power failure.
 */
void eepromAtomicWriteUint32(EEPROMAddress address, uint32_t value);

/*
 * Write 0 to every byte in the EEPROM.
 */
void eepromClear();

/*
 * Allocate a buffer for storage in the EEPROM and return
 * an address to the buffer. If allocation fails, the program
 * freezes with an error message printed to the serial monitor.
 *
 * Only call this during initialisation. DO NOT use this to 
 * dynamically allocate storage.
 */
EEPROMAddress eepromAllocateUint32();
EEPROMAddress eepromAllocate(uint32_t len);

/*
 * Add a sample to the sample buffer.
 *
 * If the buffer is full, the oldest sample is overwritten.
 *
 * If the buffer is locked by eepromLockSampleBuffer(),
 * the push operation is buffered in RAM until
 * eepromUnlockSampleBuffer() is called. If this RAM
 * buffer is full, the new sample is dropped.
 */
void eepromPushSample(const SensorSample* sample);

/*
 * Read a sample at an index relative to the tail
 * of the sample buffer.
 */
void eepromReadSample(uint32_t index, SensorSample* sample);

/*
 * Get the sample buffer length in elements.
 */
uint32_t eepromGetSampleBufferLength();

/*
 * Lock the sample buffer to prevent changes to the sample buffer.
 */
void eepromLockSampleBuffer();

/*
 * Unlock the sample buffer to allow changes to the sample buffer.
 */
void eepromUnlockSampleBuffer();

#endif
