;Joc de lumini Brad de Craciun cu 20 de LED-uri
;2023, MPopa
;
;placa de dezvolatre folosita: PicKit1
;proiect realizat in MPLAB V8.92
;
;internal OSC = 4MHz --> o instructiune este executata la Fosc/4 = 1MHz
;timpul de executie este t=1/1000000=1us (o micro secunda)
;pentru un delay de 100us:
;delay = C (o constanta) * 1us
;pentru PWM in asm, urmeaza exemplele din linkul acesta:
;https://www.circuitbread.com/tutorials/pwm-led-dimming-part-7-microcontroller-basics-pic10f200
;https://www.circuitbread.com/tutorials/musical-microcontroller-part-8-microcontroller-basics-pic10f200
;
;pentru creeat delay SW, foloseste aceasta aplicatie:
;https://www.golovchenko.org/home/delay_loops
;
;
;
;===== Program brad versiunea 1:
;===== incepe cu PWM up led_01
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_02
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_08 
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_04
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_10
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_06
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_12
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_05
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_11 
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_03
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_09
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_07
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_19 
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_18
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_13
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_15
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_14
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_16
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_17
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== apoi PWM up led_20
;===== urmeaza secventa de aprindere pseudo-aleatoare a tuturor led-urilor
;===== de la capat
;
;secventa preudo aleatorie: led 1,2,8,4,10,6,12,5,11,3,9,7,19,18,13,15,14,16,17,20 cu pauza de 100ms intre ele
;

	list      p=12F675	; list directive to define processor
	#include <p12f675.inc>	; processor specific variable definitions

	__CONFIG  _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _INTRC_OSC_NOCLKOUT & _MCLRE_OFF & _CPD_OFF
  
;	errorlevel -302		;desable warning regarding to bank bits memory

;===variabile folosite in bucla PWM si in buclele pentru Delay:
	 cblock 0x20	
	c1
	c2
	d1
	d2
	d3
	aa
	i	
	limit
	j
	dir
	 endc

#define	var1	20h

;*************************** DEFINE STATEMENTS ********************************

; define input/output designation for LEDs (what TRISIO will equal)
#define TRIS_D01_D02	B'00111100'	; TRISIO setting for D01 and D02
#define TRIS_D03_D04	B'00111001'	; TRISIO setting for D03 and D04
#define TRIS_D05_D06	B'00101011'	; TRISIO setting for D05 and D06
#define TRIS_D07_D08	B'00001111'	; TRISIO setting for D07 and D08
#define TRIS_D09_D10	B'00111010'	; TRISIO setting for D09 and D10
#define TRIS_D11_D12	B'00101110'	; TRISIO setting for D11 and D12
#define TRIS_D13_D14	B'00101101'	; TRISIO setting for D13 and D14
#define TRIS_D15_D16	B'00011101'	; TRISIO setting for D15 and D16
#define TRIS_D17_D18	B'00011110'	; TRISIO setting for D17 and D18
#define TRIS_D19_D20	B'00011011'	; TRISIO setting for D19 and D20
#define TRIS_ALL_OUTPUT B'00111111' ; TRISIO settings for all outputs

; define LED state (what GPIO will equal)
#define D01_ON	B'00000001'		; D01 LED
#define D02_ON	B'00000010'		; D02 LED
#define D03_ON	B'00000010'		; D03 LED
#define D04_ON	B'00000100'		; D04 LED
#define D05_ON	B'00000100'		; D05 LED
#define D06_ON	B'00010000'		; D06 LED
#define D07_ON	B'00010000'		; D07 LED
#define D08_ON	B'00100000'	 	; D08 LED
#define D09_ON	B'00000001'	 	; D09 LED
#define D10_ON	B'00000100'	 	; D10 LED
#define D11_ON	B'00000001'	 	; D11 LED
#define D12_ON	B'00010000'	 	; D12 LED
#define D13_ON	B'00000010'	 	; D13 LED
#define D14_ON	B'00010000'	 	; D14 LED
#define D15_ON	B'00000010'	 	; D15 LED
#define D16_ON	B'00100000'	 	; D16 LED
#define D17_ON	B'00000001'	 	; D17 LED
#define D18_ON	B'00100000'	 	; D18 LED
#define D19_ON	B'00000100'	 	; D19 LED
#define D20_ON	B'00100000'	 	; D20 LED
#define LED_OFF	B'00000000'		; LED Off


