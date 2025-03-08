/********************************************************************************
* lab2_part1_2_3_fibo.s
*
* Subroutine: this routine executes the Fibonacci Series computation for 8 numbers
*
* Called from: lab2_part1_2_3_main.s
*
********************************************************************************/

.text
.global FIBONACCI
FIBONACCI:
	subi sp, sp, 24 	/* reserve space for the stack */
	stw r4, 0(sp)
	stw r5, 4(sp)
	stw r6, 8(sp)
	stw r7, 12(sp)
	stw r8, 16(sp)
	stw r9, 20(sp)

	movia	r4, N		/* r4 points to N address */
	ldw	r5, (r4)	/* r5 is the counter initialized with the value stored in N */
	addi	r6, r4, 4	/* r6 points to the first Fibonacci number */
 	ldw	r7, (r6)	/* r7 contains the first Fibonacci number */
	addi	r6, r4, 8	/* r6 points to the second Fibonacci number */
 	ldw	r8, (r6)	/* r7 contains the second Fibonacci number */
	addi	r6, r4, 0x0C	/* r6 points to the third Fibonacci number */
	stw	r7, (r6)	/* Save the third Fibonacci number */
	addi	r6, r4, 0x10	/* r6 points to the fourth Fibonacci number */
	stw	r8, (r6)	/* Save the fourth Fibonacci number  */
	subi	r5, r5, 2	/* Decrease the number of values saved in 2 */
		
LOOP:
	beq	r5, r0, STOP  	/* Finishes when r5 = 0 */
	subi	r5, r5, 1	/* Decrement the counter */
	addi	r6, r6, 4	/* Increment the list pointer */
	add	r9, r7, r8	/* adds two previous numbers */
	stw	r9, (r6)	/* saves the result */
	mov	r7, r8
	mov	r8, r9
	br	LOOP

STOP:	
	ldw r4, 0(sp)
	ldw r5, 4(sp)
	ldw r6, 8(sp)
	ldw r7, 12(sp)
	ldw r8, 16(sp)
	ldw r9, 20(sp)
	addi sp, sp, 24 	/* releases the reserved stack */

	ret

.data
N:
	.word 8			/* 8 Fibonacci Numbers */
NUMBERS:
	.word	0, 1		/* First and second numbers */
RESULT:
	.skip	32		/*  Space for 8 numbers of 4 bytes */

.end
