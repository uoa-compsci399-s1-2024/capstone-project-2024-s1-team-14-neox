/* Code to initialise and read the onboard real-time clock. Initialising takes a starting hour and minute to set the RTC time. ReadRTC returns a byte array
   with byte[0] representing hour and byte[1] representing minute of timestamp */

void initializeRTC(RTCZero rtc, int hour, int minute) {
    rtc.begin();
    rtc.setHours(hour);
    rtc.setMinutes(minute);
}

byte* readRTC(RTCZero rtc) {
    byte time[2]; 
    time[0] = rtc.getHours();
    time[1] = rtc.getMinutes();
    return time;
}
