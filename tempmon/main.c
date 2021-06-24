// Created: 7/29/2019 7:53:56 PM
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <avr/pgmspace.h>   //����� ��� usbdrv.h 
#include "usbdrv.h"

#include "asmdispsens.h"     //��� asm ����

volatile struct dataexchange_t       // �������� ��������� ��� �������� ������
{
   uchar b1;        // � ����� ��� ������� �������� ��������� �� 3 �����.
   uchar b2;        // �� ������ ���� �������� ���� �� PORTB. ������� ���
                    // �� ����������� (����� �� 3 ���� �����).
};                  // �� � ����� ������������ � ����� ���.
                    // ��� ����������� ���������� �� ���������� � ��������� :)


volatile struct dataexchange_t pdata = {0, 0};
	volatile unsigned char TempH;
	volatile unsigned char TempL;
    volatile unsigned char TempH_temp; //=0b00000101
    volatile unsigned char TempL_temp; //=0b01011111
PROGMEM char usbHidReportDescriptor[22] = { // USB report descriptor         // ���������� ��������� ��������� ������ ������ ��� ������
    0x06, 0x00, 0xff,                       // USAGE_PAGE (Generic Desktop)
    0x09, 0x01,                             // USAGE (Vendor Usage 1)
    0xa1, 0x01,                             // COLLECTION (Application)
    0x15, 0x00,                             //    LOGICAL_MINIMUM (0)        // min. �������� ��� ������
    0x26, 0xff, 0x00,                       //    LOGICAL_MAXIMUM (255)      // max. �������� ��� ������, 255 ��� �� ��������, � ����� ��������� � 1 ����
    0x75, 0x08,                             //    REPORT_SIZE (8)            // ���������� ���������� ��������, ��� ������ ������ "�������" 8 ���
    0x95, sizeof(struct dataexchange_t),    //    REPORT_COUNT               // ���������� ������ (� ����� ������� = 2, ��������� ���� ��������� ���������� �� ��� �������)
    0x09, 0x00,                             //    USAGE (Undefined)
    0xb2, 0x02, 0x01,                       //    FEATURE (Data,Var,Abs,Buf)
    0xc0                                    // END_COLLECTION
};
/* ����� �� ������� ������ ���� report, ��-�� ���� �� ����� ������������ report-ID (�� ������ ���� ������ ������).
 * � ��� ������� ��������� 3 ����� ������ (������ ������ REPORT_SIZE = 8 ��� = 1 ����, �� ���������� REPORT_COUNT = 3).
 */


/* ��� ���������� ������ ������ ������� �������� */
static uchar    currentAddress;
static uchar    bytesRemaining;


/* usbFunctionRead() ���������� ����� ���� ����������� ������ ������ �� ����������
 * ��� �������������� ���������� ��. ������������ � usbdrv.h
 */
 uchar   usbFunctionRead(uchar *data, uchar len)
{
    if(len > bytesRemaining)
        len = bytesRemaining;

    uchar *buffer = (uchar*)&pdata;

    if(!currentAddress)        // �� ���� ����� ������ ��� �� ��������.
    {                          // �������� ��������� ��� ��������
          
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

	if((rq->bmRequestType & USBRQ_TYPE_MASK) == USBRQ_TYPE_CLASS){    /* HID ���������� */
		if(rq->bRequest == USBRQ_HID_GET_REPORT){  /* wValue: ReportType (highbyte), ReportID (lowbyte) */
			// � ��� ������ ���� ������������� �������, ����� ������������ report-ID
			bytesRemaining = sizeof(struct dataexchange_t);
			currentAddress = 0;
			return USB_NO_MSG;  // ���������� usbFunctionRead() ��� �������� ������ �����
			}else if(rq->bRequest == USBRQ_HID_SET_REPORT){
			// � ��� ������ ���� ������������� �������, ����� ������������ report-ID
			bytesRemaining = sizeof(struct dataexchange_t);
			currentAddress = 0;
			return USB_NO_MSG;  // ���������� usbFunctionWrite() ��� ��������� ������ �� �����
		}
		}else{
		/* ��������� ������� �� ������ ���������� */
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
	/*	rou=TempH<<4;               //�������� ���� � �� ����
		te=TempL;
		te =te>>4;                  //�������� �����
		rou = rou|te;               //�������� ���
		te = 0b00001111;
		dia = TempL && te;      //���� �����
		if(dia>0){
			display=0x2B;
			kom_dan_value=1;
		    ready_wait_for_c();
		}else if(dia<0){	
			display=0x2B;
			kom_dan_value=1;
		    ready_wait_for_c();
			dia = !dia+1;
			}
			*/
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
		ready_wait_for_c();         //���� "C"

		display=0xDF;
		kom_dan_value=1;            //���� "�"
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
      usbDeviceDisconnect();  // ������������� ����������� �� �����, ��� ������ ����� ������ ��� ����������� �����������!
      
      uchar i = 0;
      while(--i){             // ����� > 250 ms
	      _delay_ms(1);
      }
      
      usbDeviceConnect();     // ������������
	                                             //--------------------------
	  TCCR1B = 1<<WGM12|1<<CS10|0<<CS11|1<<CS12; //compare match mode, prescaler 1024 
	  TCNT1H = 0;                                //clean
	  TCNT1L = 0;                                //timer
	  OCR1AH = 0b00010011;                       //compare reg
	  OCR1AL = 0b10001000;                       //set 5000 (~500ms)
	  TIMSK = 0<<TOIE1|1<<OCIE1A;                //start compare match mode
	                                             //---------------------------
      sei();                  // ��������� ����������

	 _delay_ms(40);
	  vst_kom();
	
     while (1)
     {
	    usbPoll();
     }
	 return 0;
}

