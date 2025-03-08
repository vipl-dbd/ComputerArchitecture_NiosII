/********************************************************************************
* lab2_part1_2_3_BCD.s
*
* Transform the binary code into BCD value 
*
* Called from: lab2_part1_2_3_JTAG.s
* Subroutine: DIV (lab2_part1_2_3_DIV.s)
*
* input argument: r4= binary value
* output argument: r2= BCD value
*
********************************************************************************/

.text
.global BCD
BCD:
	subi sp, sp, 24 /* stack management */
	stw r3, 0(sp)
	stw r4, 4(sp)
	stw r5, 8(sp)
	stw r6, 12(sp)
	stw r10, 16(sp)
	stw r31, 20(sp) /* saved due to nested subroutines */

	beq r4, r0, END	/* if binary == 0 goto END */

	addi r5, r0, 10 /* r5 = 10 for dividing the BCD value */

	add r6, r0, r0	/* i = 0 */
	add r10, r0, r0	/* r10 = 0 */

LOOP2:	bge r0, r4, END /* while binary value > 0 */

	call DIV	/* calls division with r4 = dividend, r5 = divisor; returns r3= quotient, r2= remainder  */
	sll r2, r2, r6	/* shifts the result 4 bits to the left except for the first number */
	or r10, r10, r2 /* accumulates the result in r10 */
	addi r6, r6, 4	/* updated r6 += 4 */

	bgt r5, r3, END /* if quotient < 10 goto END */
	add r4, r3, r0	/* r4 = previous quotient */

	jmpi LOOP2	/* if quotient >= 10 goto LOOP2 */

END:	sll r3, r3, r6	/* shifts the final quotient several 4 bits to the left */
	or r10, r10, r3 /* accumulates the result in r10 */
	add r2, r10, r0 /* puts the result in the output register r2 */

	ldw r3, 0(sp)
	ldw r4, 4(sp)
	ldw r5, 8(sp)
	ldw r6, 12(sp)
	ldw r10, 16(sp)
	ldw r31, 20(sp)
	addi sp, sp, 24 /* free the reserved stack */

	ret
.end
