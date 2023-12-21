;Joc de lumini Brad de Craciun cu 20 de LED-uri
;2023, MPopa
;
;placa de dezvoltare folosita: PicKit1
;proiect realizat in MPLAB V8.92
;
;MCU: PIC12F675
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
;LED-urile sunt montate in configuratie Charliplexing, 
;Numarul maxim de LED-uri calculandu-se cu formula: 
;Nr LED = PIN_disponibil*(PIN_disponibili-1)
;De ex: PIN_disponibil = 5 (in cazul PIC12F675) => LED = 5*4=20
;
;
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
#define D01_ON	B'00000001'	    	; D01 LED
#define D02_ON	B'00000010'		    ; D02 LED
#define D03_ON	B'00000010'		    ; D03 LED
#define D04_ON	B'00000100'		    ; D04 LED
#define D05_ON	B'00000100'		    ; D05 LED
#define D06_ON	B'00010000'		    ; D06 LED
#define D07_ON	B'00010000'		    ; D07 LED
#define D08_ON	B'00100000'	 	    ; D08 LED
#define D09_ON	B'00000001'	 	    ; D09 LED
#define D10_ON	B'00000100'	 	    ; D10 LED
#define D11_ON	B'00000001'	 	    ; D11 LED
#define D12_ON	B'00010000'	 	    ; D12 LED
#define D13_ON	B'00000010'	 	    ; D13 LED
#define D14_ON	B'00010000'	 	    ; D14 LED
#define D15_ON	B'00000010'	 	    ; D15 LED
#define D16_ON	B'00100000'	 	    ; D16 LED
#define D17_ON	B'00000001'	 	    ; D17 LED
#define D18_ON	B'00100000'	 	    ; D18 LED
#define D19_ON	B'00000100'	 	    ; D19 LED
#define D20_ON	B'00100000'	 	    ; D20 LED
#define LED_OFF	B'00000000'		    ; LED Off


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


bucla
;pwm de 3 trei ori led_01, cel din stea:
   	call Delay_100ms
    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_01	;bucla PWM
    MOVLW 0x0   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_01	;bucla PWM
	call Delay_500ms
    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_01	;bucla PWM
    MOVLW 0x0   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_01	;bucla PWM
	call Delay_500ms
    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_01	;bucla PWM
    MOVLW 0x0   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_01	;bucla PWM
; aprinde toate led-uri aleator:
	call Delay_500ms
	call led_01_to_01
	call led_01_to_02
	call led_01_to_08
	call led_01_to_04
	call led_01_to_10
	call led_01_to_06
	call led_01_to_12
	call led_01_to_05
	call led_01_to_11
	call led_01_to_03
	call led_01_to_09
	call led_01_to_07
	call led_01_to_19
	call led_01_to_18
	call led_01_to_13
	call led_01_to_15
	call led_01_to_14
	call led_01_to_16
	call led_01_to_17
	call led_01_to_20
	call Led_off
	call Delay_500ms
	call Delay_500ms
;aprinde 5 led-uri, pwm, pe rand:
	call led_uri_pwm_random
;aprinde cate un led din cele 20, aleator, de trei ori:
	call Bucla_random
	call Bucla_random
	call Bucla_random
;aprinde 5 led-uri, pwm, pe rand:
	call led_uri_pwm_random
; aprinde toate led-uri aleator:
	call led_01_to_20
	call led_01_to_17
	call led_01_to_16
	call led_01_to_14
	call led_01_to_15
	call led_01_to_13
	call led_01_to_18
	call led_01_to_19
	call led_01_to_07
	call led_01_to_09
	call led_01_to_03
	call led_01_to_11
	call led_01_to_05
	call led_01_to_12
	call led_01_to_06
	call led_01_to_10
	call led_01_to_04
	call led_01_to_08
	call led_01_to_02
	call led_01_to_01
	call Led_off
	call Delay_500ms
	call Delay_500ms
;aprinde cate un led din cele 20, aleator, de trei ori:
	call Bucla_random
	call Bucla_random
	call Bucla_random
;du-te la incepurul programului
	goto bucla

led_uri_pwm_random

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_03	;bucla PWM
    MOVLW 0x0   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_03	;bucla PWM

	call Delay_500ms

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_10	;bucla PWM
    MOVLW 0x0   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_10	;bucla PWM

	call Delay_500ms

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_01	;bucla PWM
    MOVLW 0x0   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_01	;bucla PWM

	call Delay_500ms

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_16	;bucla PWM
    MOVLW 0x0   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_16	;bucla PWM

	call Delay_500ms

    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_07	;bucla PWM
    MOVLW 0x0   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
    MOVWF dir   	     	;set PWM up or down
	call LOOP_PWM_led_07	;bucla PWM

	call Delay_500ms

	return

