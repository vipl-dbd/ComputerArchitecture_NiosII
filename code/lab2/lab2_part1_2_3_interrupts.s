/********************************************************************************
* subrutina: lab2_part1_2_3_interrupts.s
*
* El programa AMP (Altera Monitoro Program) sitúa automáticamente la sección ".reset"
* en la dirección de memoria del reset que se especifica en la configuración del NIOS II
* que se determina con SOPC Builder.
* "ax" se necesita para indicar que esta sección se reserva y ejecuta
*/

.section .reset, "ax"
movia r2, _start
jmp r2 /* salta al programa principal */

/********************************************************************************
* El programa AMP (Altera Monitor Program) sitúa automáticamente la sección ".exceptions"
* en la dirección de memoria del reset que se especifica en la configuración del NIOS II
* que se determina con SOPC Builder.
* "ax" se necesita para indicar que esta sección se reserva y ejecuta
*
* Subrutinas: INTERVAL_TIMER_ISR (lab3_part1_excepciones.s)
*/

.section .exceptions, "ax"
.global EXCEPTION_HANDLER

EXCEPTION_HANDLER:
	subi sp, sp, 16 	/* reserva el Stack */
	stw et, 0(sp)
	rdctl et, ctl4
	beq et, r0, SKIP_EA_DEC /* interrupcion no es externa */
	subi ea, ea, 4 		/* debe decrementarse ea en 1 instrucción */

/* para interrupciones externas, de forma tal que */
/* la instrucción interrumpida se ejecutará después de eret (Exception RETurn) */
SKIP_EA_DEC:
	stw ea, 4(sp) 		/* guardar registros en el Stack */
	stw ra, 8(sp) 		/* se requiere si se ha usado un call */
	stw r22, 12(sp)
	rdctl et, ctl4
	bne et, r0, CHECK_LEVEL_0 /* la excepción es una interrupción externa */

NOT_EI: /* excepción para instrucciones no implementadas o TRAPs */
	br END_ISR 

CHECK_LEVEL_0: /* Timer dispone de interrupciones de Level 0 */
	call INTERVAL_TIMER_ISR
	br END_ISR

END_ISR:
	ldw et, 0(sp) 		/* restaurar valores previos de registros */
	ldw ea, 4(sp)
	ldw ra, 8(sp) 		
	ldw r22, 12(sp)
	addi sp, sp, 16
eret
.end
