# Hardware

## Terminology

- Device: The device with the Arduino (records samples).
- Phone: The device parents use to retrieve samples from the children.

## Timestamps

Most microcontrollers won't know the actual time and date, so if we
want to associate each sample with a timestamp, we have two options:

1. buy a real-time clock module; or
2. start with a known timestamp ("epoch") and assign a "timestamp" to
   each sample by adding the time between the epoch and the sample,
   and then repeat the process when device reconnects with phone by
   updating the epoch.

## Pairing device with phone

### Multiple devices

We can't assume parents will have only one young child whose
outdoor-time they'd like to track.

### Authentication

Devices can *assume* they can trust the phone pairing with them, BUT
NOT the other way around.  A big reason for this is to reduce the
complexity of the prototype by eliminating the number of components
used for interaction with the user.

Phones should check whether the device connecting is who it says it
is so that:

1. the data is associated with the correct child; and
2. children can't spoof their outdoor time (though I don't think any
   children in the target audience will think of doing this, let alone
   trying it).
