/********************************************************************************
* lab3_part1_BCD.s
*
* Subrutina: transforma código binario en BCD 
*
* LLamada desde: lab3_part1_print.s
* Subrutina: DIV (lab3_part1_DIV.s)
*
* argumentos: r4= valor binario
* resultados: r2= valor BCD
*
********************************************************************************/

.text
.global BCD
BCD:
	subi  sp, sp, 24 	/* reserva de memoria en el Stack */
	stw   r3,  0(sp)
	stw   r4,  4(sp)
	stw   r5,  8(sp)
	stw   r6, 12(sp)
	stw  r10, 16(sp)
	stw  r31, 20(sp) 	/* por posible llamada anidada */

	bne r4, r0, sigue	/* si binario == 0 goto END */
	add r2, r0, r0
	br  END_0

sigue:
	addi r5, r0, 10 /* r5 = 10 para dividir BCD */

	add r6, r0, r0	/* i = 0 */
	add r10, r0, r0	/* r10 = 0 */

LOOPbcd:	
	bge r0, r4, ENDbcd    /* while valor binario > 0 */

	call DIV	/* llama a division con r4 = dividendo, r5 = divisor; devuelve r3= cociente, r2= resto */
	sll r2, r2, r6	/* desplaza el resultado 4 bits a la izquierda excepto el primer número */
	or r10, r10, r2 /* acumula el resultado en r10 */
	addi r6, r6, 4	/* actualiza r6 += 4 */

	bgt r5, r3, ENDbcd /* si cociente < 10 goto END */
	add r4, r3, r0	/* r4 = cociente anterior */

	jmpi LOOPbcd	/* si cociente >= 10 goto LOOPbcd */

ENDbcd:	sll r3, r3, r6	/* desplaza el cociente final varios 4 bits a la izquierda */
	or r10, r10, r3 /* acumula el resultado en r10 */
	add r2, r10, r0 /* pone el resultado en el registro de salida r2 */

END_0:
	ldw   r3,  0(sp)
	ldw   r4,  4(sp)
	ldw   r5,  8(sp)
	ldw   r6, 12(sp)
	ldw  r10, 16(sp)
	ldw  r31, 20(sp)
	addi  sp, sp, 24 /* libera el stack reservado */

	ret
.end
