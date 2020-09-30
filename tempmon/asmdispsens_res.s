
;�������� ������������ ����, �� ������, ���� 
;� ��� ���� �����-���� ����������� �����������
#include "asmdispsens.h"

;������������ asm_func
.global vst_kom_a
.global vst_kom
.global Main
;.global asm_func
;� �������, ��� ���-�� ���� ������ ��� ������ global_var
; - ���� ���������� ����������
;.extern global_var
.extern symb
.extern TempH
.extern TempL

/*
;��������� �������
asm_func:

; � ���������� R30 - R31 ����� ������ ��� ������, �� ���,
; ��-����������������, ����������� ���� Z. ��������� � 
; ��� ����� ���������� ����������

    ldi R30,lo8(global_var)
    ldi R31,hi8(global_var)

; �������� �������� ���������� ���������� � ������� R25,
; � ������� ���� ����� ������ ��� ������
    ldi r20,11
	sts global_var,r20
    ld R25,Z

; ���������� ��������, ������� ����� � R24,
; � �������� ���������� ����������

    add R24,R25

; ���, ������ ������ ������ �� ����, ������ ��� 
; ������������ �������� � ������ ������ � R24, 
; ������� �� ������������
    ret
*/

ready_wait: 
                     
 ;---���������� ���������
 ldi temp,0b00000111 ;���� ��
 out DDRD,temp       ; ����
 in R16,PORTD        ;���
 ORI r16,0xF0        ;��������
 out PORTD,R16

 cbi PORTD,RS  ; RS 0
 sbi PORTD,RW  ; R/W 1
 nop
 sbi PORTD,E  ;E 1
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   17 �s                               upd12
 rcall delay       ;--------------------------
 in r19,PinD
 nop
 cbi PORTD,E  ;E 0
 nop
 sbi PORTD,E  ;E 1
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   17 �s                               upd12
 rcall delay       ;--------------------------
 in r20,PinD
 nop
 cbi PORTD,E  ;E 0
 ldi r24,0x07      ;--------------------------
 ldi r25,0x00      ;   3 �s                                upd12
 rcall delay       ;--------------------------
 sbrc r19,7
 rjmp ready_wait
 ;   ������� �������� �������
 clr temp
 out PORTD,temp
 ldi temp,0b11110111 ;���� ��
 out DDRD,temp 
 push kom_dan       ;���� ���_���
 andi kom_dan,0xF0  ;� �������� ������ ����. ����� (������� �������) 
 out PORTD,R22
 nop
 sbi PORTD,E       ;E 1
 in R22,PORTD      ;������ ���� d-
 andi r22,0x0F
 or R22,kom_dan    ;�������� RS,R/W,E � �� ����. ���_���
 out PORTD,R22     ;������ � ����
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   17 �s                                upd12
 rcall delay       ;--------------------------
 cbi PORTD,E      ;����� � 0
 nop
 nop
 ;�������� ������� �������
 in R16,PORTD     ;������ ���� d
 andi r16,0x0F    ;��������� ��.���� ����� RS,R/W,E 
 pop kom_dan          ;���� ���_���
 swap kom_dan       
 andi kom_dan,0xF0    ;� �������� ������ ����. ����� (������ �������) 
 out PORTD,R16
 nop
 sbi PORTD,E         ;����� � 1
 in R16,PORTD     ;������ ���� d
 andi r16,0x0F
 or R16,kom_dan       ;�������� RS,R/W,E � �� ����. ���_���
 out PORTD,R16    ;��������� � ���� 
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   17 �s                                 upd12
 rcall delay       ;--------------------------
 cbi PORTD,E         ;����� � 0
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   17 �s                                 upd12
 rcall delay       ;--------------------------
 ldi r16,0b00000011
 sbrc r22,1
 ldi r16,0b00000010
 out PORTD,R16
 ldi temp,0b00000111 ;���� ��
 out DDRD,temp       ; ���� 
 ret

init_com:	        
 push temp
 in temp,SREG
 ;��� ����������� (��� ��������)
 ldi r24,(0<<RS)|(1<<E)
 out PORTD,r24
 or temp,r24
 out PORTD,temp
 ldi r24,(0<<RS)|(0<<E)
 out PORTD,r24
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   �s                               upd12
 rcall delay       ;--------------------------
 out SREG,temp
 pop temp
 ret

