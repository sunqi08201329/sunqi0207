.globl _start
.extern mymain
_start:
	ldr sp, =0x30f00000
	B mymain
	
	B .
	
