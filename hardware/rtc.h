

void initializeRTC(RTCZero rtc, int hour, int minute) {
    rtc.begin();
    rtc.setHours(hour);
    rtc.setMinutes(minute);
}

byte readRTC(RTCZero rtc) {
    byte time[2]; 
    time[0] = rtc.getHours();
    time[1] = rtc.getMinutes();
    return time;
}