;****************************** Start of Program ******************************
	org     0x000		; processor reset vector
 	goto Initialize
;******************************************************************************

;	Initialize Special Function Registers     
;******************************************************************************


;	org 0x0002a0		; Start of Programm Memory Vector
Initialize
;	Set oscilator:
	bsf		STATUS,RP0		; Bank 1
	movwf 	OSCCAL			; update register with factory cal
	bsf     STATUS,RP0		; Bank 1 

;	Initializare port GPIO:
	bcf STATUS, RP0			; Bank 0
	clrf GPIO				; Init GPIO
	movlw 07H				; Set GP<2:0> to
	movwf CMCON				; digital IO
	bsf STATUS, RP0			; Bank 1
	clrf ANSEL				; Digital I/O

	movlw	B'00111111'		; Set all I/O pins as inputs
	movwf	TRISIO			; SET TRISIO register

;	Initializare variabile:
	clrf limit				; Clear the PWM limit
	clrf dir				; Clear the direction

;	Setare pentru intrerupere:
;******************************************************************************
	bsf STATUS, RP0			; Bank 1
;	movlw	B'00001000'		; Set interrupt on change at pin GP3
	movlw 	B'00000000'		; Clear interupt on change at pin GP3 
	movwf	IOC				; Set IOC register


;	movlw	B'10001000'		; Set interrupts at GPIO port change
	movlw	B'00000000'		; Clear interrupts 
	movwf	INTCON			; Set INCON register

;******************************************************************************
;******************************** Start Program *******************************
;******************************************************************************

;==========Incercare de randomizare
;Random startup:
;	call 3ffh
                
;	subwf var1,F            ;randomizare start-up
;	swapf var1,F
;	comf var1,F
;	addwf var1,W
;	rrf var1,F
;	rrf var1,F
;	addwf var1,F
;	movlw 11111b
;	andwf var1,F
;	goto pauza

;=====Bucla pentru pauza randomizare
;pauza           
;	bsf STATUS,DC
;	btfsc STATUS,DC
;	goto $-1

;	decfsz var1
;	goto pauza
                
;	goto bucla
;==========Incercare de randomizare

bucla

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_01	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_02	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_08	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_04	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_10	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_06	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_12	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_05	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_11	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_03	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_09	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_07	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_19	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_18	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_13	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_15	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_14	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_16	;bucla PWM
	call Delay_500ms

	call Bucla_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_17	;bucla PWM
	call Delay_500ms

	call Bucla_random

	MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
	MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_20 	;bucla PWM
	call Delay_500ms

	call Bucla_random

	goto bucla

Bucla_random
	call Led_01
	call Delay_100ms

	call Led_02
	call Delay_100ms

	call Led_08
	call Delay_100ms

	call Led_04
	call Delay_100ms

	call Led_10
	call Delay_100ms

	call Led_06
	call Delay_100ms

	call Led_12
	call Delay_100ms

	call Led_05
	call Delay_100ms

	call Led_11
	call Delay_100ms

	call Led_03
	call Delay_100ms

	call Led_09
	call Delay_100ms

	call Led_07
	call Delay_100ms	

	call Led_19
	call Delay_100ms

	call Led_18
	call Delay_100ms

	call Led_13
	call Delay_100ms

	call Led_15
	call Delay_100ms

	call Led_14
	call Delay_100ms

	call Led_16
	call Delay_100ms

	call Led_17
	call Delay_100ms

	call Led_20
	call Delay_100ms	


Led_off
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_ALL_OUTPUT	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	LED_OFF			; move predefined value to GPIO
	movwf	GPIO
	return

