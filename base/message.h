#ifndef MESSAGE_H
#define MESSAGE_H

typedef nx_struct Payload {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
  nx_uint16_t rssi;
  nx_uint32_t timestamp;
} payload_t;

enum{
	AM_SERIAL_MSG=0x89,
	AM_RADIO_MSG=6,
};

#endif