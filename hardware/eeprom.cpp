#include <Wire.h>
#include <SparkFun_External_EEPROM.h>
#include "eeprom.h"


static const uint32_t EEPROM_SIZE_KBIT = 256;
static const uint32_t EEPROM_SIZE_BYTES = EEPROM_SIZE_KBIT * 1024 / 8;

static const uint32_t TEMP_SAMPLE_BUFFER_MAX_SIZE_ELEMS = 16;
static const uint32_t SAMPLE_BUFFER_MAX_SIZE_BYTES = 0x4000; // 16 kilobytes
static const uint32_t SAMPLE_BUFFER_MAX_SIZE_ELEMS = SAMPLE_BUFFER_MAX_SIZE_BYTES / sizeof(SensorSample);


struct SampleBuffer
{
  EEPROMAddress bufferAddress;
  EEPROMAddress tail;
  EEPROMAddress len;
  bool locked;
};

struct TempSampleBuffer
{
  uint32_t len;
  SensorSample samples[TEMP_SAMPLE_BUFFER_MAX_SIZE_ELEMS];
};

struct AtomicTransaction
{
  // These 32-bit integer fields reside in the EEPROM itself
  EEPROMAddress address;
  EEPROMAddress value;
  EEPROMAddress pending;
};


// If an atomic write was interrupted, resume the write.
static void resumeAtomicTransaction();
// Push a sample onto the temporary sample buffer stored in RAM.
static void pushTempSample(const SensorSample* sample);
// Push all samples in the temporary sample buffer into the EEPROM.
static void flushTempSamples();


static uint32_t allocatedLen;
static ExternalEEPROM eeprom;
static SampleBuffer sampleBuffer;
static TempSampleBuffer tempSampleBuffer;
static AtomicTransaction atomicTransaction;


bool eepromBegin()
{
  eeprom.setMemoryType(EEPROM_SIZE_KBIT);
  if (!eeprom.begin(0b1010000, Wire, 255))
  {
    return false;
  }

  allocatedLen = 0;

  sampleBuffer.bufferAddress = eepromAllocate(SAMPLE_BUFFER_MAX_SIZE_BYTES);
  sampleBuffer.tail = eepromAllocateUint32();
  sampleBuffer.len = eepromAllocateUint32();
  sampleBuffer.locked = false;
  tempSampleBuffer.len = 0;

  atomicTransaction.address = eepromAllocateUint32();
  atomicTransaction.value = eepromAllocateUint32();
  atomicTransaction.pending = eepromAllocateUint32();

  resumeAtomicTransaction();

  return true;
}

void eepromWrite(EEPROMAddress address, const uint8_t* buffer, uint32_t len)
{
  while (len > 0)
  {
    uint16_t blockLen = len > 0xFFFF ? 0xFFFF : len;
    eeprom.write(address, buffer, blockLen);
    buffer += blockLen;
    len -= blockLen;
  }
}

void eepromWriteUint32(EEPROMAddress address, uint32_t value)
{
  eepromWrite(address, (const uint8_t*)&value, sizeof(value));
}

void eepromRead(EEPROMAddress address, uint8_t* buffer, uint32_t len)
{
  while (len > 0)
  {
    uint16_t blockLen = len > 0xFFFF ? 0xFFFF : len;
    eeprom.read(address, buffer, blockLen);
    buffer += blockLen;
    len -= blockLen;
  }
}

uint32_t eepromReadUint32(EEPROMAddress address)
{
  uint32_t value;
  eepromRead(address, (uint8_t*)&value, sizeof(value));
  return value;
}

void eepromAtomicWriteUint32(EEPROMAddress address, uint32_t value)
{
  eepromWriteUint32(atomicTransaction.address, address);
  eepromWriteUint32(atomicTransaction.value, value);
  eepromWriteUint32(atomicTransaction.pending, true);
  eepromWriteUint32(address, value);
  eepromWriteUint32(atomicTransaction.pending, false);
}

void eepromClear()
{
  eeprom.erase();
}

EEPROMAddress eepromAllocateUint32() {
  return eepromAllocate(sizeof(uint32_t));
}

EEPROMAddress eepromAllocate(uint32_t len)
{
  if (allocatedLen + len > EEPROM_SIZE_BYTES)
  {
    Serial.print("EEPROM allocation failed: ");
    Serial.print(EEPROM_SIZE_BYTES);
    Serial.print(" total, ");
    Serial.print(allocatedLen);
    Serial.print(" used, ");
    Serial.print(EEPROM_SIZE_BYTES - allocatedLen);
    Serial.print(" free, ");
    Serial.print(len);
    Serial.println(" requested.");
    while (true)
    {
      delay(1000);
    }
  }

  uint32_t address = allocatedLen;
  allocatedLen += len;
  return address;
}

void eepromPushSample(const SensorSample* sample)
{
  if (sampleBuffer.locked)
  {
    pushTempSample(sample);
    return;
  }

  uint32_t tail = eepromReadUint32(sampleBuffer.tail);
  uint32_t len = eepromGetSampleBufferLength();
  uint32_t head = (tail + len) % SAMPLE_BUFFER_MAX_SIZE_ELEMS;
  uint32_t address = sampleBuffer.bufferAddress + head * sizeof(SensorSample);
  eepromWrite(address, (const uint8_t*)sample, sizeof(SensorSample));
  
  // Always keep sampleBuffer.len one less than the full buffer size.
  // This ensures that when you write a new sample, you're
  // always writing to an unused index. This is important
  // for keeping the data consistent even if the power is lost.
  if (len < SAMPLE_BUFFER_MAX_SIZE_ELEMS - 1)
  {
    eepromAtomicWriteUint32(sampleBuffer.len, len + 1);
  }
  else
  {
    eepromAtomicWriteUint32(sampleBuffer.tail, tail + 1);
  }
}

void eepromReadSample(uint32_t index, SensorSample* sample)
{
  uint32_t tail = eepromReadUint32(sampleBuffer.tail);
  uint32_t rawIndex = (tail + index) % SAMPLE_BUFFER_MAX_SIZE_ELEMS;
  uint32_t address = sampleBuffer.bufferAddress + rawIndex * sizeof(SensorSample);
  eepromRead(address, (uint8_t*)sample, sizeof(SensorSample));
}

uint32_t eepromGetSampleBufferLength()
{
  return eepromReadUint32(sampleBuffer.len);
}

void eepromLockSampleBuffer()
{
  sampleBuffer.locked = true;
}

void eepromUnlockSampleBuffer()
{
  sampleBuffer.locked = false;
  flushTempSamples();
}

static void pushTempSample(const SensorSample* sample)
{
  if (tempSampleBuffer.len < TEMP_SAMPLE_BUFFER_MAX_SIZE_ELEMS) {
    tempSampleBuffer.samples[tempSampleBuffer.len] = *sample;
    tempSampleBuffer.len++;
  }
}

static void flushTempSamples()
{
  while (tempSampleBuffer.len > 0)
  {
    tempSampleBuffer.len--;
    eepromPushSample(&tempSampleBuffer.samples[tempSampleBuffer.len]);
  }
}

static void resumeAtomicTransaction()
{
  if (eepromReadUint32(atomicTransaction.pending)) {
    uint32_t address = eepromReadUint32(atomicTransaction.address);
    uint32_t value = eepromReadUint32(atomicTransaction.value);
    eepromWriteUint32(address, value);
    eepromWriteUint32(atomicTransaction.pending, false);
  }
}
