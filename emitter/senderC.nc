#include <Timer.h>
#include "message.h"

configuration senderC{
	
}
implementation{
	  components MainC;
	  components LedsC;
	  components senderP;
	  components new TimerMilliC() as Timer; 
	  components ActiveMessageC;
	  components new AMSenderC(AM_RADIO_MSG);  
	  components CC2420ActiveMessageC;
	  components CC2420ControlC;
	  
	  senderP.Boot->MainC.Boot;
	  senderP.Leds->LedsC.Leds;
	  senderP.sendTimer->Timer.Timer;
	  senderP.AMSend->AMSenderC.AMSend;
	  senderP.Packet->AMSenderC.Packet;
	  senderP.PacketAcknowledgements->AMSenderC.Acks;
	  senderP.CC2420Config->CC2420ControlC.CC2420Config;
	  senderP.CC2420Packet->CC2420ActiveMessageC.CC2420Packet;
	  senderP.AMControl->ActiveMessageC;
}