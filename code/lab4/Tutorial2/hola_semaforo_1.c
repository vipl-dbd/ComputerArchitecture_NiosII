/*
 * AC - Practica 4
 *
 * Tutorial: "hola_semaforo_1"
 *
 */

#include "stdio.h"

#include <stdio.h>
#include <system.h>
#include <altera_avalon_mutex.h>

int main(){
// dirección de memoria de message buffer: 0x 400 0000
volatile int * message_buffer_ptr  = (int *) MESSAGE_BUFFER_RAM_BASE;	
/* se guarda el manejador del dispositivo hardware de tipo mutex*/
alt_mutex_dev* mutex = altera_avalon_mutex_open("/dev/message_buffer_mutex");
int message_buffer_val 	= 0x0;

while(1) {
   /* CPU pide ser propietario de mutex, asignando el valor 2 */
   altera_avalon_mutex_lock(mutex,2);
    /* guarda en buffer el valor */
   *(message_buffer_ptr) = message_buffer_val; 
   altera_avalon_mutex_unlock(mutex); /* libera mutex */
   message_buffer_val++;
}

return 0;
}