/************************************************************* 
* benchNIOSII2021_Parte2.s (ver 1.0)
*
* AC - Practica 3
*
* Programa para obtener la curva de limitaciones de prestaciones ALU:
* operacionesALU/segundo versus operacionesALU/byte.
*
* subrutinas: ROOFLINE, ESCRIBIR_JTAG, activaTimer, desactivaTimer, PRINT_JTAG 
*
* ficheros: DIV.s, JTAG2021.s, roofline.s, BCD.s, nios_macros.s
*
* Domingo Benitez, Marzo 2021
*
*************************************************************/
.equ ITER_BENCH,1

.global _start
_start:
	movi  	r20, 97		/* codigo ASCII letra 'a' */
	movia 	r22, 0x10001000	/* JTAG data register*/
	movia   sp, 0x007FFFFC	/* inicio de pila */
	movia 	r17, NiterRealizadas /* zona de memoria donde se guardan el numero de iteraciones realizadas: NiterRealizadas */

verTEXTO: 
/* muestra un texto de entradilla en la terminal de Altera Monitor Program */
	movia 	r3, TEXTOentrada	 /* paso parametro: r3, puntero memoria de la string */
	call  	ESCRIBE_TEXTO_JTAG /* printf de strings constantes */

LOOP:	/* esperar por tecla pulsada en el teclado */
	ldwio 	r2, 0(r22)	/* lee data register puerto JTAG */
	andi  	r3,  r2, 0x8000	/* extrae el bit 15: RVALID */
	beq   	r3,  r0, LOOP	/* RVALID=0 -> no dato pulsado */
	andi  	r10, r2, 0xFF	/* extrae bits 0..7: DATA */
	call  	ESCRIBIR_JTAG
	bne   	r10, r20, verTEXTO /* si no es la ‘a’ sigue encuestando JTAG */

/* zona de inicializaciones del benchmark */
	add  	r7, r0, r0		/* numero iteraciones realizadas de benchmark */
	addi 	r4, r0, ITER_BENCH 	/* numero iteraciones a realizar de benchmark */
	stw  	r0, 0(r17)		/* NiterRealizadas = 0 */	

	stw  	r0, tiempoTotal_acumulado(r0) 	/* variable t_T: tiempo de ejecución total del benchmark */

	call 	activaTimer  /* configura Timer y pone en marcha */

/* marca inicial de tiempo total de ejecución del benchmark */
	call 	LEER_TIMER_SNAPSHOT 	/* se toma una marca inicial para luego calcular el tiempo total */
	movia 	r8, TIEMPO		/* TIEMPO guarda la lectura actual del Timer de los ciclos */
	ldw   	r9, 0(r8)
	movia 	r8, tiempoTotal_antes 	/* variable t_1: tiempoTotal_antes <- TIEMPO */
	stw   	r9, 0(r8) 			/* se guarda marca de tiempo variable t_1 */

secuencia: 
/* bucle que itera varias veces sobre la rutina kernel */

hazCall:
	call 	ROOFLINE	/* kernel de computo */
	addi 	r5, r5, 1			/* i++ */
	bne  	r5, r4, secuencia  	/* fin bucle, r4=ITER_BENCH */

	stw  	r5, 0(r17)		/* se guarda i en NiterRealizadas */	

	/* marca final de tiempo total de una ejecución del benchmark */
	call  	LEER_TIMER_SNAPSHOT 	/* accede al Timer para leer el numero de ciclos actuales */
	movia 	r8, TIEMPO		/* variable : TIEMPO guarda la lectura de ciclos del Timer */
	ldw   	r9, 0(r8)
	movia 	r8, tiempoTotal_despues 	/* variable t_2: tiempoTotal_despues <- TIEMPO */
	stw   	r9, 0(r8)
	movia 	r8, tiempoTotal_antes
	ldw          r10, 0(r8)
	sub  	r9, r10, r9			/* tiempoTotal_despues = tiempoTotal_antes - tiempoTotal_despues, el cambio de signo de los operandos es porque Timer empieza a contar desde FFFFFFFF y sub los considera valores negativos */
	movia 	r8, tiempoTotal_acumulado
	stw  	r9, 0(r8) 			/* variable t_T: tiempoTotal_despues = t_2 - t_1 */

	/* salida de la prueba del benchmark */
	call 	desactivaTimer	/* paramos el Timer */
	call 	PRINT_JTAG	/* se muestra las medidas de prestaciones en terminal de AMP */

FIN:
	br 	FIN	/* fin de la prueba */


