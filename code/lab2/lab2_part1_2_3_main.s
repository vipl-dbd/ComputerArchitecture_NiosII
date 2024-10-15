/********************************************************************************
* lab2_part1_2_3_main.s
*
* Programa principal de la Práctica 2, Ejercicio 1 de AC
*
* Inicializa el sistema Timer de DE2
* Inicializa y activa el sistema de interrupciones del procesador NIOS II
* Ejecuta un bucle Fibonacci y muestra el número de intervalos de 33 ms en HEX de la placa DE2
*
* Subrutinas: PRINT_JTAG (lab2_part1_2_3_JTAG.s), FIBONACCI (lab2_part1_2_3_fibo.s), 
*
********************************************************************************/
.equ ITERACIONES, 500000
.text /* empieza el código ejecutable */
.global _start

_start:
	/* se inicializa el puntero del stack */
	movia sp,  0x007FFFFC 	/* stack comienza en la última posición de memoria de la SDRAM */
	movia r16, 0x10002000 	/* dirección base del sistema Timer interno */

	/* se iniciliza el tiempo del intervalo en el que el Timer genera una interrupción para análisis de prestaciones*/
	movia r12, 0x190000 	/* 1/(50 MHz) x (0x190000) = 33 milisegundos */
	sthio r12, 8(r16) 	/* guarda la mitad interior de la palabra del valor inicial del Timer */
	srli  r12, r12, 16 	/* desplaza el valor 16 bits a la derecha */
	sthio r12, 0xC(r16) 	/* guarda la mitad superior de la palabra del valor inicial del Timer */

	/* se inicializa el Timer, habilitando sus interrupciones */
	movi  r15, 0b0111 	/* START = 1, CONT = 1, ITO = 1 */
	sthio r15, 4(r16)

	/* se habilita el sistema de interrupciones del procesador Nios II */
	movi  r7, 0b011 	/* se inicializa la máscara de bits de interrupciones para el nivel 0 (interval */
	wrctl ienable, r7 	/* Timer) y nivel 1 (pushbuttons) */
	movi  r7, 1
	wrctl status, r7 	/* se activan las interrupciones del Nios II */

	movia r14, ITERACIONES 	/* inicializa el contador de iteraciones LOOP, cada una de ellas ejecuta un bucle Fibonacci */
	addi  r17, r0, 0 	/* inicializa el contador de intervalos del programa "r17" */

LOOP:	beq   r14, r0, END 	/* se ejecuta el bucle Fibonacci */
	call  FIBONACCI
	addi  r14, r14, -1
	br    LOOP

END:	movi  r7, 0
	wrctl status, r7 	/* se desactiva el procesamiento de interrupciones en el Nios II */

	call PRINT_JTAG 		/* se muestra el número de intervalos de 33 ms en el terminal de AMP */

IDLE:	br   IDLE 		/* termina el programa principal */

.data
.global CONTADOR
CONTADOR:
	.skip 4 		/* posicion de memoria que guarda el contador de intervalos del Timer */

.end
