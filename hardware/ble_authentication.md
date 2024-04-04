# BLE Authentication

# Method 1 - Explicit Authentication

Both the central and peripheral must be authenticated
to access and transmit the sensor data. Other data such as sensor data
length are public information.

The peripheral stores a secret key which is set while the device
is 'in the factory' and is not changable. The key is a 10 digit code
containing upper/lower case letters and numbers. The key is printed on
a piece of paper shipped with the device. Internally, this key is an ASCII
character array padded with 22 zero bytes at the end to give a 256 bit key.

## Authentication Process

- The central pairs with the peripheral to establish encrypted communication.
- The central is authenticated:
  - The peripheral writes a random 256 bit number to characteristic `R1`.
  - The central reads characteristic `R1` and writes `SHA256(R1 xor key)` to characteristic `H1`.
  - The peripheral checks whether characteristic `H1` is correct and authenticates the central.
- The Peripheral is authenticated:
  - The central writes zero to characteristic `H2`.
  - The central writes a random 256 bit number to characteristic `R2`.
  - The peripheral reads characteristic `R2` and writes `SHA256(R2 xor key)` to characteristic `H2`.
  - The central polls characteristic `H2` until it is nonzero.
  - The central checks whether characteristic `H2` is correct and authenticates the peripheral.

The central must be authenticated before the peripheral so that the peripheral
can make the sensitive data available as soon as the central is authenticated.
This avoids the central needing to check when the data is ready to be read.

This method concentrates the complexity in the initial handshake and requires BLE pairing for encryption.

## Characteristics

| Name | Size | UUID | Function |
|------|------|------|----------|
| R1 | 32 Bytes | 9ab7d3df-a7b4-4858-8060-84a9adcf1420 | Random challenge from peripheral. |
| H1 | 32 Bytes | a90aa9a2-b186-4717-bc8d-f169eead75da | Hash response from central. |
| R2 | 32 Bytes | c03b7267-dcfa-4525-8521-1bc31c08c312 | Random challenge from central. |
| H2 | 32 Bytes | 750d5d43-96c4-4f5c-8ce1-fdb44a150336 | Hash response from peripheral. |

# Method 2 - Implicit Authentication via Encryption

Only the central must be authenticated to access the sensor data.
Other data such as sensor data length are public information. Peripherals cannot
fake data even though they do not need to be authenticated.

The peripheral stores a secret key which is set while the device
is 'in the factory' and is not changable. The key is a 10 digit code
containing upper/lower case letters and numbers. The key is printed on
a piece of paper shipped with the device. Internally, this key is an ASCII
character array padded with 22 zero bytes at the end to give a 256 bit key.

The sensor data stream is encrypted with AES256 so the central is implicitly
authenticated by knowing the decryption key. The end of the sensor data stream
is signalled with an encrypted empty sensor sample (all zeros) called the _sentinal_.
Since only a peripheral that knows the key can encrypt an empty sensor sample correctly,
the central can ensure the integrity of the peripheral's sensor data. This does not guard against
replay attacks but means that an attacker can only replay unmodified data.

## Encryption Process

The process to encrypt the sensor data stream being transmitted through characteristic `A` is:
- Pad the data to be stored characteristic `A` with zeros to a multiple of 16 bytes.
- Encrypt the padded data and store it in characteristic `A`.
- Repeat until all data is sent, including the sentinal.

The process to decrypt the sensor data stream from characteristic `A` is:
- Read characteristic `A` and decrypt the data.
- Unpad the data by removing bytes from the end until you have a multiple of sizeof(SensorSample) bytes.
- Check for the sentinal. There may be multiple sentinals due to the padding so use the earliest
  sentinal to find the end of the data.
- Repeat until the sentinal is found. If no sentinal is found after some MAX_SAMPLES_PER_TRANSFER,
  reject the peripheral as malicious.

This method does not require an initial handshake but adds complexity to the data transfer.
It also does not use the encryption from BLE since we have our own layer of encryption.
