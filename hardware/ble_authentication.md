# BLE Authentication

Both the central and peripheral must be authenticated
to access and transmit the sensor data. Other data such as sensor data
length are public information.

The peripheral stores a secret key which is set while the device
is 'in the factory' and is not changable. The key is a 10 digit code
containing upper/lower case letters and numbers. The key is printed on
a piece of paper shipped with the device. Internally, this key is an ASCII
character array padded with 22 zero bytes at the end to give a 256 bit key.

## Authentication Process

- Before any connection is established, the peripheral writes a random 256 bit number to characteristic `R1`.
  This number must be regenerated after every connection so that every new connection sees a different number.
- The central pairs with the peripheral to establish encrypted communication.
- The central is authenticated:
  - The central reads characteristic `R1` and writes `SHA256(R1 xor key)` to characteristic `H1`.
  - The peripheral checks whether characteristic `H1` is correct and writes a boolean (true=1, false=0)
    into characteristic `A` to indicate whether authentication succeeded.
- The peripheral is authenticated:
  - The central writes zero to characteristic `H2`.
  - The central writes a random 256 bit number to characteristic `R2`.
  - The peripheral reads characteristic `R2` and writes `SHA256(R2 xor key)` to characteristic `H2`.
  - The central polls characteristic `H2` until it is nonzero.
  - At this point, the central can read characteristic `A` to see if the central itself is authenticated.
  - The central checks whether characteristic `H2` is correct and authenticates the peripheral.

The central must be authenticated before the peripheral so that the peripheral
can make the sensitive data available as soon as the central is authenticated.
This avoids the central needing to check when the data is ready to be read.

## Characteristics

| Name | Size | Properties | UUID | Function |
|------|------|------------|------|----------|
| R1 | 32 Bytes | Read        | 9ab7d3df-a7b4-4858-8060-84a9adcf1420 | Random challenge from peripheral. |
| H1 | 32 Bytes | Write       | a90aa9a2-b186-4717-bc8d-f169eead75da | Hash response from central. |
| R2 | 32 Bytes | Write       | c03b7267-dcfa-4525-8521-1bc31c08c312 | Random challenge from central. |
| H2 | 32 Bytes | Read, Write | 750d5d43-96c4-4f5c-8ce1-fdb44a150336 | Hash response from peripheral. |
| A  | 1 Byte   | Read        | 776edbca-a020-4d86-a5e8-25eb87e82554 | Central authenticated flag. |
