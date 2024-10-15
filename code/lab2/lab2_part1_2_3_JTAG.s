/****************************************************************
* fichero: lab2_part1_2_3_JTAG.s
*
* AC - Practica 2 - Eejrcicio 1
* Subrutinas relacionadas con la muestra de un caracter en la terminal 
* 
* parametros de entrada:
*			r10 = valor ascii del caracter a procesar 
*
* parametros de salida: ninguno
****************************************************************/

.extern 	CONTADOR /* variable definida en prog principal */

/* 
Subrutina: PRINT_JTAG
Muestra en terminal JTAG de AMP el contenido de la posición de memoria externa CONTADOR 
*/
.global PRINT_JTAG
PRINT_JTAG:
	
	subi  	sp, sp, 24	/* gestion de pila */
	stw   	r2,  4(sp)
	stw   	r3,  8(sp)
	stw  	  	r4, 12(sp)
	stw  	    r10, 16(sp)
	stw  	    r17, 20(sp)
	stw   	ra, 24(sp)

	movia 	r3, TEXTO
	call 	ESCRIBE_TEXTO_JTAG	/* escribe en terminal JTAG texto fijo */

	movia 	r17, CONTADOR	/* direccion base del contador de intervalos del Timer */
	ldw   	  r4, 0(r17)
	call  	BCD			/* r4= valor binario, r2= valor BCD */

	call 	ESCRIBE_VALOR_JTAG	/* escribe en terminal JTAG valor BCD */
	
	movia 	r3, TEXTO_FIN
	call 	ESCRIBE_TEXTO_JTAG	/* escribe en terminal JTAG texto fijo */

	ldw   	  r2,  4(sp)		/* gestion de pila */
	ldw   	  r3,  8(sp)
	ldw   	  r4, 12(sp)
	ldw  	r10, 16(sp)
	ldw  	r17, 20(sp)
	ldw   	  ra, 24(sp)
	addi  	  sp, sp, 24

	ret

/* 
Subrutina: ESCRIBE_TEXTO_JTAG
escribe una cadena de caracteres por terminal JTAG
	parametros:	r3, puntero de la string 
*/
.global ESCRIBE_TEXTO_JTAG
ESCRIBE_TEXTO_JTAG:
	subi 	 sp, sp, 12
	stw   r3,  4(sp)
	stw  	r10,  8(sp)
	stw   ra, 12(sp)

BUC:
	ldb  	r10, 0(r3) 		/* carga 1 byte desde dirección de la cadena de caracteres */
	beq  	r10, r0, CON 	/* si lee un 0, significa que ha llegado al final de la cadena y sale bucle */
	call 	ESCRIBIR_JTAG 	/* subrutina que muestra el byte por JTAG-UART */
	addi  	r3, r3, 1 		/* siguiente byte */
	br   	BUC 		/* cierra el bucle */
CON:
	ldw   	r3,  4(sp)
	ldw         r10,  8(sp)
	ldw   	ra, 12(sp)
	addi  	sp, sp, 12

	ret

/* 
Subrutina: ESCRIBE_VALOR_JTAG
escribe un valor en BCD por terminal JTAG
	parametros:	r2, valor BCD 
*/
.global ESCRIBE_VALOR_JTAG
ESCRIBE_VALOR_JTAG:
	subi  	sp, sp, 16
	stw   	r2,  4(sp)
	stw   	r4,  8(sp)
	stw  		r10, 12(sp)
	stw   	ra, 16(sp)

	addi   	r4, r0, 8		/* contador de 8 nibles BCD */
VALOR:	
	andhi 	r10, r2, 0xf000	/* extrae 4 bits BCD más significativos*/
	srli  	r10, r10, 28	/* resultado r10 se desplaza a dcha 28 bits */
	addi  	r10, r10, 0x30	/* suma 0x30: BCD -> ASCII */ 
	call  	ESCRIBIR_JTAG	/* muesra ASCII */
	subi   	r4, r4, 1		/* contador de nible -- */
	slli   	r2, r2, 4		/* siguiente nible BCD */
	bne    	r4, r0, VALOR

	ldw   	r2,  4(sp)
	ldw   	r4,  8(sp)
	ldw  	r10, 12(sp)
	ldw   	ra, 16(sp)
	addi  	sp, sp, 16

	ret

.global ESCRIBIR_JTAG
ESCRIBIR_JTAG:
	subi	  sp, sp, 12	/* los registros usados se guardan en la pila */
	stw 	  r3,  4(sp)
	stw 	 r22,  8(sp)
	stw  	  ra, 12(sp)

	movia 	r22, 0x10001000 	/* direccion base de puerto JTAG */

otraVEZ:	/* encuesta: comprobar si hay espacio para escribir */
	ldwio 	r3, 4(r22)		/* lee registro del puerto JTAG-UART */
	andhi 	r3, r3, 0xffff  	/* se seleccionan los 16 bits más significativos */
	beq   	r3, r0, otraVEZ	/* ¿WSPACE=0? */

WRT:	/* envia el caracter escribiendo en JTAG-UART */
	stwio 	r10, 0(r22)
	
FIN:	ldw  	  r3, 4(sp)		/* recuperar los registros de la pila y retornar */
	ldw	r22, 8(sp)
	ldw 	  ra, 12(sp)
	addi 	  sp, sp, 12

	ret

/*
* Zona de datos
*/
TEXTO:
.asciz 	"\n\nIntervalos de tiempo que el programa necesita= "
TEXTO_FIN:
.asciz 	"\n\nFin del programa "

.end 
