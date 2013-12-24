#include <Timer.h>
#include "message.h"

configuration serialC{
	
}
implementation{
	  components MainC;
	  components LedsC;
	  components serialP;
	  components new TimerMilliC() as Timer; 
	  components ActiveMessageC;
	  //components new AMSenderC(6);
	  components new AMReceiverC(AM_RADIO_MSG);  
	  components CC2420ActiveMessageC;
	  components CC2420ControlC;
	  components SerialActiveMessageC as Serial;
	  
	  serialP.Boot->MainC.Boot;
	  serialP.Leds->LedsC.Leds;
	  serialP.sendTimer->Timer.Timer;
	  serialP.AMSend->Serial.AMSend[AM_SERIAL_MSG];
	  serialP.Receive->AMReceiverC;
	  serialP.Packet->Serial.Packet;
	  serialP.SerialControl->Serial;
	  //serialP.PacketAcknowledgements->AMSenderC.Acks;
	  serialP.CC2420Config->CC2420ControlC.CC2420Config;
	  serialP.AMControl->ActiveMessageC;
	  serialP.CC2420Packet->CC2420ActiveMessageC;
	  serialP.PacketTimeStamp->ActiveMessageC.PacketTimeStampMilli;	  
}