Led_01
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D01_D02	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D01_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_02
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D01_D02	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D02_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_03
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D03_D04	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D03_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_04
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D03_D04	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D04_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_05
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D05_D06	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D05_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_06
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D05_D06	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D06_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_07
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D07_D08	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D07_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_08
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D07_D08	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D08_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_09
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D09_D10	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D09_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_10
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D09_D10	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D10_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_11
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D11_D12	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D11_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_12
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D11_D12	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D12_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_13
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D13_D14	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D13_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_14
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D13_D14	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D14_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_15
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D15_D16	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D15_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_16
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D15_D16	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D16_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_17
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D17_D18	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D17_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_18
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D17_D18	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D18_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_19
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D19_D20	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D19_ON			; move predefined value to GPIO
	movwf	GPIO
	return

Led_20
	bsf		STATUS, RP0		; Bank 1
	movlw	TRIS_D19_D20	; move predefined value to TRISIO
	movwf	TRISIO
	bcf		STATUS, RP0		; Bank 0
	movlw	D20_ON			; move predefined value to GPIO
	movwf	GPIO
	return




;==========Bucla PWM up si down!!!
;==========Bucla PWM Led 01 - primul led

LOOP_PWM_led_01
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_01			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_01   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_01   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_01    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_01
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_01   		 
    GOTO TOGGLE_DIR_led_01   	 
DEC_BRIGHTNESS_led_01   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_01   		 
TOGGLE_DIR_led_01   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_01   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_01   		 
	return
SET_DIR_led_01   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_01   
	return 

DELAY_led_01   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_01   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_01  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 02 - al doilea led

LOOP_PWM_led_02
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_02			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_02   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_02   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_02    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_02
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_02   		 
    GOTO TOGGLE_DIR_led_02   	 
DEC_BRIGHTNESS_led_02  	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_02   		 
TOGGLE_DIR_led_02   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_02   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_02   		 
	return
SET_DIR_led_02   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_02   
	return 

DELAY_led_02   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_02   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_02  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 03 - al treilea led

LOOP_PWM_led_03
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_03			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_03   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_03   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_03    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_03
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_03   		 
    GOTO TOGGLE_DIR_led_03   	 
DEC_BRIGHTNESS_led_03   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_03   		 
TOGGLE_DIR_led_03   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_03   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_03   		 
	return
SET_DIR_led_03   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_03   
	return 

DELAY_led_03   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_03   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_03  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 04 - al patrulea led

LOOP_PWM_led_04
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_04			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_04   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_04   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_04    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_04
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_04   		 
    GOTO TOGGLE_DIR_led_04   	 
DEC_BRIGHTNESS_led_04   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_04   		 
TOGGLE_DIR_led_04   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_04   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_04   		 
	return
SET_DIR_led_04   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_04   
	return 

DELAY_led_04   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_04   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_04  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 05 - al cincilea led

LOOP_PWM_led_05
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_05			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_05   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP5   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_05   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_05    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_05
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_05   		 
    GOTO TOGGLE_DIR_led_05   	 
DEC_BRIGHTNESS_led_05   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_05   		 
TOGGLE_DIR_led_05   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_05   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_05   		 
	return
SET_DIR_led_05   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_05   
	return 

DELAY_led_05   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_05   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_05  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 06 - al saselea led

LOOP_PWM_led_06
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_06			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_06   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_06   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_06    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_06
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_06   		 
    GOTO TOGGLE_DIR_led_06   	 
DEC_BRIGHTNESS_led_06   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_06   		 
TOGGLE_DIR_led_06   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_06   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_06   		 
	return
SET_DIR_led_06   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_06   
	return 

DELAY_led_06   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_06   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_06  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 07 - al saaptelea led

LOOP_PWM_led_07
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_07			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_07   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_06   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_07    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_07
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_07   		 
    GOTO TOGGLE_DIR_led_07   	 
DEC_BRIGHTNESS_led_07   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_07   		 
TOGGLE_DIR_led_07   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_07   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_07   		 
	return
SET_DIR_led_07   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_07   
	return 