led_01_to_01
	call executa_bucla
led_01_to_01_bucla
	call	Led_01	
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_01_bucla
	return

led_01_to_02
	call executa_bucla
led_01_to_02_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_02_bucla
	return

led_01_to_08
	call executa_bucla
led_01_to_08_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_08_bucla
	return

led_01_to_04
	call executa_bucla
led_01_to_04_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_04_bucla
	return

led_01_to_10
	call executa_bucla
led_01_to_10_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_10_bucla
	return

led_01_to_06
	call executa_bucla
led_01_to_06_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_06_bucla
	return

led_01_to_12
	call executa_bucla
led_01_to_12_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_12_bucla
	return

led_01_to_05
	call executa_bucla
led_01_to_05_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_05_bucla
	return

led_01_to_11
	call executa_bucla
led_01_to_11_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	call	Led_11
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_11_bucla
	return

led_01_to_03
	call executa_bucla
led_01_to_03_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	call	Led_11
	call	Delay_1ms
	call	Led_03
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_03_bucla
	return

led_01_to_09
	call executa_bucla
led_01_to_09_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	call	Led_11
	call	Delay_1ms
	call	Led_03
	call	Delay_1ms
	call	Led_09
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_09_bucla
	return

led_01_to_07
	call executa_bucla
led_01_to_07_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	call	Led_11
	call	Delay_1ms
	call	Led_03
	call	Delay_1ms
	call	Led_09
	call	Delay_1ms
	call	Led_07
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_07_bucla
	return

led_01_to_19
	call executa_bucla
led_01_to_19_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	call	Led_11
	call	Delay_1ms
	call	Led_03
	call	Delay_1ms
	call	Led_09
	call	Delay_1ms
	call	Led_07
	call	Delay_1ms
	call	Led_19
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_19_bucla
	return

led_01_to_18
	call executa_bucla
led_01_to_18_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	call	Led_11
	call	Delay_1ms
	call	Led_03
	call	Delay_1ms
	call	Led_09
	call	Delay_1ms
	call	Led_07
	call	Delay_1ms
	call	Led_19
	call	Delay_1ms
	call	Led_18
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_18_bucla
	return

led_01_to_13
	call executa_bucla
led_01_to_13_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	call	Led_11
	call	Delay_1ms
	call	Led_03
	call	Delay_1ms
	call	Led_09
	call	Delay_1ms
	call	Led_07
	call	Delay_1ms
	call	Led_19
	call	Delay_1ms
	call	Led_18
	call	Delay_1ms
	call	Led_13
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_13_bucla
	return

led_01_to_15
	call executa_bucla
led_01_to_15_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	call	Led_11
	call	Delay_1ms
	call	Led_03
	call	Delay_1ms
	call	Led_09
	call	Delay_1ms
	call	Led_07
	call	Delay_1ms
	call	Led_19
	call	Delay_1ms
	call	Led_18
	call	Delay_1ms
	call	Led_13
	call	Delay_1ms
	call	Led_15
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_15_bucla
	return


led_01_to_14
	call executa_bucla
led_01_to_14_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	call	Led_11
	call	Delay_1ms
	call	Led_03
	call	Delay_1ms
	call	Led_09
	call	Delay_1ms
	call	Led_07
	call	Delay_1ms
	call	Led_19
	call	Delay_1ms
	call	Led_18
	call	Delay_1ms
	call	Led_13
	call	Delay_1ms
	call	Led_15
	call	Delay_1ms
	call	Led_14
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_14_bucla
	return

led_01_to_16
	call executa_bucla
led_01_to_16_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	call	Led_11
	call	Delay_1ms
	call	Led_03
	call	Delay_1ms
	call	Led_09
	call	Delay_1ms
	call	Led_07
	call	Delay_1ms
	call	Led_19
	call	Delay_1ms
	call	Led_18
	call	Delay_1ms
	call	Led_13
	call	Delay_1ms
	call	Led_15
	call	Delay_1ms
	call	Led_14
	call	Delay_1ms
	call	Led_16
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_16_bucla
	return

led_01_to_17
	call executa_bucla
