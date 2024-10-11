/* 
* fichero: roofline.s, Arquitectura de Computadores, GII, EII 
*
* Medida de la relacion: op/seg vs. op/byte
*
* Domingo Benitez, marzo 2021
*/

.equ Niter,1000	/* numero de iteraciones del bucle principal de este kernel */
.equ NiterInternas,1 /* 1,5,20,47,400,500; numero iteraciones de un bucle anidado, se modifica para dar mas o menos porcentaje de instrucciones de salto al numero total de instrucciones */

.global ROOFLINE
ROOFLINE:

	subi      sp, sp, 24    /* 6 registros --> pila, 24 dir */

   	stw       ra, 0(sp)
   	stw       r2, 4(sp)
   	stw       r4, 8(sp)
   	stw       r6, 12(sp)
   	stw       r5, 16(sp)
   	stw       r7, 20(sp)

	movia 	r2, A 	    /* r2: puntero a variable A */
	movia 	r4, N
	ldw 	r4, 0(r4)   /* r4 = Niter, numero de iteraciones a realizar */
	add	r7, r0, r0  /* contador de iteraciones realizadas = 0 */

LOOP: 	
/* Begin: ZONA 1 de accesos a memoria */
	ldw 	r6, 0(r2)   /* carga A */

/* 3 cargas que se pueden activar o desactivar para variar la relacion op/byte 
   Cada ldw accede a 4 bytes */
/*
	ldw 	r6, 0(r2)   
 	ldw 	r6, 0(r2)   
 	ldw 	r6, 0(r2)   
*/
/* End: Zona de accesos a memoria */

/* Begin: ZONA 2 de operaciones ALU */
	add 	r6, r6, r6  /* suma con dependencia de datos con ldw r6, 0(r2) */

/* 44 add que se pueden activar o desactivar parcialmente para dar variar la relacion op/byte */
/*
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
	add 	r6, r6, r6  
*/
/* End: Zona de operaciones ALU */

/* 2 instrucciones mas de tipo ALU, nunca se desactivan */
	addi 	r7, r7, 1   /* contador_iteraciones_realizadas++ */
	subi 	r4, r4, 1   /* Niter-- */

/* Begin: ZONA 3 de bucle interno para forzar la ejecucion de multiples saltos */
/* NiterInternas= 1,5,20,47,400,500 */
/*
	addi	r5,r0,NiterInternas 
bucleInterno:
	add 	r6, r6, r6  
	subi	r5, r5, 1
	bgt	r5, r0, bucleInterno
*/
/* End: ZONA 3 de bucle interno para forzar la ejecucion de multiples saltos */

/* Fin del bucle  LOOP */
	bgt 	r4, r0, LOOP 


/* guarda Niter iteraciones realizadas en variable ITERACIONES para la */
/* comprobación de la ejecucion correcta */
	stw 	r7, ITERACIONES(r0) 

/* recuperar los registros de la pila y retornar */
	ldw  	  ra, 0(sp)
	ldw  	  r2, 4(sp)
	ldw  	  r4, 8(sp)
	ldw  	  r6, 12(sp)
	ldw  	  r5, 16(sp)
	ldw  	  r7, 20(sp)

	addi 	  sp, sp, 24

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