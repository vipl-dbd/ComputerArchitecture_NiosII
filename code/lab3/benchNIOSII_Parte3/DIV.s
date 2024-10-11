/********************************************************************************
* fichero: DIV.s
*
* EC- Practica 4 - Eejrcicio 4
* División entera para el NIOS II que se requiere cuando el procesador no dispone 
* del hardware de un divisor
*
* Referencia: http://stackoverflow.com/questions/938038/assembly-mod-algorithm-on-processor-with-no-division-operator
*
* Llamada desde: benchNIOSII.s
*
* parametros de entrada:
*			r4= dividendo
*			r5= divisor
* parametros de salida: 
*			r2= resto
*			r3= cociente
*
********************************************************************************/
.text
.global DIV
DIV:
	subi 	  sp, sp, 16 	/* reservar espacio en pila */
	stw 	  r6, 0(sp)
	stw 	  r7, 4(sp)
	stw 	r10, 8(sp)
	stw 	r11, 12(sp)

	beq 	  r5, r0, END	/* si divisor == 0 goto END */

EMPIEZA:
	add 	r2, r4, r0		/* resto = dividendo */
	add 	r6, r5, r0		/* r6 = next_multiple = divisor */
	add 	r3, r0, r0		/* cociente = 0 */

LOOP:	add 	r7, r6, r0		/* r7 = multiple = next_multiple */
	slli 	r6, r7, 1		/* next_multiple = left_shift(multiple,1) */
	
	sub 	r10, r2, r6		/* r10 = resto - next_multiple */
	sub 	r11, r6, r7		/* r11 = next_multiple - multiple */

	blt 	r10, r0, LOOP2  	/* si r10 < 0 goto LOOP2 */
	bgt 	r11, r0, LOOP   	/* si r11 > 0 goto LOOP */
	
LOOP2:	bgt 	r5, r7, END    	/* while divisor <= multiple */
	slli 	r3, r3, 1	   	/* cociente << 1 */
	bgt 	r7, r2, DESPLAZA 	/* si multiple <= resto */
	sub 	r2, r2, r7		/* then resto = resto - multiple */
	addi 	r3, r3, 1		/* cociente += 1 */

DESPLAZA:
	srli 	r7, r7, 1		/* multiple = right_shift(multiple, 1) */
	jmpi 	LOOP2

END:	ldw 	  r6, 0(sp)
	ldw 	  r7, 4(sp)
	ldw 	r10, 8(sp)
	ldw 	r11, 12(sp)
	addi 	  sp, sp, 16 	/* libera la pila */

	ret
.end
