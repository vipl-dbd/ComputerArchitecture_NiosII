/********************************************************************************
* lab2_part1_2_3_div.s
*
* Integer division for Nios II processors\par
*
* Reference: http://stackoverflow.com/questions/938038/assembly-mod-algorithm-on-processor-with-no-division-operator
*
* Called from: lab2_part1_2_3_JTAG.s
*
* input arguments: r4= dividend, r5= divisor
* output arguments: r2= remainder, r3= quotient
*
********************************************************************************/

.text
.global DIV
DIV:
	subi sp, sp, 16 	/* reserve memory space for the stack */
	stw r6, 0(sp)
	stw r7, 4(sp)
	stw r10, 8(sp)
	stw r11, 12(sp)

	beq r5, r0, END		/* if divisor == 0 goto END */

EMPIEZA:
	add r2, r4, r0		/* remainder = dividend */
	add r6, r5, r0		/* r6 = next_multiple = divisor */
	add r3, r0, r0		/* cociente = 0 */

LOOP:	
	add r7, r6, r0		/* r7 = multiple = next_multiple */
	slli r6, r7, 1		/* next_multiple = left_shift(multiple,1) */
	
	sub r10, r2, r6		/* r10 = remainder - next_multiple */
	sub r11, r6, r7		/* r11 = next_multiple - multiple */

	blt r10, r0, LOOP2  	/* si r10 < 0 goto LOOP2 */
	bgt r11, r0, LOOP   	/* si r11 > 0 goto LOOP */
	
LOOP2:	
	bgt r5, r7, END    	/* while divisor <= multiple */
	slli r3, r3, 1	   	/* cociente << 1 */
	bgt r7, r2, DESPLAZA 	/* if multiple <= resto */
	sub r2, r2, r7		/* then remainder = remainder - multiple */
	addi r3, r3, 1		/* 	cociente += 1 */

DESPLAZA:
	srli r7, r7, 1		/* multiple = right_shift(multiple, 1) */
	jmpi LOOP2

END:	
	ldw r6, 0(sp)
	ldw r7, 4(sp)
	ldw r10, 8(sp)
	ldw r11, 12(sp)
	addi sp, sp, 16 	/* free stack memory */

	ret
.end
