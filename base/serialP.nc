#include <Timer.h>
#include "message.h"

module serialP{
	uses interface Boot;
	uses interface Timer<TMilli> as sendTimer; 
	uses interface Leds;
	uses interface Packet;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface SplitControl as SerialControl;
	uses interface CC2420Config;
	uses interface PacketAcknowledgements;
	uses interface CC2420Packet;
	uses interface Receive;
	uses interface PacketTimeStamp<TMilli,uint32_t>;
		
}
implementation{
	message_t sendingMsg;	
	uint16_t try=0;
	uint16_t senderRssi;
	uint32_t timestamp;
	uint16_t counter=0;
	uint16_t nodeid;
	payload_t *payloadIn;
	payload_t *payloadMsg;
	task void sendMessage(){		
		payloadMsg=(payload_t *)call Packet.getPayload(&sendingMsg, sizeof(payload_t));
		payloadMsg->nodeid=nodeid;
		payloadMsg->counter=counter;
		counter=(++counter)%1024;
		payloadMsg->rssi=senderRssi;
		payloadMsg->timestamp=timestamp;
		//call PacketAcknowledgements.requestAck(&sendingMsg);
		if(call AMSend.send(AM_BROADCAST_ADDR,&sendingMsg,sizeof(payload_t))!=SUCCESS){
			post sendMessage();				
		}
		//call Leds.led0Toggle();
	}
	
	event void Boot.booted(){
		call AMControl.start();
		call SerialControl.start();
		call sendTimer.startPeriodic(1000);
		
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
	
	event void SerialControl.startDone(error_t error){
		if(error!=SUCCESS){
			call SerialControl.start();
		}
	}
	
	
	event void AMControl.stopDone(error_t error){
		
	}
	
	event void SerialControl.stopDone(error_t error){
		
	}
	
		
	event void AMSend.sendDone(message_t *temp, error_t error){
		atomic{
			if(error!=SUCCESS){
				if(try==3){
					try=0;	
				}
				else{
					try=try+1;
					post sendMessage();
				}				
			}
		}
	}
	
	event void CC2420Config.syncDone(error_t error){
		
	}
	
	
	event void sendTimer.fired(){
		//call Leds.led2Toggle();
		//post sendMessage();
	}
	
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		//call Leds.led1Toggle();
		payloadIn=payload;
		//else 
		if(payloadIn->nodeid==1||payloadIn->nodeid==2||payloadIn->nodeid==3){
			atomic{
				senderRssi=payloadIn->rssi;
				timestamp=payloadIn->timestamp;
				nodeid=payloadIn->nodeid;
				counter=payloadIn->counter;
				try=0;
				post sendMessage();
			}
			
		}
		return msg;
	}

	
}
