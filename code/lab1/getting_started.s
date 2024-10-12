/********************************************************************************
 * This program demonstrates use of parallel ports in the DE0-Nano Basic Computer
 *
 * It performs the following: 
 * 	1. displays a rotating pattern on the green LEDG
 * 	2. if KEY[1] is pressed, uses the SW switches as the pattern
********************************************************************************/
	.text									/* executable code follows */
	.global	_start
_start:

	/* initialize base addresses of parallel ports */
	movia		r16, 0x10000010		/* green LED base address */
	movia		r15, 0x10000040		/* SW slider switch (DIP switches) base address */
	movia		r17, 0x10000050		/* pushbutton KEY base address */
	movia		r19, LEDG_bits
	ldw		r6, 0(r19)				/* load pattern for LEDG lights */

DO_DISPLAY:
	ldwio		r4, 0(r15)				/* load slider (DIP) switches */

	ldwio		r5, 0(r17)				/* load pushbuttons */
	beq		r5, r0, NO_BUTTON	
	mov		r6, r4					/* use SW (DIP switch) values on LEDG */
	roli		r4, r4, 8				
	or			r6, r6, r4				
	roli		r4, r4, 8				
	or			r6, r6, r4				
	roli		r4, r4, 8				
	or			r6, r6, r4				
WAIT:
	ldwio		r5, 0(r17)				/* load pushbuttons */
	bne		r5, r0, WAIT			/* wait for button release */

NO_BUTTON:
	stwio		r6, 0(r16)				/* store to LEDG */
	roli		r6, r6, 1				/* rotate the displayed pattern */

	movia		r7, 150000				/* delay counter */
DELAY:	
	subi		r7, r7, 1
	bne		r7, r0, DELAY	

	br 		DO_DISPLAY

/********************************************************************************/
	.data									/* data follows */

LEDG_bits:
	.word 0x0F0F0F0F

	.end
