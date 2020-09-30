
;Включаем заголовочный файл, на случай, если 
;в нем есть какие-либо необходимые определения
#include "asmdispsens.h"

;Экспортируем asm_func
;.global init
.global vst_kom
.global maina
.global ready_wait_for_c
;.global asm_func
;и говорим, что где-то есть нужный нам символ global_var
; - наша глобальная переменная
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
                     
 ;---очікування готовності
 ldi temp,0b00001011 ;порт на
 out DDRD,temp       ; вхід
 in temp,PORTD        ;без
 ORI temp,0xF0        ;подтажки
 out PORTD,temp

 cbi PORTD,RS  ; RS 0
 sbi PORTD,RW  ; R/W 1
 nop
 sbi PORTD,E  ;E 1
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   µs
 rcall delay       ;--------------------------
 in r19,PinD
 nop
 cbi PORTD,E  ;E 0
 nop
 sbi PORTD,E  ;E 1
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   µs
 rcall delay       ;--------------------------
 in r20,PinD
 nop
 cbi PORTD,E  ;E 0
 ldi r24,0x07      ;--------------------------
 ldi r25,0x00      ;   µs
 rcall delay       ;--------------------------
 sbrc r19,7
 rjmp ready_wait
 ;   початок відправки команди
 clr temp
 out PORTD,temp
 ldi temp,0b11111011 ;порт на
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
 ldi r25,0x00      ;   µs
 rcall delay       ;--------------------------
 cbi PORTD,E      ;строб в 0
 nop
 nop
 ;передача другого півбайта
 in temp,PORTD     ;копіюєм порт d
 andi temp,0x0F    ;выддавили ст.тетр залиш RS,R/W,E 
 pop kom_dan          ;стек ком_дан
 swap kom_dan       
 andi kom_dan,0xF0    ;і віддавили старшу тетр. байта (старшу команди) 
 out PORTD,temp
 nop
 sbi PORTD,E         ;строб в 1
 in temp,PORTD     ;копіюєм порт d
 andi temp,0x0F
 or temp,kom_dan       ;зростили RS,R/W,E і ст тетр. ком_дан
 out PORTD,temp    ;відправили в порт 
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   µs
 rcall delay       ;--------------------------
 cbi PORTD,E         ;строб в 0
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   µs
 rcall delay       ;--------------------------
 ldi temp,0b00000011
 sbrc r22,1
 ldi temp,0b00000010
 out PORTD,temp
 ldi temp,0b00001011 ;порт на
 out DDRD,temp       ; вхід 
 ldi temp,0x30
 sts display,temp
 ret

init_com:	        
 //push temp
 in temp,SREG
 ;ком ініціалізації (мол тетрарда)
 ldi r24,(0<<RS)|(1<<E)
 out PORTD,r24
 or temp,r24
 out PORTD,temp
 ldi r24,(0<<RS)|(0<<E)
 out PORTD,r24
 ldi r24,0x31      ;--------------------------
 ldi r25,0x00      ;   µs
 rcall delay 
 out SREG,temp
 //pop temp
 ret

reset18b20:       ;імпульс скид і присутн
sbi DDRB,L
cbi PORTB,L
;ret
ldi r24,0x9E      ;--------------------------
ldi r25,0x05      ;   480µs
rcall delay       ;--------------------------
cbi DDRB,L
cbi PORTB,L
ldi r24,0x2E      ;--------------------------
ldi r25,0x00      ;   15µs
rcall delay       ;----------------------
vair: sbic PinB,0
rjmp vair
ldi r24,0x9E      ;--------------------------
ldi r25,0x05      ;   480µs
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
ldi r25,0x00      ;   80µs
sbi DDRB,L
cbi PORTB,L
rcall delay       ;--------------------------
cbi PORTB,L
cbi DDRB,L
;cbi PORTB,L
rjmp n_bit
wr_1_slot:
ldi r24,0x2E     ;--------------------------
ldi r25,0x00      ;   15µs
sbi DDRB,L
cbi PORTB,L
rcall delay       ;--------------------------
cbi DDRB,L
cbi PORTB,L
ldi r24,0xC4     ;--------------------------
ldi r25,0x00      ;   65µs
rcall delay       ;--------------------------
rjmp n_bit

;--------------------------------------------------------
read_slot:       ;слот читання
clr cou
ne_bit:
sbi DDRB,L
cbi PORTB,L       ;просадили лінію master
ldi r24,0x04      ;--------------------------
ldi r25,0x00      ;   1µs
rcall delay       ;--------------------------
cbi DDRB,L        ;відпускаєм
cbi PORTB,L       ;шину 
ldi r24,0x25      ;--------------------------
ldi r25,0x00      ;   12µs
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
ldi r25,0x00      ;   45µs
rcall delay       ;--------------------------
rjmp ne_bit
ret

vpor:
lds temp,TempH_temp        ;вигр ст.темпер
swap temp                  ;
andi temp,0xF0             ;віддавили хлам
lds r19,TempL_temp         ;загр мол.тет
swap r19                   ;
andi r19,0x0F              ;відав дробн.час
or temp,r19                ;зростили знач температури
sts TempH,temp             ;зберегли старший
lds r19,TempL_temp         ;
andi r19,0x0F              ;
sts TempL,r19              ;і молодший
sbrs temp,7                ;перевірка на мінусовість
rjmp vstplus               ;якщо +
com r19                    ;-------------
andi r19,0x0F              ;
com temp
ldi r20,1
add r19,r20
mov r20,r19
andi r19,0x0F
sts TempL,r19              ;плюсовий мінус:)
swap r20
lsr r20
clr r20
adc temp,r20
sts TempH,temp             ;зберегли 
ldi temp,0x2D              ;
sts symb,temp              ;
ret			               ;----------------------
vstplus:                   ;встановили плюс
ldi temp,0x2B
sts symb,temp
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
ldi r25,0x02      ;   200µs
rcall delay       ;--------------------------
ldi kom_dan,0b00110000
ldi r22,0
rcall init_com
ldi r24,0x97      ;--------------------------
ldi r25,0x00      ;   50µs
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
;----------------------------------------------------------------------------------------

ret

maina:

rcall reset18b20    ;процедура скид і готовн
ldi dsW_R,0xCC      ;пропуск
rcall write_slot    ;ROM
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


/*
rcall hudred       ;вст цілі
ldi kom_dan,0x2E   ;----------------------
ldi r22,1          ;ставим крапку
rcall ready_wait   ;----------------------
;rcall vst_thou     ;встановллємо тисячні
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
*/
/*
ldi r23,0x80        ;--------------------------
ldi r24,0x84 
ldi r25,0x1E        ;   50 ms
rcall delay1        ;--------------------------
*/
ret
; End Main =====================================================