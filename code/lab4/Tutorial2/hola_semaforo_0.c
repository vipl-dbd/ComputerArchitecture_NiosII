/*
 * AC - Practica 4
 *
 * Tutorial: "hola_semaforo_0"
 *
 */
#include <stdio.h>
#include <system.h>
#include <altera_avalon_mutex.h>
#include <unistd.h>

int main(){

// dirección de memoria de message buffer: 0x 400 0000
volatile int * message_buffer_ptr = (int *) MESSAGE_BUFFER_RAM_BASE;	

printf("Hola, soy CPU!\n");

/* se guarda el manejador del dispositivo hardware de tipo mutex*/
alt_mutex_dev* mutex = altera_avalon_mutex_open("/dev/message_buffer_mutex");

int message_buffer_val 	= 0x0;
int iteraciones 	= 0x0;

while(1) {
	iteraciones++;
	/* CPU pide ser propietario de mutex, asignando el valor 1 */
	altera_avalon_mutex_lock(mutex,1);

	message_buffer_val = *(message_buffer_ptr); /* lee valor guardado en buffer */

	altera_avalon_mutex_unlock(mutex); /* libera mutex */

	printf("CPU - iter: %i - message_buffer_val: %08X\n", iteraciones, message_buffer_val); 

	usleep(1000000); /* espera 1 seg = 106 useg */
}
return 0;
}