reset18b20:       ;������� ���� � �������
sbi DDRB,L
cbi PORTB,L
;ret
ldi r24,0x9E      ;--------------------------
ldi r25,0x05      ;   480�s                             upd12
rcall delay       ;--------------------------
cbi DDRB,L
cbi PORTB,L
ldi r24,0x2E      ;--------------------------
ldi r25,0x00      ;   15�s(16)                          upd12
rcall delay       ;----------------------
vair: sbic PinB,0
rjmp vair
ldi r24,0x9E      ;--------------------------
ldi r25,0x05      ;   480�s                             upd12
rcall delay       ;--------------------------
ret

 write_slot:       ;���� ������
ldi cou,9
n_bit: dec cou
cpi cou,0
BRNE sd 
ret
sd:LSR dsW_R
BRCS wr_1_slot
BRCC wr_0_slot
wr_0_slot:
ldi r24,0xF1      ;--------------------------
ldi r25,0x00      ;   80�s                            upd12
sbi DDRB,L
cbi PORTB,L
rcall delay       ;--------------------------
cbi PORTB,L
cbi DDRB,L
;cbi PORTB,L
rjmp n_bit
wr_1_slot:
ldi r24,0x2E     ;--------------------------
ldi r25,0x00      ;   15�s                                 upd12
sbi DDRB,L
cbi PORTB,L
rcall delay       ;--------------------------
cbi DDRB,L
cbi PORTB,L
ldi r24,0xC4     ;--------------------------
ldi r25,0x00      ;   65�s                                 upd12
rcall delay       ;--------------------------
rjmp n_bit

;--------------------------------------------------------
read_slot:       ;���� �������
clr cou
ne_bit:
sbi DDRB,L
cbi PORTB,L       ;��������� ��� master
ldi r24,0x04      ;--------------------------
ldi r25,0x00      ;   1�s                                 upd12
rcall delay       ;--------------------------
cbi DDRB,L        ;��������
cbi PORTB,L       ;���� 
ldi r24,0x25      ;--------------------------
ldi r25,0x00      ;   12�s                                upd12
rcall delay       ;--------------------------
in temp,PinB
lsr temp
ROR data
inc cou
cpi cou,8
BREQ tim1
cpi cou,16
BREQ tim2
rjmp ndel
tim1:sts TempL,data
rjmp ndel
tim2:sts TempH,data
ret
ndel:ldi r24,0x88      ;--------------------------
ldi r25,0x00      ;   45�s                                  upd12
rcall delay       ;--------------------------
rjmp ne_bit
ret

vpor:
lds temp,TempH ;���� ��.������
swap temp      ;
andi temp,0xF0 ;�������� ����
lds r17,TempL  ;���� ���.���
swap r17       ;
andi r17,0x0F  ;���� �����.���
or temp,r17    ;�������� ���� �����������
sts TempH,temp ;�������� �������
lds r17,TempL  ;
andi r17,0x0F  ;
sts TempL,r17  ;� ��������
sbrs temp,7    ;�������� �� ���������
rjmp vstplus   ;���� +
com r17        ;-------------
andi r17,0x0F  ;
com temp
ldi r18,1
add r17,r18
mov r18,r17
andi r17,0x0F
sts TempL,r17  ;�������� ����:)
swap r18
lsr r18
clr r18
adc temp,r18
sts TempH,temp ;�������� 
ldi temp,0x2D  ;
sts symb,temp  ;
ret			   ;----------------------
vstplus:       ;���������� ����
ldi temp,0x2B
sts symb,temp
ret

hudred:
lds znach1,TempH
clr display
 ldi r27,0b01100100        ; 100 byte-------------------------------
hundred1:
		cp znach1,r27    ;                     \  /
		BRCS   diltens1     ;                       hundred
		sub znach1,r27   ;                     /  \
		;inc display
		subi display,-1
		rjmp hundred1 ;--------------------------------------------------
diltens1:ori display,0x30     ;------------------------------
        mov kom_dan,display         ;�������� ��
        ldi r22,1               ;�������
        rcall ready_wait        ;------------------------------                                 ghfggdhgfhfghh
		clr display
ldi r27,0b00001010  ; 10 byte-----------------------------------
 tens1: clc
		cp znach1,r27;                \  /
		BRCS   dilones1;                  tens
		sub znach1,r27;               /  \
		;inc display
		subi display,-1
		rjmp tens ;---------------------------------------------- 