led_01_to_17_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	call	Led_11
	call	Delay_1ms
	call	Led_03
	call	Delay_1ms
	call	Led_09
	call	Delay_1ms
	call	Led_07
	call	Delay_1ms
	call	Led_19
	call	Delay_1ms
	call	Led_18
	call	Delay_1ms
	call	Led_13
	call	Delay_1ms
	call	Led_15
	call	Delay_1ms
	call	Led_14
	call	Delay_1ms
	call	Led_16
	call	Delay_1ms
	call	Led_17
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_17_bucla
	return

led_01_to_20
	call executa_bucla
led_01_to_20_bucla
	call	Led_01	
	call	Delay_1ms
	call	Led_02
	call	Delay_1ms
	call	Led_08
	call	Delay_1ms
	call	Led_04
	call	Delay_1ms
	call	Led_10
	call	Delay_1ms
	call	Led_06
	call	Delay_1ms
	call	Led_12
	call	Delay_1ms
	call	Led_05
	call	Delay_1ms
	call	Led_11
	call	Delay_1ms
	call	Led_03
	call	Delay_1ms
	call	Led_09
	call	Delay_1ms
	call	Led_07
	call	Delay_1ms
	call	Led_19
	call	Delay_1ms
	call	Led_18
	call	Delay_1ms
	call	Led_13
	call	Delay_1ms
	call	Led_15
	call	Delay_1ms
	call	Led_14
	call	Delay_1ms
	call	Led_16
	call	Delay_1ms
	call	Led_17
	call	Delay_1ms
	call	Led_20
	call	Delay_1ms
	decfsz	aa,f			;executa bucla de "aa" ori
	goto	led_01_to_20_bucla
	return


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

	call Led_20
	call Delay_100ms

	call Led_17
	call Delay_100ms	


executa_bucla
	movlw	D'100' ;0xC6	;de aici se seteaza viteza "de curgere"
	movwf	aa
	return

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

;=====Bucla PWM Led 01
LOOP_PWM_led_01
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_01			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
INT_LOOP_led_01   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
	call Led_off			;led OFF
    CALL DELAY_led   	;and call the DELAY subroutine
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
	return
SET_DIR_led_01   			 
    BSF dir, 0   		               
	return 

;=====Bucla PWM Led 03
LOOP_PWM_led_03
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_03			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
INT_LOOP_led_03   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
	call Led_off			;led OFF
    CALL DELAY_led      	;and call the DELAY subroutine
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
	return
SET_DIR_led_03   			 
    BSF dir, 0   		               
	return 

;=====Bucla PWM Led 10
LOOP_PWM_led_10
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_10			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
INT_LOOP_led_10   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
	call Led_off			;led OFF
    CALL DELAY_led   	;and call the DELAY subroutine
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
	return
SET_DIR_led_10   			 
    BSF dir, 0   		               
	return 

;=====Bucla PWM Led 16
LOOP_PWM_led_16
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_16			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
INT_LOOP_led_16   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
	call Led_off			;led OFF
    CALL DELAY_led   	;and call the DELAY subroutine
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
	return
SET_DIR_led_16   			 
    BSF dir, 0   		               
	return 

;=====Bucla PWM Led 07
LOOP_PWM_led_07
;    MOVLW 0x1   		 	;1 = PWM 0 -> max; 0 = PWM max -> 0
;    MOVWF dir   	     	;set PWM up or down		
	call Led_07			 	;led ON
    MOVLW 0xFF   		 	;Set the initial value of i
    MOVWF i   			 	;as 0xFF
INT_LOOP_led_07   			;Beginning of the internal PWM loop
    MOVF limit, W   	 	;Copy the PWM limit value of the W register
    SUBWF i, W   		 	;Subtract the W from i
    BTFSS STATUS, Z   	 	;If the result is not 0
    GOTO $ + 2   		 	;then go to the line 22
	call Led_off			;led OFF
    CALL DELAY_led      	;and call the DELAY subroutine
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
	return
SET_DIR_led_07 			 
    BSF dir, 0   		               
	return

;==========Bucle pentru Delay:
;=====Bucla folosita pentru PWM
DELAY_led   			 	;Start DELAY subroutine here
    MOVLW 5;10   		 	;Load initial value for the delay    
    MOVWF j   			 	;Copy the value to j
DELAY_LOOP_led   		;Start delay loop
    decfsz j, f   		 	;Decrement j and check if it is not zero
    goto DELAY_LOOP_led  ;If not, then go to the DELAY_LOOP label
	return                  ;Else return from the subroutine

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