/********************************************************************************
* lab2_part1_2_3_main.s
*
* Main program for Nios II-based Lab Assignment 2 of Computer Architecture course
* Initialize the Timer system 
* Initialize and activate the interrupt system of the Nios II processor
* Execute a loop that calls Fibonacci routine and show the number of 33-ms. intervals
*
* Subroutines: PRINT_JTAG (lab2_part1_2_3_JTAG.s), FIBONACCI (lab2_part1_2_3_fibo.s)
*
********************************************************************************/
.equ ITERACIONES, 500000
.text /* the executable code starts */
.global _start

_start:
	/* the stack pointer is initialized */
	movia sp,  0x007FFFFC 	/* stack starts in last memory position of SDRAM */
	movia r16, 0x10002000 	/* base address of the internal Timer system */

	/* the time of the interval in which the timer generates an interrupt for performance analysis is started */
	movia r12, 0x190000 	/* 1/(50 MHz) x (0x190000) = 33 ms. */
	sthio r12, 8(r16) 	/* saves the half of the word from the initial value of timer */
	srli  r12, r12, 16 	/* shifts the 16 bits value to the right */
	sthio r12, 0xC(r16) 	/* saves the top half word for the initial value of timer */

	/* the Timer is initialized, enabling its interrupts */
	movi  r15, 0b0111 	/* START = 1, CONT = 1, ITO = 1 */
	sthio r15, 4(r16)

	/* Nios II processor interrupt is enabled */
	movi  r7, 0b011 	/* the interrupt bit mask is initialized for level 0 (Timer) and level 1 (pushbuttons) */
	wrctl ienable, r7 	
	movi  r7, 1
	wrctl status, r7 	/* Nios II interrupts are activated */

	movia r14, ITERACIONES 	/* initializes the Fibonacci iteration counter */
	addi  r17, r0, 0 	/* initializes the interval counter of the program "r17" */

LOOP:	beq   r14, r0, END 	/* the Fibonacci loop is executed */
	call  FIBONACCI
	addi  r14, r14, -1
	br    LOOP

END:	movi  r7, 0
	wrctl status, r7 	/* interrupt processing is disabled in Nios II */

	call PRINT_JTAG 	/* the number of 33-ms. intervals is displayed on the AMP terminal */

IDLE:	br   IDLE 		/* the main program finishes */

.data
.global CONTADOR
CONTADOR:
	.skip 4 		/* memory addresses that save the counter of 33-ms. intervals */

.end
