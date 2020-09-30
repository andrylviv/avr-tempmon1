
;Включаем заголовочный файл, на случай, если 
;в нем есть какие-либо необходимые определения
#include "asmdispsens.h"

;Экспортируем asm_func
.global vst_kom_a
.global vst_kom
.global Main
;.global asm_func
;и говорим, что где-то есть нужный нам символ global_var
; - наша глобальная переменная
;.extern global_var
.extern symb
.extern TempH
.extern TempL

/*
;Реализуем функцию
asm_func:

; С регистрами R30 - R31 можно делать что угодно, но это,
; по-совместительству, регистровая пара Z. Загружаем в 
; нее адрес глобальной переменной

    ldi R30,lo8(global_var)
    ldi R31,hi8(global_var)

; Добываем значение глобальной переменной в регистр R25,
; с которым тоже можно делать что угодно
    ldi r20,11
	sts global_var,r20
    ld R25,Z

; Складываем параметр, который лежит в R24,
; и значение глобальной переменной

    add R24,R25

; Все, больше ничего делать не надо, потому что 
; возвращаемое значение и должно лежать в R24, 
; выходим из подпрограммы
    ret
*/

ready_wait: 
                     
 ;---очікування готовності
 ldi temp,0b00000111 ;порт на
 out DDRD,temp       ; вхід
 in R16,PORTD        ;без
 ORI r16,0xF0        ;подтажки
 out PORTD,R16

 cbi PORTD,RS  ; RS 0
 sbi PORTD,RW  ; R/W 1
 nop
 sbi PORTD,E  ;E 1
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   17 µs                               upd12
 rcall delay       ;--------------------------
 in r19,PinD
 nop
 cbi PORTD,E  ;E 0
 nop
 sbi PORTD,E  ;E 1
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   17 µs                               upd12
 rcall delay       ;--------------------------
 in r20,PinD
 nop
 cbi PORTD,E  ;E 0
 ldi r24,0x07      ;--------------------------
 ldi r25,0x00      ;   3 µs                                upd12
 rcall delay       ;--------------------------
 sbrc r19,7
 rjmp ready_wait
 ;   початок відправки команди
 clr temp
 out PORTD,temp
 ldi temp,0b11110111 ;порт на
 out DDRD,temp 
 push kom_dan       ;стек ком_дан
 andi kom_dan,0xF0  ;і віддавили старшу тетр. байта (молодшу команди) 
 out PORTD,R22
 nop
 sbi PORTD,E       ;E 1
 in R22,PORTD      ;копіюєм порт d-
 andi r22,0x0F
 or R22,kom_dan    ;зростили RS,R/W,E і ст тетр. ком_дан
 out PORTD,R22     ;видали в порт
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   17 µs                                upd12
 rcall delay       ;--------------------------
 cbi PORTD,E      ;строб в 0
 nop
 nop
 ;передача другого півбайта
 in R16,PORTD     ;копіюєм порт d
 andi r16,0x0F    ;выддавили ст.тетр залиш RS,R/W,E 
 pop kom_dan          ;стек ком_дан
 swap kom_dan       
 andi kom_dan,0xF0    ;і віддавили старшу тетр. байта (старшу команди) 
 out PORTD,R16
 nop
 sbi PORTD,E         ;строб в 1
 in R16,PORTD     ;копіюєм порт d
 andi r16,0x0F
 or R16,kom_dan       ;зростили RS,R/W,E і ст тетр. ком_дан
 out PORTD,R16    ;відправили в порт 
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   17 µs                                 upd12
 rcall delay       ;--------------------------
 cbi PORTD,E         ;строб в 0
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   17 µs                                 upd12
 rcall delay       ;--------------------------
 ldi r16,0b00000011
 sbrc r22,1
 ldi r16,0b00000010
 out PORTD,R16
 ldi temp,0b00000111 ;порт на
 out DDRD,temp       ; вхід 
 ret

init_com:	        
 push temp
 in temp,SREG
 ;ком ініціалізації (мол тетрарда)
 ldi r24,(0<<RS)|(1<<E)
 out PORTD,r24
 or temp,r24
 out PORTD,temp
 ldi r24,(0<<RS)|(0<<E)
 out PORTD,r24
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   µs                               upd12
 rcall delay       ;--------------------------
 out SREG,temp
 pop temp
 ret

reset18b20:       ;імпульс скид і присутн
sbi DDRB,L
cbi PORTB,L
;ret
ldi r24,0x9E      ;--------------------------
ldi r25,0x05      ;   480µs                             upd12
rcall delay       ;--------------------------
cbi DDRB,L
cbi PORTB,L
ldi r24,0x2E      ;--------------------------
ldi r25,0x00      ;   15µs(16)                          upd12
rcall delay       ;----------------------
vair: sbic PinB,0
rjmp vair
ldi r24,0x9E      ;--------------------------
ldi r25,0x05      ;   480µs                             upd12
rcall delay       ;--------------------------
ret

 write_slot:       ;слот запису
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
ldi r25,0x00      ;   80µs                            upd12
sbi DDRB,L
cbi PORTB,L
rcall delay       ;--------------------------
cbi PORTB,L
cbi DDRB,L
;cbi PORTB,L
rjmp n_bit
wr_1_slot:
ldi r24,0x2E     ;--------------------------
ldi r25,0x00      ;   15µs                                 upd12
sbi DDRB,L
cbi PORTB,L
rcall delay       ;--------------------------
cbi DDRB,L
cbi PORTB,L
ldi r24,0xC4     ;--------------------------
ldi r25,0x00      ;   65µs                                 upd12
rcall delay       ;--------------------------
rjmp n_bit