/* -----------------------------------------------------------* subrutina: activaTimer
*
* Configura el Timer de DE2 para que cuente pulsos de reloj
*
* Parametros entrada: ninguno
*
* Parametros salida:  ninguno
*  ------------------------------------------------------------*/
activaTimer:
	subi  	sp, sp, 16	/* guardamos registros en pila */
	stw   	ra, 16(sp)
	stw 	r12, 12(sp)
	stw  	r15, 8(sp)
	stw  	r16, 4(sp)

	/* configuracion del Timer */
	movia 	r16, 0x10002000 	/* direccion base del Timer */
	movia 	r12, 0xffffffff 	/* inicializa el Timer con la mayor cuenta ya que se configura para hacer snapshots */
	sthio 	r12, 8(r16) 	/* inicializa la media palabra menos significativa del valor inicial del Timer */
	srli  	r12, r12, 16
	sthio 	r12, 0xC(r16) 	/* inicializa la media palabra mas significativa del valor inicial del Timer */

	movi  	r15, 0b0110 	/* START = 1, CONT = 1, ITO = 0 */
	sthio 	r15, 4(r16)	/* configuracion del Timer sin interrupciones */

	ldw  	r12, 12(sp)	/* restauramos registros desde pila */
	ldw  	r15,  8(sp)
	ldw  	r16,  4(sp)
	ldw     ra, 16(sp)
	addi  	sp, sp, 16		

	ret

/* -----------------------------------------------------------* subrutina: desactivaTimer
*
* Desconfigura el Timer de DE2 
*
* Parametros entrada: ninguno
*
* Parametros salida:  ninguno
*  --------------------------------------------------------------*/
desactivaTimer:
	subi sp, sp, 12		/* registros en pila */
	stw  r15,  4(sp)
	stw  r16, 12(sp)
	stw  ra,  8(sp)

	
	movia 	r16, 0x10002000 	/* direccion base del Timer  */
	sthio 	r0, 4(r16)		/* START = 0, CONT = 0, ITO = 0 */

	ldw  	r15,   4(sp)
	ldw  	r16, 12(sp)
	ldw   	ra,    8(sp)
	addi  	sp, sp, 12	/* restauramos registros desde pila */

	ret

/* -----------------------------------------------------------* rutina: LEER_TIMER_SNAPSHOT
*
* Lee el registro de ciclos del Timer haciendo snapshot.
*
* Parametros entrada: ninguno
*
* Parametros de salida: TIEMPO, variable global
*
*  ------------------------------------------------------------*/
.global LEER_TIMER_SNAPSHOT
LEER_TIMER_SNAPSHOT:
	subi 	sp, sp, 16 		/* guardamos registros en pila */
	stw  	r2,  4(sp)
	stw  	r3, 12(sp)
	stw          r10,  8(sp)
	stw  	ra, 16(sp)

	movia   r10, 0x10002000 	/* direccion base del Timer  */
	stwio  	r0, 16(r10) 	/* snapshot del Timer: hacemos una foto del contador de ciclos  */
	ldwio  	r3, 16(r10)	/* 16 bits menos significativos de la cuenta */
	ldwio  	r2, 20(r10)	/* 16 bits mas significativos de la cuenta */
	slli   	r2, r2, 16		/* desplaza a izquierda los mas significativos para alinear */
	or    	r2, r2, r3		/* se componen los 32 bits de la cuenta */
	movia   r10, TIEMPO	
	stw    	r2, 0(r10)		/* se guarda la cuenta en variable TIEMPO */

	ldw   	r3, 12(sp)		/* restauramos registros desde pila */
	ldw   	r2,  4(sp)
	ldw     r10,  8(sp)
	ldw   	ra, 16(sp)
	addi  	sp, sp, 16 	

	ret

/* -----------------------------------------------------------
*  Zona de datos
*  -------------------------------------------------------- */	
.org 0x1000

.global NiterRealizadas
NiterRealizadas:
	.skip 4 		/* numero iteraciones del bucle donde el CODEC estas saturado */

.global TIEMPO
TIEMPO:
	.skip 4 		/* variable para guardar el valor actual del contador de pulsos del Timer */

TIEMPOantes:
	.skip 4 		/* variable con la marca de intervalo de tiempo antes */
TIEMPOdespues:
	.skip 4 		/* variable con la marca de intervalo de tiempo despues */

tiempoTotal_antes:
	.skip 4
tiempoTotal_despues:
	.skip 4

.global tiempoTotal_acumulado
tiempoTotal_acumulado:
	.skip 4

TEXTOentrada:
.ascii "\n   "
.asciz "\nAprieta la tecla a para empezar el benchmark: "


.end
