
#ifndef ASMDISPSENS_H_
#define ASMDISPSENS_H_
//Общие определения


#ifdef __ASSEMBLER__     //Определения только для ассемблера
//#include <avr/io.h>
#define  al r20
#define  am r21
#define  ah r22
#define  bl r27
#define  c0 r16
#define  c1 r17
#define  c2 r23
#define  tmp r23

#define	 tempdiv r26
#define  kom_dan r23
#define  cou r20
#define  dsW_R r19
#define  temp  r18
#define  data  r19
#define  L 0
#define	 RS 0
#define	 RW 1
#define  E 3

#define PORTB 0x18
#define PORTD 0x12
#define DDRD 0x11
#define DDRB 0x17
#define DDRC 0x14
#define PinB 0x16
#define PinD 0x10
#define SREG 0x3F

#endif
#ifndef __ASSEMBLER__

//Определения только для С

char vst_kom();
char maina();
char ready_wait_for_c();

#endif

#endif