;--------------------------------------------------------
read_slot:       ;слот читання
clr cou
ne_bit:
sbi DDRB,L
cbi PORTB,L       ;просадили лінію master
ldi r24,0x04      ;--------------------------
ldi r25,0x00      ;   1µs                                 upd12
rcall delay       ;--------------------------
cbi DDRB,L        ;відпускаєм
cbi PORTB,L       ;шину 
ldi r24,0x25      ;--------------------------
ldi r25,0x00      ;   12µs                                upd12
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
ldi r25,0x00      ;   45µs                                  upd12
rcall delay       ;--------------------------
rjmp ne_bit
ret

vpor:
lds temp,TempH ;вигр ст.темпер
swap temp      ;
andi temp,0xF0 ;віддавили хлам
lds r17,TempL  ;загр мол.тет
swap r17       ;
andi r17,0x0F  ;відав дробн.час
or temp,r17    ;зростили знач температури
sts TempH,temp ;зберегли старший
lds r17,TempL  ;
andi r17,0x0F  ;
sts TempL,r17  ;і молодший
sbrs temp,7    ;перевірка на мінусовість
rjmp vstplus   ;якщо +
com r17        ;-------------
andi r17,0x0F  ;
com temp
ldi r18,1
add r17,r18
mov r18,r17
andi r17,0x0F
sts TempL,r17  ;плюсовий мінус:)
swap r18
lsr r18
clr r18
adc temp,r18
sts TempH,temp ;зберегли 
ldi temp,0x2D  ;
sts symb,temp  ;
ret			   ;----------------------
vstplus:       ;встановили плюс
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
        mov kom_dan,display         ;відправка на
        ldi r22,1               ;дисплей
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
        mov kom_dan,display         ;відправка на
        ldi r22,1               ;дисплей
        rcall ready_wait        ;------------------------------                                 fhdfghfgghgh
		clr display
mov display,znach1; ones
        ori display,0x30     ;------------------------------
        mov kom_dan,display         ;відправка на
        ldi r22,1               ;дисплей
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
mul8_16:         ;множення 
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
        mov kom_dan,display         ;відправка на
        ldi r22,1               ;дисплей
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
        mov kom_dan,display         ;відправка на
        ldi r22,1               ;дисплей
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
        mov kom_dan,display     ;відправка на
        ldi r22,1               ;дисплей
        rcall ready_wait        ;------------------------------                                 fhdfghfgghgh
		clr display
        mov display,znach1      ; ones
        ori display,0x30        ;------------------------------
        mov kom_dan,display     ;відправка на
        ldi r22,1               ;дисплей
        rcall ready_wait        ;------------------------------                                 dhfdghfdgfgdg
		clr display
        clr znach1
		ret
;------------------------------
delay:
subi r24,1
sbci r25,0           ;затримка
brcc delay
ret
delay1:
subi r23,1
sbci r24,0           ;затримка
sbci r25,0
brcc delay1
ret
;------------------------------
vst_kom_a: 
/*push r0
push r1                                        ;початок  ---------------------------------------     
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
ldi r25,0x02      ;   200µs                                upd12
rcall delay       ;--------------------------
ldi kom_dan,0b00110000
ldi r22,0
rcall init_com
ldi r24,0x97      ;--------------------------
ldi r25,0x00      ;   50µs                                 upd12
rcall delay       ;--------------------------

;-----------------------------------------------------------------------------------------
ldi kom_dan,0x02  
ldi r22,0
rcall ready_wait     
ldi kom_dan,0x28
ldi r22,0
rcall ready_wait                                                 ;ініціалізація
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
;початок команди
ldi kom_dan,0x74    ;-------------
ldi r22,1           ;вст букву "t"
rcall ready_wait    ;-------------
ldi kom_dan,0x3D    ;-------------
ldi r22,1           ;вст знак "="
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
rcall reset18b20    ;процедура скид і готовн
ldi dsW_R,0xCC      ;пропуск
rcall write_slot    ;ROM
;Main:
ldi dsW_R,0x44      ;конверт
rcall write_slot    ;темп
rea_vait:sbis PinB,L;перевірка
rjmp rea_vait       ;готовності
rcall reset18b20   ;процедура скид і готовн
ldi dsW_R,0xCC     ;пропуск
rcall write_slot   ;ROM
ldi dsW_R,0xBE     ;читання
rcall write_slot   ;памяті
rcall read_slot    ;читаєм температуру
rcall reset18b20   ;процедура скид і готовн. тільки температуру)
ldi dsW_R,0xCC     ;пропуск
rcall write_slot   ;ROM
rcall vpor         ;розкидуєм по регістрах
lds kom_dan,symb   ;---------------------------------------------
ldi r22,1          ;встановлення знака
rcall ready_wait   ;----------------------------------------------
rcall hudred       ;вст цілі
ldi kom_dan,0x2E   ;----------------------
ldi r22,1          ;ставим крапку
rcall ready_wait   ;----------------------
rcall vst_thou     ;встановллємо тисячні
ldi kom_dan,0xDF   ;----------------------
ldi r22,1          ;знак "°" 
rcall ready_wait   ;----------------------
ldi kom_dan,0x43
ldi r22,1
rcall ready_wait
;ком вст курсора
ldi kom_dan,0x82    ;------------
ldi r22,0           ;відст 2 поз
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