DELAY_led_07   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_07   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_07  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 08 - al optulea led

LOOP_PWM_led_08
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_08			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_08   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_08   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_08    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_08
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_08   		 
    GOTO TOGGLE_DIR_led_08   	 
DEC_BRIGHTNESS_led_08   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_08   		 
TOGGLE_DIR_led_08   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_08   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_08   		 
	return
SET_DIR_led_08   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_08   
	return 

DELAY_led_08   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_08   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_08  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return


;==========Bucla PWM Led 09 - al noualea led

LOOP_PWM_led_09
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_09			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_09   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_09   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_09    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_09
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_09   		 
    GOTO TOGGLE_DIR_led_09   	 
DEC_BRIGHTNESS_led_09   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_09   		 
TOGGLE_DIR_led_09   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_09   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_09   		 
	return
SET_DIR_led_09   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_09   
	return 

DELAY_led_09   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_09   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_09  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return


;==========Bucla PWM Led 10 - al zecelea led

LOOP_PWM_led_10
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_10			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_10   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_10   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_10    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_10
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_10   		 
    GOTO TOGGLE_DIR_led_10   	 
DEC_BRIGHTNESS_led_10   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_10   		 
TOGGLE_DIR_led_10   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_10   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_10   		 
	return
SET_DIR_led_10   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_10   
	return 

DELAY_led_10   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_10   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_10  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 011 - al unsprezecelea led

LOOP_PWM_led_11
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_11			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_11   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_11   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_11    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_11
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_11   		 
    GOTO TOGGLE_DIR_led_11   	 
DEC_BRIGHTNESS_led_11   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_11   		 
TOGGLE_DIR_led_11   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_11   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_11   		 
	return
SET_DIR_led_11   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_11   
	return 

DELAY_led_11   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_11   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_11  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 12 - al doisprezecelea led

LOOP_PWM_led_12
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_12			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_12   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_12   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_12    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_12
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_12   		 
    GOTO TOGGLE_DIR_led_12   	 
DEC_BRIGHTNESS_led_12   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_12   		 
TOGGLE_DIR_led_12   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_12   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_12   		 
	return
SET_DIR_led_12   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_12   
	return 

DELAY_led_12   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_12   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_12  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 13 - al treisprezecelea led

LOOP_PWM_led_13
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_13			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_13   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_13   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_13    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_13
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_13   		 
    GOTO TOGGLE_DIR_led_13   	 
DEC_BRIGHTNESS_led_13   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_13   		 
TOGGLE_DIR_led_13   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_13   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_13   		 
	return
SET_DIR_led_13   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_13   
	return 

DELAY_led_13   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_13   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_13  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 14 - al paisprezecelea led

LOOP_PWM_led_14
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_14			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_14   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_14   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_14    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_14
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_14   		 
    GOTO TOGGLE_DIR_led_14   	 
DEC_BRIGHTNESS_led_14   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_14   		 
TOGGLE_DIR_led_14   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_14   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_14   		 
	return
SET_DIR_led_14  			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_14   
	return 

DELAY_led_14   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_14   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_14  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 15 - al cincisprezecelea led

LOOP_PWM_led_15
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_15			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_15   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_15   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_15    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_15
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_15   		 
    GOTO TOGGLE_DIR_led_15   	 
DEC_BRIGHTNESS_led_15   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_15   		 
TOGGLE_DIR_led_15   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_15   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_15   		 
	return
SET_DIR_led_15   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_15   
	return 

DELAY_led_15   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_15   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_15  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 16 - al saisprezecelea led

LOOP_PWM_led_16
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_16			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_16   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_16   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_16    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_16
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_16   		 
    GOTO TOGGLE_DIR_led_16   	 
DEC_BRIGHTNESS_led_16   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_16   		 
TOGGLE_DIR_led_16   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_16  	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_16   		 
	return
SET_DIR_led_16   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_16   
	return 

DELAY_led_16   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_16   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_16  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 17 - al saptisprezecelea led

LOOP_PWM_led_17
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_17			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_17   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_17   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_17    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_17
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_17   		 
    GOTO TOGGLE_DIR_led_17   	 
