/****************************************************************
* lab2_part1_2_3_JTAG.s
*
* Subroutines related to the display of a character on the terminal
* 
* input parameters: 
* r10 = ascii value of the character to be shown
****************************************************************/

.extern 	CONTADOR /* variable defined in the main program */

/**************************************************************** 
Subroutine: PRINT_JTAG
Displays on AMP JTAG terminal the contents of the external memory address COUNTER 
****************************************************************/ 			
.global PRINT_JTAG
PRINT_JTAG:
	
	subi  	sp, sp, 24		/* stack management */
	stw   	r2,  4(sp)
	stw   	r3,  8(sp)
	stw  	r4, 12(sp)
	stw  	r10, 16(sp)
	stw  	r17, 20(sp)
	stw   	ra, 24(sp)

	movia 	r3, TEXTO
	call 	ESCRIBE_TEXTO_JTAG	/* show on JTAG terminal a fixed text */

	movia 	r17, CONTADOR		/* base address of the Timer interval counter */
	ldw   	r4, 0(r17)
	call  	BCD			/* input: r4= binary value, output: r2= BCD value */

	call 	ESCRIBE_VALOR_JTAG	/* show on the JTAG terminal the BCD value */
	
	movia 	r3, TEXTO_FIN
	call 	ESCRIBE_TEXTO_JTAG	/* show on the JTAG terminal a fixed text */

	ldw   	r2,  4(sp)		/* stack management */
	ldw   	r3,  8(sp)
	ldw   	r4, 12(sp)
	ldw  	r10, 16(sp)
	ldw  	r17, 20(sp)
	ldw   	ra, 24(sp)
	addi  	sp, sp, 24

	ret

/****************************************************************
Subroutine: ESCRIBE_TEXTO_JTAG
Show a string of characters on the JTAG terminal
input parameter: r3, string pointer
****************************************************************/ 
.global ESCRIBE_TEXTO_JTAG
ESCRIBE_TEXTO_JTAG:
	subi  sp, sp, 12
	stw   r3,  4(sp)
	stw   r10, 8(sp)
	stw   ra, 12(sp)

BUC:
	ldb  	r10, 0(r3) 		/* loads one byte from the base address of the character string */
	beq  	r10, r0, CON 		/* if reads a 0, it means that r3 has reached the end of the chain and jumps out of the loop*/
	call 	ESCRIBIR_JTAG 		/* subroutine that shows the byte on the JTAG-UART terminal  */
	addi  	r3, r3, 1 		/* next byte */
	br   	BUC 			/* close the loop */
CON:
	ldw   	r3,  4(sp)
	ldw     r10,  8(sp)
	ldw   	ra, 12(sp)
	addi  	sp, sp, 12

	ret

/**************************************************************** 
Subroutine: ESCRIBE_VALOR_JTAG 
Show a BCD value on the JTAG terminal
input parameters: r2, BCD value
****************************************************************/ 
.global ESCRIBE_VALOR_JTAG
ESCRIBE_VALOR_JTAG:
	subi  	sp, sp, 16
	stw   	r2,  4(sp)
	stw   	r4,  8(sp)
	stw  	r10, 12(sp)
	stw   	ra, 16(sp)

	addi   	r4, r0, 8		/* 8 nibbles for the BCD value of the counter */
VALOR:	
	andhi 	r10, r2, 0xf000		/* extracts the 4 more significant bytes of the BCD value */
	srli  	r10, r10, 28		/* r10 is shifted 28 bits to the right */
	addi  	r10, r10, 0x30		/* add 0x30: BCD -> ASCII */ 
	call  	ESCRIBIR_JTAG		/* shows ASCII value */
	subi   	r4, r4, 1		/* counter of nibbles */
	slli   	r2, r2, 4		/* next nibble of BCD value */
	bne    	r4, r0, VALOR

	ldw   	r2,  4(sp)
	ldw   	r4,  8(sp)
	ldw  	r10, 12(sp)
	ldw   	ra, 16(sp)
	addi  	sp, sp, 16

	ret

.global ESCRIBIR_JTAG
ESCRIBIR_JTAG:
	subi	  sp, sp, 12		/* he used registers are saved in the stack */
	stw 	  r3,  4(sp)
	stw 	 r22,  8(sp)
	stw  	  ra, 12(sp)

	movia 	r22, 0x10001000 	/* base address of JTAG I/O controller */

otraVEZ:	
/* while loop: check if there is space to write */
	ldwio 	r3, 4(r22)		/* read register of JTAG-UART controller */
	andhi 	r3, r3, 0xffff  	/* selects the 16 more significative bits  */
	beq   	r3, r0, otraVEZ		/* WSPACE=0? */

WRT:	/* show the character on the terminal by writing in the JTAG-UART controller */
	stwio 	r10, 0(r22)
	
FIN:	ldw  	r3, 4(sp)		/* retrieve the registers from the stack and return */
	ldw	r22, 8(sp)
	ldw 	ra, 12(sp)
	addi 	sp, sp, 12

	ret

/*
* Data zone
*/
TEXTO:
.asciz 	"\n\nTime intervals that the program needs= "
TEXTO_FIN:
.asciz 	"\n\nEnd of the program "

.end 
