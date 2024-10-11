/* 
* fichero: bypassing.s, Arquitectura de Computadores, GII, EII 
*
* Medida de prestaciones de NiosII/f cuando se aplica la tecnica 
* de reordenacion de instrucciones
*
* Domingo Benitez, marzo 2021
*/

.equ Niter,1000	/* numero de iteraciones del bucle principal de este kernel */

.global BYPASSING
BYPASSING:
	subi	  sp, sp, 16	/* 4 registros --> pila, 16 dir */

	stw 	  r2, 4(sp)
	stw 	  r4, 8(sp)
	stw 	  r6, 12(sp)
	stw 	  r7, 16(sp)

	movia 	r2, A 	    /* r2: puntero a variable A */
	movia 	r4, N
	ldw 	r4, 0(r4)   /* r4: contador de iteraciones */
	add	r7, r0, r0  /* Niter=0 */

LOOP: 	
	ldw 	r6, 0(r2)   /* carga A */

/* ZONA de dependencia de datos */
	add 	r6, r6, r6  /* suma CON dependencia de datos con ldw r6, 0(r2) */
	/*add 	r6, r4, r4  /* suma SIN dependencia de datos con ldw r6, 0(r2) */

/* 2 instrucciones mas de tipo ALU, nunca se comentan */
	addi 	r7, r7, 1   /* Niter++ */
	subi 	r4, r4, 1   /* N-- */

	bgt 	r4, r0, LOOP 

	stw 	r7, ITERACIONES(r0) 

/* recuperar los registros de la pila y retornar */
	ldw  	  r2, 4(sp)
	ldw  	  r4, 8(sp)
	ldw  	  r6, 12(sp)
	ldw  	  r7, 16(sp)

	addi 	  sp, sp, 16

	ret
 

.org 0x5000
N: 
.word Niter /* numero de iteraciones del bucle principal del kernel mem-computo */
A: 
.word 5 /* variable A */

.org 0x5040
ITERACIONES:
.skip 4


.end
