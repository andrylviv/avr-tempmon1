
;�������� ������������ ����, �� ������, ���� 
;� ��� ���� �����-���� ����������� �����������
#include "asmdispsens.h"

;������������ asm_func
;.global init
.global vst_kom
.global maina
.global ready_wait_for_c
;.global asm_func
;� �������, ��� ���-�� ���� ������ ��� ������ global_var
; - ���� ���������� ����������
;.extern global_var
.extern kom_dan_value
.extern TempH
.extern TempL
.extern TempH_temp
.extern TempL_temp
.extern display
.extern symb

ready_wait_for_c:lds r22,kom_dan_value
                 lds kom_dan,display
ready_wait: 
                     
 ;---���������� ���������
 ldi temp,0b00001011 ;���� ��
 out DDRD,temp       ; ����
 in temp,PORTD        ;���
 ORI temp,0xF0        ;��������
 out PORTD,temp

 cbi PORTD,RS  ; RS 0
 sbi PORTD,RW  ; R/W 1
 nop
 sbi PORTD,E  ;E 1
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   �s
 rcall delay       ;--------------------------
 in r19,PinD
 nop
 cbi PORTD,E  ;E 0
 nop
 sbi PORTD,E  ;E 1
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   �s
 rcall delay       ;--------------------------
 in r20,PinD
 nop
 cbi PORTD,E  ;E 0
 ldi r24,0x07      ;--------------------------
 ldi r25,0x00      ;   �s
 rcall delay       ;--------------------------
 sbrc r19,7
 rjmp ready_wait
 ;   ������� �������� �������
 clr temp
 out PORTD,temp
 ldi temp,0b11111011 ;���� ��
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
 ldi r25,0x00      ;   �s
 rcall delay       ;--------------------------
 cbi PORTD,E      ;����� � 0
 nop
 nop
 ;�������� ������� �������
 in temp,PORTD     ;������ ���� d
 andi temp,0x0F    ;��������� ��.���� ����� RS,R/W,E 
 pop kom_dan          ;���� ���_���
 swap kom_dan       
 andi kom_dan,0xF0    ;� �������� ������ ����. ����� (������ �������) 
 out PORTD,temp
 nop
 sbi PORTD,E         ;����� � 1
 in temp,PORTD     ;������ ���� d
 andi temp,0x0F
 or temp,kom_dan       ;�������� RS,R/W,E � �� ����. ���_���
 out PORTD,temp    ;��������� � ���� 
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   �s
 rcall delay       ;--------------------------
 cbi PORTD,E         ;����� � 0
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   �s
 rcall delay       ;--------------------------
 ldi temp,0b00000011
 sbrc r22,1
 ldi temp,0b00000010
 out PORTD,temp
 ldi temp,0b00001011 ;���� ��
 out DDRD,temp       ; ���� 
 ldi temp,0x30
 sts display,temp
 ret

init_com:	        
 //push temp
 in temp,SREG
 ;��� ����������� (��� ��������)
 ldi r24,(0<<RS)|(1<<E)
 out PORTD,r24
 or temp,r24
 out PORTD,temp
 ldi r24,(0<<RS)|(0<<E)
 out PORTD,r24
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   �s
 rcall delay 
 out SREG,temp
 //pop temp
 ret

reset18b20:       ;������� ���� � �������
sbi DDRB,L
cbi PORTB,L
;ret
ldi r24,0x9E      ;--------------------------
ldi r25,0x05      ;   480�s
rcall delay       ;--------------------------
cbi DDRB,L
cbi PORTB,L
ldi r24,0x2E      ;--------------------------
ldi r25,0x00      ;   15�s
rcall delay       ;----------------------
vair: sbic PinB,0
rjmp vair
ldi r24,0x9E      ;--------------------------
ldi r25,0x05      ;   480�s
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
ldi r25,0x00      ;   80�s
sbi DDRB,L
cbi PORTB,L
rcall delay       ;--------------------------
cbi PORTB,L
cbi DDRB,L
;cbi PORTB,L
rjmp n_bit
wr_1_slot:
ldi r24,0x2E     ;--------------------------
ldi r25,0x00      ;   15�s
sbi DDRB,L
cbi PORTB,L
rcall delay       ;--------------------------
cbi DDRB,L
cbi PORTB,L
ldi r24,0xC4     ;--------------------------
ldi r25,0x00      ;   65�s
rcall delay       ;--------------------------
rjmp n_bit

