/****************************************************************************** 
* subroutine: lab2\_part1\_2\_3\_interrupts.s
* 
* The AMP program (Altera Monitor Program) finds out the section ".reset" 
* in the memory address that is set in the Nios II hardware configuration 
* by the SOPC Builder tool. 
* "ax" is needed to indicate that this section is reserved and executed 
******************************************************************************/ 

.section .reset, "ax"
movia r2, _start
jmp r2 				/* jump to the main program */

/******************************************************************************
* The AMP program (Altera Monitor Program) finds out the section ".exceptions" 
* in the memory address that is set in the Nios II hardware configuration 
* by the SOPC Builder tool. \par
* "ax" is needed to indicate that this section is reserved and executed 
*
* Subroutines: INTERVAL_TIMER_ISR (lab2_part1_2_3_excepciones.s)
******************************************************************************/ 

.section .exceptions, "ax"
.global EXCEPTION_HANDLER

EXCEPTION_HANDLER:
	subi sp, sp, 16 		/* reserve the stack */
	stw et, 0(sp)
	rdctl et, ctl4
	beq et, r0, SKIP_EA_DEC 	/* interrupt is not external */
	subi ea, ea, 4 			/* ea register must be decreased by 1 instruction */

SKIP_EA_DEC:
/* For external interruptions, so that the interrupted instruction will be executed  */
/* after eret (Exception Return) */
	stw ea, 4(sp) 			/* save registers in the stack */
	stw ra, 8(sp) 			/* required if a call has been used */
	stw r22, 12(sp)
	rdctl et, ctl4
	bne et, r0, CHECK_LEVEL_0 	/* the exception is an external interrupt */

NOT_EI:
/* exception for not implemented instructions or TRAPs */
	br END_ISR 

CHECK_LEVEL_0: 
/* Timer has Level 0 interrupt */
	call INTERVAL_TIMER_ISR
	br END_ISR

END_ISR:
	ldw et, 0(sp) 			/* restore previous registers values from stack */
	ldw ea, 4(sp)
	ldw ra, 8(sp) 		
	ldw r22, 12(sp)
	addi sp, sp, 16
eret
.end
