/********************************************************************************
* lab2_part1_2_3_fibo.s
*
* Subrutina: Ejecuta el c�mputo de la Serie Fibonacci para 8 n�meros
*
* LLamada desde: lab2_part1_2_3_main.s
*
********************************************************************************/

.text
.global FIBONACCI
FIBONACCI:
	subi sp, sp, 24 	/* reserva de espacio para el Stack */
	stw r4, 0(sp)
	stw r5, 4(sp)
	stw r6, 8(sp)
	stw r7, 12(sp)
	stw r8, 16(sp)
	stw r9, 20(sp)

	movia	r4, N		/* r4 apunta N */
	ldw	r5, (r4)	/* r5 es el contador inicializado con N */
	addi	r6, r4, 4	/* r6 apunta al primer n�meros Fibonacci */
 	ldw	r7, (r6)	/* r7 contiene el primer n�mero Fibonacci */
	addi	r6, r4, 8	/* r6 apunta al primer n�meros Fibonacci */
 	ldw	r8, (r6)	/* r7 contiene el segundo n�mero Fibonacci */
	addi	r6, r4, 0x0C	/* r6 apunta al primer n�mero Fibonacci resultado */
	stw	r7, (r6)	/* Guarda el primer n�mero Fibonacci */
	addi	r6, r4, 0x10	/* r6 apunta al segundo n�mero Fibonacci resultado */
	stw	r8, (r6)	/* Guarda el segundo n�mero Fibonacci  */
	subi	r5, r5, 2	/* Decrementa el contador en 2 n�meros ya guardados */
		
LOOP:
	beq	r5, r0, STOP  	/* Termina cuando r5 = 0 */
	subi	r5, r5, 1	/* Decrement the counter */
	addi	r6, r6, 4	/* Increment the list pointer	*/
	add	r9, r7, r8	/* suma dos n�mero precedentes */
	stw	r9, (r6)	/* guarda el resultado */
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
	addi sp, sp, 24 	/* libera el stack reservado */

	ret

.data
N:
	.word 8			/* N�meros Fibonacci */
NUMBERS:
	.word	0, 1		/* Primeros 2 n�meros */
RESULT:
	.skip	32		/* Espacio para 8 n�meros de 4 bytes */

.end
