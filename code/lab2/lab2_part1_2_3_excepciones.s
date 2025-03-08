/********************************************************************************
* lab2_part1_2_3_excepciones.s
*
* Subroutine that increases an interval counter of the Timer
*
* Called from: lab2_part1_2_3_interrupts.s
*
********************************************************************************/

.extern CONTADOR
.global INTERVAL_TIMER_ISR
INTERVAL_TIMER_ISR:
	subi sp, sp, 8 		/* reserved space in the stack */
	stw r10, 0(sp)
	stw r11, 4(sp)

	movia r10, 0x10002000 	/* base address of Timer */
	sthio r0, 0(r10) 	/* initialize to 0 the interrupt */

	movia r10, CONTADOR 	/* base address of the Timer interval counter */
	ldw r11, 0(r10)
	addi r11, r11, 1  	/* adds the timer interval counter */
	stw r11, 0(r10)

	ldw r10, 0(sp)
	ldw r11, 4(sp)
	addi sp, sp, 8 		/* release the stack */

	ret
.end