DEC_BRIGHTNESS_led_17   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_17   		 
TOGGLE_DIR_led_17   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_17   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_17   		 
	return
SET_DIR_led_17   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_17   
	return 

DELAY_led_17   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_17   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_17  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 18 - al optisprezecelea led

LOOP_PWM_led_18
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_18			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_18   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_18   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_18    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_18
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_18   		 
    GOTO TOGGLE_DIR_led_18   	 
DEC_BRIGHTNESS_led_18   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_18   		 
TOGGLE_DIR_led_18   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_18   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_218  		 
	return
SET_DIR_led_18   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_18   
	return 

DELAY_led_18   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_18   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_18  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 19 - al nouasprezecelea led

LOOP_PWM_led_19
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_10			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_19   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_19   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_19    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_19
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_19   		 
    GOTO TOGGLE_DIR_led_19   	 
DEC_BRIGHTNESS_led_19   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_19  		 
TOGGLE_DIR_led_19  		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_19   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_19   		 
	return
SET_DIR_led_19   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_19   
	return 

DELAY_led_19   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_19   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_19  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return

;==========Bucla PWM Led 20 - al douazecelea led

LOOP_PWM_led_20
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_20			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
;    BSF GPIO, GP1      	;Set GP1 pin
INT_LOOP_led_20   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
;    BCF GPIO, GP1   	 	;else reset the GP1 pin
	call Led_off			;led OFF
    CALL DELAY_led_20   	;and call the DELAY subroutine
    DECFSZ i, F   		 	;Decrement the i, and check if the result is 0
    GOTO INT_LOOP_led_20    ;If not, return to the internal PWM loop start
    BTFSS dir, 0   	             
    GOTO DEC_BRIGHTNESS_led_20
    DECFSZ limit, F  	             
    GOTO LOOP_PWM_led_20   		 
    GOTO TOGGLE_DIR_led_20   	 
DEC_BRIGHTNESS_led_20   	 
    INCF limit, F  	             
    MOVLW 0xFF   		 
    SUBWF limit, W   	             
    BTFSS STATUS, Z   	 
    GOTO LOOP_PWM_led_20   		 
TOGGLE_DIR_led_20   		 
    BTFSS dir, 0   	             
    GOTO SET_DIR_led_20   	             
    BCF dir, 0   		             
;    GOTO LOOP_PWM_led_20   		 
	return
SET_DIR_led_20   			 
    BSF dir, 0   		             
;    GOTO LOOP_PWM_led_20   
	return 

DELAY_led_20   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led_20   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led_20  ;If not, then go to the DELAY_LOOP label
;    RETLW 0   			 	;Else return from the subroutine
	return





;==========Bucle pentru Delay:
;=====Bucla calculata 1ms
Delay_1ms ;993 cycles		
	movlw	0xC6
	movwf	d1
	movlw	0x01
	movwf	d2
Delay_001
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	Delay_001
			;3 cycles
	goto	$+1
	nop
			;4 cycles (including call)
	return

;=====Bucla calculata 10ms
Delay_10ms ;9993 cycles			
	movlw	0xCE
	movwf	d1
	movlw	0x08
	movwf	d2
Delay_010
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	Delay_010
			;3 cycles
	goto	$+1
	nop
			;4 cycles (including call)
	return

;=====Bucla calculata 100ms
Delay_100ms ;99993 cycles			
	movlw	0x1E
	movwf	d1
	movlw	0x4F
	movwf	d2
Delay_0100
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	Delay_0100
			;3 cycles
	goto	$+1
	nop
			;4 cycles (including call)
	return

;=====Bucla calculata 500ms
Delay_500ms ;499994 cycles			
	movlw	0x03
	movwf	d1
	movlw	0x18
	movwf	d2
	movlw	0x02
	movwf	d3
Delay_0500
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	$+2
	decfsz	d3, f
	goto	Delay_0500
			;2 cycles
	goto	$+1
			;4 cycles (including call)
	return

	END