dilones1:ori display,0x30     ;------------------------------
        mov kom_dan,display         ;�������� ��
        ldi r22,1               ;�������
        rcall ready_wait        ;------------------------------                                 fhdfghfgghgh
		clr display
mov display,znach1; ones
        ori display,0x30     ;------------------------------
        mov kom_dan,display         ;�������� ��
        ldi r22,1               ;�������
        rcall ready_wait        ;------------------------------                                 dhfdghfdgfgdg
		clr display
        clr dres16uL
		ret

vst_thou:
;ldi bl,8
lds bl,TempL
ldi al,0x10
ldi am,0x27
ldi ah,0x00
clr tmp
mul8_16:         ;�������� 
 mul al,bl

 ;movw c1:c0,r1:r0
 mov c1,r1
 mov c0,r0

 mul am,bl
 add c1,r0
 adc c2,r1
 adc c2,tmp
 mul ah,bl
 add c2,r0
 ldi	dv16uL,16
;***** Code
div16u:	clr	drem16uL	  ;clear remainder Low byte
    clr	drem16uH
	sub	drem16hH,drem16hH ;clear remainder High byte and carry
	ldi	dcnt16u,25	      ;init loop counter
d16u_1:	rol	dd16uL		  ;shift left dividend
	rol	dd16uH
	rol	dd16hH
	dec	dcnt16u		      ;decrement counter
	brne	d16u_2        ;if done
	rjmp rocc			  ;  return
d16u_2:	rol	drem16uL	  ;shift dividend into remainder
	rol	drem16uH
	rol	drem16hH
	sub	drem16uL,dv16uL	  ;remainder = remainder - divisor
	sbci	drem16uH,0	  ;
	sbci	drem16hH,0	  ;
	brcc	d16u_3		  ;if result negative
	add	drem16uL,dv16uL	  ; restore remainder
	clr tempdiv
	adc	drem16uH,tempdiv
	adc	drem16hH,tempdiv
	clc			          ; clear carry to be shifted into result
	rjmp	d16u_1		  ;else
d16u_3:	sec			      ;  set carry to be shifted into result
	rjmp	d16u_1

 rocc:mov znach1,dres16uL
     mov znach2,dres16uH
     mov znach3,dres16hH	
dildus:	ldi r27,0b11101000  ; 1000 L-byte------------------------------
		ldi r28,0b00000011  ; 1000 H-byte
		clr display
thousent:clc
		cp znach1,r27
		cpc znach2,r28
		clr temp;                               \  /
		cpc znach3,temp;                  thousend
		BRCS   dilhundred;                      /  \
		sub znach1,r27
		sbc znach2,r28
		clr temp
		sbc znach3,temp
		;inc display
		subi display,-1
		rjmp thousent;--------------------------------------------------

dilhundred:ori display,0x30     ;------------------------------
        mov kom_dan,display         ;�������� ��
        ldi r22,1               ;�������
        rcall ready_wait        ;------------------------------                                 fghfghhgfhgfhgfhgf
		clr display
        ldi r27,0b01100100  ; 100 byte-------------------------------
hundred:clc
		cp znach1,r27
		clr temp
		cpc znach2,temp;                     \  /
		BRCS   diltens;                       hundred
		sub znach1,r27;                     /  \
		clr temp
		sbc znach2,temp
		;inc display
		subi display,-1
		rjmp hundred ;--------------------------------------------------
diltens:ori display,0x30     ;------------------------------
        mov kom_dan,display         ;�������� ��
        ldi r22,1               ;�������
        rcall ready_wait        ;------------------------------                                 ghfggdhgfhfghh
		clr display
ldi r27,0b00001010  ; 10 byte-----------------------------------
  tens: clc
		cp znach1,r27;                \  /
		BRCS   dilones;                  tens
		sub znach1,r27;               /  \
		;inc display
		subi display,-1
		rjmp tens ;---------------------------------------------- 
dilones:ori display,0x30        ;------------------------------
        mov kom_dan,display     ;�������� ��
        ldi r22,1               ;�������
        rcall ready_wait        ;------------------------------                                 fhdfghfgghgh
		clr display
        mov display,znach1      ; ones
        ori display,0x30        ;------------------------------
        mov kom_dan,display     ;�������� ��
        ldi r22,1               ;�������
        rcall ready_wait        ;------------------------------                                 dhfdghfdgfgdg
		clr display
        clr znach1
		ret
