#include <Timer.h>
#include "message.h"

module senderP{
	uses interface Boot;
	uses interface Timer<TMilli> as sendTimer; 
	uses interface Leds;
	uses interface Packet;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface CC2420Config;
	uses interface CC2420Packet;
	uses interface PacketAcknowledgements;
	//uses interface PacketTimeStamp<TMilli,uint32_t>;
		
}
implementation{
	message_t msg;	
	uint16_t try;
	uint16_t counter=0;
	task void sendMessage(){
		payload_t *payloadMsg;
		payloadMsg=(payload_t *)call Packet.getPayload(&msg, sizeof(payload_t));
		payloadMsg->nodeid=TOS_NODE_ID;
		payloadMsg->counter=counter;
		if(counter==1023)
			counter=0;
		else 				
			counter++;
		//call PacketAcknowledgements.requestAck(&msg);
		call CC2420Packet.setPower(&msg, 31);
		if(call AMSend.send(AM_BROADCAST_ADDR,&msg,sizeof(payload_t))!=SUCCESS){
			post sendMessage();				
		}
	}
	
	event void Boot.booted(){
		call AMControl.start();
		call sendTimer.startPeriodic(330);
		
	}
	
	event void AMControl.startDone(error_t error){
		if(error==SUCCESS){
			call CC2420Config.sync();
			call CC2420Config.setChannel(26);
		}
		else{
			call AMControl.start();	
		}		
	}
	
	event void AMControl.stopDone(error_t error){
		
	}
	
	
	event void AMSend.sendDone(message_t *temp, error_t error){
		atomic{
			if(error!=SUCCESS){
				if(try==3){
					try=0;	
				}
				else{
					try=try+1;
					call Leds.led1Toggle();
					post sendMessage();
				}				
			}
		}
		if(error==SUCCESS){
			call Leds.led0Toggle();
		}
	}
	
	event void CC2420Config.syncDone(error_t error){
		
	}
	
	
	event void sendTimer.fired(){
		try=0;
		post sendMessage();	
	}
	
}
