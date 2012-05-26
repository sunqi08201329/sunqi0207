.globl _start
.extern mymain
_start:
	B mymain
	#LDR R0,=0XE0200280	@set GPJ2CON
	#LDR R1,=0X1111
	#STR R1,[R0]
#led_test:
	#LDR R0,=0XE0200284	@set GPJ2DAT
	#LDR R1,=0XF
	#STR R1,[R0]

	#BL delay

	#LDR R0,=0XE0200284
	#LDR R1,=0X0
	#STR R1,[R0]
	
	#BL delay
	
	#B led_test

#delay:	
	#LDR R2,=0X5FFFFFF
#loop:
	#SUBS R2, R2, #0X1
	#BNE loop
	#MOV PC, LR
		
	
	B .
	