;------------------------------
delay:
subi r24,1
sbci r25,0           ;��������
brcc delay
ret
delay1:
subi r23,1
sbci r24,0           ;��������
sbci r25,0
brcc delay1
ret
;------------------------------
vst_kom_a: 
/*push r0
push r1                                        ;�������  ---------------------------------------     
push r5
push r6
push r7
push r17*/
push r16

ldi temp,0b11110111
out DDRD,temp
ldi temp,0b00000000
out PORTD,temp
ldi temp, 0b00000000
out DDRC,temp
ldi temp, 0b00000000
out DDRB,temp
ldi temp, 0b00000000
out PORTB,temp

;ret

vst_kom:
ldi r23,0xBE       ;--------------------------
ldi r24,0xD4 
ldi r25,0x01       ;   50 ms                               upd12
rcall delay1       ;--------------------------
ldi kom_dan,0b00110000
ldi r22,0
rcall init_com
ldi r24,0xA0      ;--------------------------
ldi r25,0x3A      ;   5ms                                  upd12
rcall delay       ;--------------------------
ldi kom_dan,0b00110000
ldi r22,0
rcall init_com
ldi r24,0x59      ;--------------------------
ldi r25,0x02      ;   200�s                                upd12
rcall delay       ;--------------------------
ldi kom_dan,0b00110000
ldi r22,0
rcall init_com
ldi r24,0x97      ;--------------------------
ldi r25,0x00      ;   50�s                                 upd12
rcall delay       ;--------------------------

;-----------------------------------------------------------------------------------------
ldi kom_dan,0x02  
ldi r22,0
rcall ready_wait     
ldi kom_dan,0x28
ldi r22,0
rcall ready_wait                                                 ;�����������
ldi kom_dan,0x0c
ldi r22,0
rcall ready_wait
ldi kom_dan,0x01
ldi r22,0
rcall ready_wait
ldi kom_dan,0x06
ldi r22,0
rcall ready_wait 
;----------------------------------------------------------------------------------------
;������� �������
ldi kom_dan,0x74    ;-------------
ldi r22,1           ;��� ����� "t"
rcall ready_wait    ;-------------
ldi kom_dan,0x3D    ;-------------
ldi r22,1           ;��� ���� "="
rcall ready_wait    ;-------------
pop r16
;ret
;-------------------------------------------------------------------------------
Main:
/*push r0
push r1                                          
push r5
push r6
push r7
push r16
push r17*/
rcall reset18b20    ;��������� ���� � ������
ldi dsW_R,0xCC      ;�������
rcall write_slot    ;ROM
;Main:
ldi dsW_R,0x44      ;�������
rcall write_slot    ;����
rea_vait:sbis PinB,L;��������
rjmp rea_vait       ;���������
rcall reset18b20   ;��������� ���� � ������
ldi dsW_R,0xCC     ;�������
rcall write_slot   ;ROM
ldi dsW_R,0xBE     ;�������
rcall write_slot   ;�����
rcall read_slot    ;����� �����������
rcall reset18b20   ;��������� ���� � ������. ����� �����������)
ldi dsW_R,0xCC     ;�������
rcall write_slot   ;ROM
rcall vpor         ;�������� �� ��������
lds kom_dan,symb   ;---------------------------------------------
ldi r22,1          ;������������ �����
rcall ready_wait   ;----------------------------------------------
rcall hudred       ;��� ���
ldi kom_dan,0x2E   ;----------------------
ldi r22,1          ;������ ������
rcall ready_wait   ;----------------------
rcall vst_thou     ;����������� ������
ldi kom_dan,0xDF   ;----------------------
ldi r22,1          ;���� "�" 
rcall ready_wait   ;----------------------
ldi kom_dan,0x43
ldi r22,1
rcall ready_wait
;��� ��� �������
ldi kom_dan,0x82    ;------------
ldi r22,0           ;���� 2 ���
rcall ready_wait    ;------------

ldi r23,0x80        ;--------------------------
ldi r24,0x84 
ldi r25,0x1E        ;   50 ms
rcall delay1        ;--------------------------
/*
pop r17
pop r16
pop r7
pop r6
pop r5
pop r1
pop r0
ret*/
rjmp Main