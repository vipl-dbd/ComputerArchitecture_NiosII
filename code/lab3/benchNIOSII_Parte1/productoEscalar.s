/* 
fichero: productoEscalar.s, Arquitectura de Computadores, EII 

Realizacion del producto escalar de dos vectores

Domingo Benitez, marzo 2021
*/

.global PRODUCTO_ESCALAR
PRODUCTO_ESCALAR:

	subi	  sp, sp, 32	/* 8 registros --> pila, 32 dir */

	stw 	  r2, 4(sp)
	stw 	  r3, 8(sp)
	stw 	  r4, 12(sp)
	stw 	  r5, 16(sp)
	stw 	  r6, 20(sp)
	stw 	  r7, 24(sp)
	stw 	  r8, 28(sp)
	stw  	  ra, 32(sp)

	movia 	r2, AVECTOR /* r2: puntero a vector A */
	movia 	r3, BVECTOR /* r3: puntero a vector B */
	movia 	r4, N
	ldw 	r4, 0(r4)   /* r4: contador de iteraciones */
	add 	r5, r0, r0  /* r5: acumulador del producto */

LOOP: 	ldw 	r6, 0(r2)   /* carga elemento de vector A*/
	ldw 	r7, 0(r3)   /* carga elemento de vector B*/

/* mul r8, r6, r7 - mul: solo para los NIOSII/s y NIOSII/f */
	call MULTIPLICA /* multiplicación para el NIOSII/e */

	add 	r5, r5, r8 /* suma en el acumulador */
	addi 	r2, r2, 4  /* Incrementa puntero a vector A */
	addi 	r3, r3, 4  /* Incrementa puntero a vector B */
	subi 	r4, r4, 1  /* reduce el contador de iteraciones */
	bgt 	r4, r0, LOOP /* repite una iteración */

	stw 	r5, DOT_PRODUCT(r0) /* guarda resultado en memoria */

FIN:	
/* recuperar los registros de la pila y retornar */
	ldw  	  r2, 4(sp)
	ldw  	  r3, 8(sp)
	ldw  	  r4, 12(sp)
	ldw  	  r5, 16(sp)
	ldw  	  r6, 20(sp)
	ldw  	  r7, 24(sp)
	ldw  	  r8, 28(sp)
	ldw  	  ra, 32(sp)

	addi 	  sp, sp, 32

	ret
 

.org 0x5000
N: 
.word 6 /* Specify the number of elements */
AVECTOR: 
.word 5, 3, -6, 19, 8, 12 /* Specify the elements of vector A */
BVECTOR: 
.word 2, 14,-3, 2, -5, 36 /* Specify the elements of vector B */
.org 0x5040
DOT_PRODUCT:
.skip 4

MULTIPLICA:
/* Algoritmo de la multiplicación binaria para NIOSII/e */
/* r6: multiplicando, r7: multiplicador, resultado: r8 */

/* guardar los registros usados en la pila */
	stw 	r31, 0(sp)
	subi 	sp, sp, 4
	stw 	r5, 0(sp)
	subi 	sp, sp, 4
	stw 	r4, 0(sp)
	subi 	sp, sp, 4
	stw 	r9, 0(sp)
	subi 	sp, sp, 4

/* preambulo */
	addi 	r5, r0, 0x1 /* máscara */
	addi 	r4, r0, 32  /* contador bits */
	addi 	r8, r0, 0   /* resultado multiplicacion */

loopMUL:
	and 	r9, r7, r5   /* selecciona bit menos significativo mltiplicador */
	beq 	r9, r0, salida 
	add 	r8, r8, r6
salida:
	subi 	r4, r4, 1   /* Decrement the counter */
	slli 	r6, r6, 1   /* desplaza multiplicando a izquierda */
	beq 	r6, r0, vuelve /* atajo para acortar la multiplicacion */
	srli 	r7, r7, 1   /* desplaza multiplicador a derecha */
	beq 	r7, r0, vuelve /* atajo para acortar la multiplicacion */
	bgt 	r4, r0, loopMUL /* Loop again if not finished */

vuelve:
/* recuperar los registros de la pila y retornar */
	addi 	sp, sp, 4
	ldw 	r9, 0(sp)
	addi 	sp, sp, 4
	ldw 	r4, 0(sp)
	addi 	sp, sp, 4
	ldw 	r5, 0(sp)
	addi 	sp, sp, 4
	ldw 	r31, 0(sp)

	ret
.end
