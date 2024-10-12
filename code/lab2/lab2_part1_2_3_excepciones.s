/********************************************************************************
* lab2_part1_2_3_excepciones.s
*
* Subrutina que aumenta un contador de intervalos del Timer
*
* LLamada desde: lab2_part1_2_3_interrupts.s
*
********************************************************************************/

.extern CONTADOR
.global INTERVAL_TIMER_ISR
INTERVAL_TIMER_ISR:
	subi sp, sp, 8 		/* reserva de espacio en el stack */
	stw r10, 0(sp)
	stw r11, 4(sp)

	movia r10, 0x10002000 	/* direccion base del Timer */
	sthio r0, 0(r10) 	/* inicializa a 0 la interrupción */

	movia r10, CONTADOR 	/* dirección base del contador de intervalos del Timer */
	ldw r11, 0(r10)
	addi r11, r11, 1  	/* suma el contador de intervalos Timer */
	stw r11, 0(r10)

	ldw r10, 0(sp)
	ldw r11, 4(sp)
	addi sp, sp, 8 		/* libera el stack */

	ret
.end