;--------------------------------------------------------
read_slot:       ;���� �������
clr cou
ne_bit:
sbi DDRB,L
cbi PORTB,L       ;��������� ��� master
ldi r24,0x04      ;--------------------------
ldi r25,0x00      ;   1�s
rcall delay       ;--------------------------
cbi DDRB,L        ;��������
cbi PORTB,L       ;���� 
ldi r24,0x25      ;--------------------------
ldi r25,0x00      ;   12�s
rcall delay       ;--------------------------
in temp,PinB
lsr temp
ROR data
;inc cou
subi cou,-1
cpi cou,8
BREQ tim1
cpi cou,16
BREQ tim2
rjmp ndel
tim1:sts TempL_temp,data
rjmp ndel
tim2:sts TempH_temp,data
ret
ndel:ldi r24,0x88      ;--------------------------
ldi r25,0x00      ;   45�s
rcall delay       ;--------------------------
rjmp ne_bit
ret

vpor:
lds temp,TempH_temp        ;���� ��.������
swap temp                  ;
andi temp,0xF0             ;�������� ����
lds r19,TempL_temp         ;���� ���.���
swap r19                   ;
andi r19,0x0F              ;���� �����.���
or temp,r19                ;�������� ���� �����������
sts TempH,temp             ;�������� �������
lds r19,TempL_temp         ;
andi r19,0x0F              ;
sts TempL,r19              ;� ��������
sbrs temp,7                ;�������� �� ���������
rjmp vstplus               ;���� +
com r19                    ;-------------
andi r19,0x0F              ;
com temp
ldi r20,1
add r19,r20
mov r20,r19
andi r19,0x0F
sts TempL,r19              ;�������� ����:)
swap r20
lsr r20
clr r20
adc temp,r20
sts TempH,temp             ;�������� 
ldi temp,0x2D              ;
sts symb,temp              ;
ret			               ;----------------------
vstplus:                   ;���������� ����
ldi temp,0x2B
sts symb,temp
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
vst_kom:

/*
ldi r23,0xBE       ;--------------------------
ldi r24,0xD4 
ldi r25,0x01       ;   50 ms
rcall delay1       ;--------------------------
*/
ldi kom_dan,0b00110000
ldi r22,0
rcall init_com
ldi r24,0xA0      ;--------------------------
ldi r25,0x3A      ;   5ms
rcall delay       ;--------------------------
ldi kom_dan,0b00110000
ldi r22,0
rcall init_com
ldi r24,0x59      ;--------------------------
ldi r25,0x02      ;   200�s
rcall delay       ;--------------------------
ldi kom_dan,0b00110000
ldi r22,0
rcall init_com
ldi r24,0x97      ;--------------------------
ldi r25,0x00      ;   50�s
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
;----------------------------------------------------------------------------------------

ret

maina:

rcall reset18b20    ;��������� ���� � ������
ldi dsW_R,0xCC      ;�������
rcall write_slot    ;ROM
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


/*
rcall hudred       ;��� ���
ldi kom_dan,0x2E   ;----------------------
ldi r22,1          ;������ ������
rcall ready_wait   ;----------------------
;rcall vst_thou     ;����������� ������
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
*/
/*
ldi r23,0x80        ;--------------------------
ldi r24,0x84 
ldi r25,0x1E        ;   50 ms
rcall delay1        ;--------------------------
*/
ret
; End Main =====================================================