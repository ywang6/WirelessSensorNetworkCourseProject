#include <Timer.h>
#include "message.h"

configuration sensorC{
	
}
implementation{
	  components MainC;
	  components LedsC;
	  components sensorP;
	  components new TimerMilliC() as Timer; 
	  components ActiveMessageC;
	  components new AMSenderC(AM_RADIO_MSG);
	  components new AMReceiverC(AM_RADIO_MSG);  
	  components CC2420ActiveMessageC;
	  components CC2420ControlC;
	  
	  sensorP.Boot->MainC.Boot;
	  sensorP.Leds->LedsC.Leds;
	  sensorP.sendTimer->Timer.Timer;
	  sensorP.AMSend->AMSenderC.AMSend;
	  sensorP.Receive->AMReceiverC;
	  sensorP.Packet->AMSenderC.Packet;
	  sensorP.PacketAcknowledgements->AMSenderC.Acks;
	  sensorP.CC2420Config->CC2420ControlC.CC2420Config;
	  sensorP.AMControl->ActiveMessageC;
	  sensorP.CC2420Packet->CC2420ActiveMessageC;
	  sensorP.PacketTimeStamp->ActiveMessageC.PacketTimeStampMilli;
}