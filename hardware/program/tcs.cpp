#include <Adafruit_TCS34725.h>
#include "tcs.h"
#include "error.h"

Adafruit_TCS34725 tcs(101);

void initializeTCS() {
  if (!tcs.begin())
  {
    showError(ERROR_TCS_BEGIN);
  }
}

TCSData readTCS() {
  TCSData data = { 0 };
  tcs.getRawData(&data.red, &data.green, &data.blue, &data.clear);
  return data;
}
