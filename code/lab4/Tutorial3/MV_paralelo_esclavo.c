/*
 * AC - Practica 4
 *
 * Tutorial 3: "Multiplicacion Matriz x Vector"
 * Version paralela - Hilo Esclavo
 *
 * y = A . x
 * 
 */
#include "sys/alt_stdio.h"
#include <stdio.h>
#include <unistd.h>
#include <system.h>
#include <altera_avalon_mutex.h>

#define Ta_m 16 // numero de columnas de matriz A
#define Ta_n 16 // numero filas de matriz y tamaño de vectores x, y

int m			= Ta_m;
int n			= Ta_n;
int thread_count	= 2; // 2;
int Niter		= 2000; //1000,2000,5000, 10000; // veces repite matriz-vector
int rank		= 1; // hilo esclavo, para nucleo= CPU2

// RAM para sincronizacion entre hilos, tamano total RAM= 8 bytes
volatile unsigned int * message_buffer_ptr 		= (unsigned int *) MESSAGE_BUFFER_RAM_BASE;
volatile unsigned int * message_buffer_ptr_join = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+4);
//volatile int 			* message_buffer_ptr 		= (int *) 			MESSAGE_BUFFER_RAM_BASE;
//volatile unsigned int 	* message_buffer_ptr_join 	= (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+4);

// zona de memoria compartida para matriz A y vectores x, y
volatile int * x 	= (int *) 0x6440; // 16x1 x4=64B: 0x6440 - 0x647F
volatile int * y	= (int *) 0x6480; // 16x1 x4=64B: 0x6480 - 0x64BF
volatile int * A	= (int *) 0x6000; // 16x16x4=1KB: 0x6000 - 0x63FF

// Realiza matriz-vector del hilo esclavo
int main()
{
	/* direccion del dispositivo mutex */
	alt_mutex_dev* mutex = altera_avalon_mutex_open("/dev/message_buffer_mutex");

	int message_buffer_val 		= 0x0;
	int message_buffer_val_join = 0x0;
	int k;

	// FORK del Hilo-1, sincronizacion desde Hilo-0, message_buffer_val=15
	while(message_buffer_val != 15) {
		/* acquire the mutex, setting the value to two */
		altera_avalon_mutex_lock(mutex,2);			/* bloquea mutex */
		message_buffer_val = *(message_buffer_ptr); /* lee valor en buffer */
		altera_avalon_mutex_unlock(mutex); 			/* libera mutex */
	}

	// COMPUTO ESCLAVO - Operacion matriz-vector
	// k: bucle de computo, realiza multiples veces matriz-vector en esta cpu
	int i, j;
	int local_n 	 = n / thread_count;
	int my_first_row = rank * local_n;			// 1ª fila asignada a este nucleo
	int my_last_row  = (rank+1) * local_n - 1;  // ultima fila asignada a este nucleo

	for (k = 0; k < Niter; k++) {
		for (i=my_first_row; i<=my_last_row; i++){
		   for(j=0; j<m; j++){
			   y[i] += A[i*m+j] * x[j];
		   }
		}
	}

	// JOIN - Unificacion de hilos
	altera_avalon_mutex_lock(mutex,2);
	message_buffer_val_join = *(message_buffer_ptr_join); /* lee valor en buffer */
	message_buffer_val_join |= 0x2; /* ID=2 sincronizacion hilo 1 */
	*(message_buffer_ptr_join) = message_buffer_val_join; /* guarda en buffer el valor */
	altera_avalon_mutex_unlock(mutex); /* libera mutex */

	return 0;
}
