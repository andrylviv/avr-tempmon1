#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <avr/pgmspace.h>    
#include "usbdrv.h"

#include "asmdispsens.h" 

volatile struct dataexchange_t   
{
   uchar b1;      
   uchar b2;      
                   
};               


volatile struct dataexchange_t pdata = {0, 0};
	volatile unsigned char TempH;
	volatile unsigned char TempL;
    volatile unsigned char TempH_temp;
    volatile unsigned char TempL_temp;
PROGMEM char usbHidReportDescriptor[22] = { // USB report descriptor         
    0x06, 0x00, 0xff,                       // USAGE_PAGE (Generic Desktop)
    0x09, 0x01,                             // USAGE (Vendor Usage 1)
    0xa1, 0x01,                             // COLLECTION (Application)
    0x15, 0x00,                             //    LOGICAL_MINIMUM (0)        
    0x26, 0xff, 0x00,                       //    LOGICAL_MAXIMUM (255)      
    0x75, 0x08,                             //    REPORT_SIZE (8)            
    0x95, sizeof(struct dataexchange_t),    //    REPORT_COUNT               
    0x09, 0x00,                             //    USAGE (Undefined)
    0xb2, 0x02, 0x01,                       //    FEATURE (Data,Var,Abs,Buf)
    0xc0                                    // END_COLLECTION
};


static uchar    currentAddress;
static uchar    bytesRemaining;


// usbFunctionRead() call when host reqest data portion from device

 uchar   usbFunctionRead(uchar *data, uchar len)
{
    if(len > bytesRemaining)
        len = bytesRemaining;

    uchar *buffer = (uchar*)&pdata;

    if(!currentAddress)        // no one data portion is not read yet.
    {                          // filling structure for transfer 
          
            pdata.b1 = TempH_temp;
        
            pdata.b2 = TempL_temp;
       
    }

    uchar j;
    for(j=0; j<len; j++)
        data[j] = buffer[j+currentAddress];

    currentAddress += len;
    bytesRemaining -= len;
    return len;
}

/* ------------------------------------------------------------------------- */
uchar usbFunctionWrite(uchar *data, uchar len)
{
	return 1;
}
/*----------------------------------------------------------------------------*/
usbMsgLen_t usbFunctionSetup(uchar data[8])
{
	usbRequest_t    *rq = (void *)data;

	if((rq->bmRequestType & USBRQ_TYPE_MASK) == USBRQ_TYPE_CLASS){    /* HID devise */
		if(rq->bRequest == USBRQ_HID_GET_REPORT){  /* wValue: ReportType (highbyte), ReportID (lowbyte) */
			// we have single type of report, we can ignore report-ID
			bytesRemaining = sizeof(struct dataexchange_t);
			currentAddress = 0;
			return USB_NO_MSG;  // using usbFunctionRead() for transfer data on host
			}else if(rq->bRequest == USBRQ_HID_SET_REPORT){
			// we have single type of report, we can ignore report-ID
			bytesRemaining = sizeof(struct dataexchange_t);
			currentAddress = 0;
			return USB_NO_MSG;  // use usbFunctionWrite() for getting data from host
		}
		}else{
		/* ignoring rest requests  */
	}
	return 0;
}
/* ------------------------------------------------------------------------- */
volatile unsigned char kom_dan_value;
volatile unsigned char display=0x30;
volatile unsigned char te;
volatile unsigned char rou;
volatile unsigned long dia;
volatile unsigned int div_a;
volatile unsigned char symb;
void con_disp(void){
	 maina();
		rou=TempH;
		dia = TempL;
		while(rou>=100){            //-----------------------------------------------------------------------
			rou=rou-100;
			display++;                //out hundred
		}
		kom_dan_value=1;
		ready_wait_for_c();         //------------------
		while(rou>=10){             //------------------                             rou
			rou=rou-10;
			display++;              //out tens
		}
		kom_dan_value=1;
		ready_wait_for_c();         //------------------
		display=0x30+rou;                //out ones
		kom_dan_value=1;
		ready_wait_for_c();         //------------------
		
		display=0x2E;
		kom_dan_value=1;
		ready_wait_for_c();         //point
		                            //----------------------------------------------------------------------
		div_a=dia*10000/16;							
		while(div_a>=1000){            //------------------
			div_a=div_a-1000;
			display++;                //out hundred
		}
		kom_dan_value=1;
		ready_wait_for_c();					
		while(div_a>=100){            //------------------
			div_a=div_a-100;
			display++;                //out hundred                                 div
		}
		kom_dan_value=1;
		ready_wait_for_c();         //------------------
		while(div_a>=10){             //------------------
			div_a=div_a-10;
			display++;              //out tens
		}
		kom_dan_value=1;
		ready_wait_for_c();         //------------------
		display=(unsigned char)div_a+0x30;                //out ones
		kom_dan_value=1;
		ready_wait_for_c();         //------------------------------------------------------------------
		display=0x43;
		kom_dan_value=1;
		ready_wait_for_c();         //знак "C"

		display=0xDF;
		kom_dan_value=1;            //знак "°"
		ready_wait_for_c();
		
		display=0x82;
		kom_dan_value=0;
		ready_wait_for_c();
}
ISR(TIMER1_COMPA_vect){
	con_disp();
}

int main(void)
{
	
	  DDRD= 0b11111011;                // port initialization  
	  DDRB= 0b00000001;
	//  usbFunctionRead(0x0060, 2);
      usbInit();
      usbDeviceDisconnect();  // forcibly disconnect from host, we can do it when interruptions is switched off!
      
      uchar i = 0;
      while(--i){             // pause > 250 ms
	      _delay_ms(1);
      }
      
      usbDeviceConnect();     // connecting
	                                             //--------------------------
	  TCCR1B = 1<<WGM12|1<<CS10|0<<CS11|1<<CS12; //compare match mode, prescaler 1024 
	  TCNT1H = 0;                                //clean
	  TCNT1L = 0;                                //timer
	  OCR1AH = 0b00010011;                       //compare reg
	  OCR1AL = 0b10001000;                       //set 5000 (~500ms)
	  TIMSK = 0<<TOIE1|1<<OCIE1A;                //start compare match mode
	                                             //---------------------------
      sei();                  // allowing interruption

	 _delay_ms(40);
	  vst_kom();
	
     while (1)
     {
	    usbPoll();
     }
	 return 0;
}

