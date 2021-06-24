// Created: 7/29/2019 7:53:56 PM
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <avr/pgmspace.h>   //нужно дл€ usbdrv.h 
#include "usbdrv.h"

#include "asmdispsens.h"     //дл€ asm кода

volatile struct dataexchange_t       // ќписание структуры дл€ передачи данных
{
   uchar b1;        // я решил дл€ примера написать структуру на 3 байта.
   uchar b2;        // Ќа каждый байт подцепим ногу из PORTB.  онечно это
                    // не рационально (всего то 3 бита нужно).
};                  // Ќо в цел€х демонстрации в самый раз.
                    // ƒл€ нагл€дности прикрутить по светодиоду и созерцать :)


volatile struct dataexchange_t pdata = {0, 0};
	volatile unsigned char TempH;
	volatile unsigned char TempL;
    volatile unsigned char TempH_temp; //=0b00000101
    volatile unsigned char TempL_temp; //=0b01011111
PROGMEM char usbHidReportDescriptor[22] = { // USB report descriptor         // ƒескриптор описывает структуру пакета данных дл€ обмена
    0x06, 0x00, 0xff,                       // USAGE_PAGE (Generic Desktop)
    0x09, 0x01,                             // USAGE (Vendor Usage 1)
    0xa1, 0x01,                             // COLLECTION (Application)
    0x15, 0x00,                             //    LOGICAL_MINIMUM (0)        // min. значение дл€ данных
    0x26, 0xff, 0x00,                       //    LOGICAL_MAXIMUM (255)      // max. значение дл€ данных, 255 тут не случайно, а чтобы уложитьс€ в 1 байт
    0x75, 0x08,                             //    REPORT_SIZE (8)            // информаци€ передаетс€ порци€ми, это размер одного "репорта" 8 бит
    0x95, sizeof(struct dataexchange_t),    //    REPORT_COUNT               // количество порций (у нашем примере = 2, описанна€ выше структура передастс€ за три репорта)
    0x09, 0x00,                             //    USAGE (Undefined)
    0xb2, 0x02, 0x01,                       //    FEATURE (Data,Var,Abs,Buf)
    0xc0                                    // END_COLLECTION
};
/* «десь мы описали только один report, из-за чего не нужно использовать report-ID (он должен быть первым байтом).
 * — его помощью передадим 3 байта данных (размер одного REPORT_SIZE = 8 бит = 1 байт, их количество REPORT_COUNT = 3).
 */


/* Ёти переменные хран€т статус текущей передачи */
static uchar    currentAddress;
static uchar    bytesRemaining;


/* usbFunctionRead() вызываетс€ когда хост запрашивает порцию данных от устройства
 * ƒл€ дополнительной информации см. документацию в usbdrv.h
 */
 uchar   usbFunctionRead(uchar *data, uchar len)
{
    if(len > bytesRemaining)
        len = bytesRemaining;

    uchar *buffer = (uchar*)&pdata;

    if(!currentAddress)        // Ќи один кусок данных еще не прочитан.
    {                          // «аполним структуру дл€ передачи
          
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

	if((rq->bmRequestType & USBRQ_TYPE_MASK) == USBRQ_TYPE_CLASS){    /* HID устройство */
		if(rq->bRequest == USBRQ_HID_GET_REPORT){  /* wValue: ReportType (highbyte), ReportID (lowbyte) */
			// у нас только одна разновидность репорта, можем игнорировать report-ID
			bytesRemaining = sizeof(struct dataexchange_t);
			currentAddress = 0;
			return USB_NO_MSG;  // используем usbFunctionRead() дл€ отправки данных хосту
			}else if(rq->bRequest == USBRQ_HID_SET_REPORT){
			// у нас только одна разновидность репорта, можем игнорировать report-ID
			bytesRemaining = sizeof(struct dataexchange_t);
			currentAddress = 0;
			return USB_NO_MSG;  // используем usbFunctionWrite() дл€ получени€ данных от хоста
		}
		}else{
		/* остальные запросы мы просто игнорируем */
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
	/*	rou=TempH<<4;               //видалили хлам з ст тетр
		te=TempL;
		te =te>>4;                  //видалтли дробн≥
		rou = rou|te;               //зростили ц≥л≥
		te = 0b00001111;
		dia = TempL && te;      //впор дробн≥
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
		ready_wait_for_c();         //знак "C"

		display=0xDF;
		kom_dan_value=1;            //знак "∞"
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
      usbDeviceDisconnect();  // принудительно отключаемс€ от хоста, так делать можно только при выключенных прерывани€х!
      
      uchar i = 0;
      while(--i){             // пауза > 250 ms
	      _delay_ms(1);
      }
      
      usbDeviceConnect();     // подключаемс€
	                                             //--------------------------
	  TCCR1B = 1<<WGM12|1<<CS10|0<<CS11|1<<CS12; //compare match mode, prescaler 1024 
	  TCNT1H = 0;                                //clean
	  TCNT1L = 0;                                //timer
	  OCR1AH = 0b00010011;                       //compare reg
	  OCR1AL = 0b10001000;                       //set 5000 (~500ms)
	  TIMSK = 0<<TOIE1|1<<OCIE1A;                //start compare match mode
	                                             //---------------------------
      sei();                  // разрешаем прерывани€

	 _delay_ms(40);
	  vst_kom();
	
     while (1)
     {
	    usbPoll();
     }
	 return 0;
}

