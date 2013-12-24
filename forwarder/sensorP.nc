#include <Timer.h>
#include "message.h"

module sensorP{
	uses interface Boot;
	uses interface Timer<TMilli> as sendTimer; 
	uses interface Leds;
	uses interface Packet;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
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
	uint16_t counter;
	payload_t *payloadIn;
	
	payload_t *payloadMsg;
	task void sendMessage(){		
		payloadMsg=(payload_t *)call Packet.getPayload(&sendingMsg, sizeof(payload_t));
		payloadMsg->nodeid=TOS_NODE_ID;
		payloadMsg->rssi=senderRssi;
		payloadMsg->timestamp=timestamp;
		payloadMsg->counter=counter;
		//call PacketAcknowledgements.requestAck(&sendingMsg);
                //call CC2420Packet.setPower(&sendingMsg, 31);
		if(call AMSend.send(0,&sendingMsg,sizeof(payload_t))!=SUCCESS){
			post sendMessage();				
		}
		call Leds.led2Toggle();
	}
	
	event void Boot.booted(){
		call AMControl.start();
		call sendTimer.startPeriodic(250);
		
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
					post sendMessage();
				}				
			}
		
		}
	}
	
	event void CC2420Config.syncDone(error_t error){
		
	}
	
	
	event void sendTimer.fired(){
		//call Leds.led0Toggle();
	}
	
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		call Leds.led1Toggle();
		payloadIn=payload;
		if(payloadIn->nodeid==5){
			atomic{
				senderRssi=call CC2420Packet.getRssi(msg);
				if(call PacketTimeStamp.isValid(msg)){
					timestamp=call PacketTimeStamp.timestamp(msg);
				}
				counter=payloadIn->counter;
				try=0;
				post sendMessage();
			}			
		}
		return msg;
	}

	
}
