/*
 * AC - Practica 4
 *
 * Tutorial 3: "Multiplicacion Matriz x Vector"
 * Version paralela - Hilo Maestro
 *
 * y = A . x
 * 
 */
#include "sys/alt_stdio.h"
#include "sys/alt_sys_init.h"
#include <stdio.h>
#include <system.h>
#include <unistd.h>
#include <altera_avalon_mutex.h>

// Timer, incluir el timestamp en BSP: boton dcho en BSP folder, Nios2 > BSP editor > cambiar system timer y timestamp timer
#include <altera_avalon_timer.h>
#include <sys/alt_timestamp.h>
#include <alt_types.h>

#define Ta_m 16 // numero de columnas de matriz A
#define Ta_n 16 // numero filas de matriz y tamaño de vectores x, y

int m			= Ta_m;
int n			= Ta_n;
int Niter		= 2000; // veces repite matriz-vector; otros valores: 1000,2000,5000,10000
int thread_count	= 2;    // numero de hilos
int rank		= 0; 	// hilo maestro para nucleo= CPU

// RAM para sincronizacion entre hilos, tamano total RAM= 8 bytes
volatile unsigned int * message_buffer_ptr 	= (unsigned int *) MESSAGE_BUFFER_RAM_BASE;
volatile unsigned int * message_buffer_ptr_join = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+4);

// zona de memoria compartida para matriz y vectores
volatile int * x 	= (int *) 0x6440; // 16x1 x4=64B: 0x6440 - 0x647F
volatile int * y	= (int *) 0x6480; // 16x1 x4=64B: 0x6480 - 0x64BF
volatile int * A	= (int *) 0x6000; // 16x16x4=1KB: 0x6000 - 0x63FF

// Inicializa zona memoria compartida
void Ini(int ini_printf){
   int i,j;
   if (ini_printf == 0){
	   printf("\nInicializa Matriz y Vector\n");
   }
   else if (ini_printf == 1){
	   printf("\nPRINTF VALORES\n");
   }
   else if (ini_printf == 2){
	   printf("\nPRINTF DIRECCIONES\n");
   }
   for (i=0; i<n; i++){
	   if (ini_printf == 0){
		   x[i] = i;
		   y[i] = 0.0;
	   }
	   else if (ini_printf == 1){
		   // printf datos de entrada en hilo maestro
		   printf("y[%2i]= %i"   , i, y[i]);
		   printf("\tx[%2i]= %2i", i, x[i]);
		   printf("\tA[%2i]= "   , i);
	   }
	   else if (ini_printf == 2){
		   printf("y[%i]= 0x%x"  , i, (unsigned int) &y[i]);
		   printf("\tx[%i]= 0x%x", i, (unsigned int) &x[i]);
		   printf("\tA[%i][]= "  , i);
	   }
	   for(j=0; j<m; j++){
		   if (ini_printf == 0){
			   A[i*m+j]=j;
		   }
		   else if (ini_printf == 1){
			   printf("%i ", A[i*Ta_m+j]);
		   }
		   else if (ini_printf == 2){
			   printf(" 0x%x ", (unsigned int) &A[i*Ta_m+j]);
		   }
	   }
	   if (ini_printf == 1 || ini_printf == 2){
		   printf("\n");
	   }
   }
}

int main()
{ 
    /* direccion del dispositivo mutex */
    alt_mutex_dev* mutex = altera_avalon_mutex_open("/dev/message_buffer_mutex");

    alt_u32 freq=0;
    unsigned int time[6], k;
    char etiqueta_time[6][6]={"tStar","tInic","tFork","tComp","tJoin","tFina"};
    int message_buffer_val = 0x0;
    int message_buffer_val_join = 0x0;
    int dumy = 0;
    int iteraciones = 0, timeInterval=0, timeInterval2=0;

    alt_putstr("Matriz x Vector Paralelo - CPU Mestro - BEGIN\n");
    printf("\tHilos: %i, Iteraciones: %i\n", thread_count, Niter); /* printf valor */

    // lee RAM de sincronizacion
    altera_avalon_mutex_lock(mutex,1); 					 /* bloquea mutex */
    message_buffer_val 		= *(message_buffer_ptr); 	 /* lee valor de sincronizacion */
    message_buffer_val_join = *(message_buffer_ptr_join); /* lee valor en sincronizacion */
    altera_avalon_mutex_unlock(mutex); 					 /* libera mutex */

    printf("\nCPU1 - antes FORK\n");
    printf("\tRAM sincronizacion, message_buffer_val:      %08X\n", message_buffer_val);      /* printf valor */
    printf("\tRAM sincronizacion, message_buffer_val_join: %08X\n", message_buffer_val_join); /* printf valor */

    // Inicializa el timestamp para medir tiempo en ciclos de reloj
    int start = alt_timestamp_start();
    if(start < 0) {
    	printf("\nTimestamp start -> FALLO!, %i\n", start);
    }
    else{
    	freq = alt_timestamp_freq() / 1e6;
    	printf("\nTimestamp start -> OK!, frecuencia de reloj= %u MHz\n", (unsigned int) freq);
    }

    // time0: marca tiempo inicial
    start = alt_timestamp_start(); // resetea el reg del timer pq se satura
    if(start < 0) {
    	printf("Timestamp start -> FALLO!, %i\n", start);
    }
    time[0] = alt_timestamp();

    // Inicializacion Hilo Maestro: Matriz, Vector en zona memoria compartida
    altera_avalon_mutex_lock(mutex,1); // bloquea mutex
    Ini(0); 	// inicializa valores
    //Ini(2); 	// printf direcciones
    Ini(1); 	// printf valores
    altera_avalon_mutex_unlock(mutex); // libera mutex

    // FORK - Sincronizacion de Separacion: *MESSAGE_BUFFER_RAM_BASE = 15
    // time1: marca tiempo inicial FORK
    time[1] = alt_timestamp();
    message_buffer_val = 15; 	 // ID=15(0xF) indica que Fork empieza
    message_buffer_val_join = 0; // ID=0 indica que memoria esta inicializada
    altera_avalon_mutex_lock(mutex,1);			      // bloquea mutex
    *(message_buffer_ptr) 		= message_buffer_val; // inicializa RAM FORK
    *(message_buffer_ptr_join) 	= message_buffer_val_join;    // inicializa RAM JOIN
    altera_avalon_mutex_unlock(mutex); 			      // libera mutex

    // lee buffer para comprobar por printf que son correctos
    altera_avalon_mutex_lock(mutex,1);			  /* bloquea mutex */
    message_buffer_val = *(message_buffer_ptr); 	  /* lee valor en buffer */
    message_buffer_val_join = *(message_buffer_ptr_join); /* lee valor en buffer */
    altera_avalon_mutex_unlock(mutex); 			  /* libera mutex */

    printf("\nCPU1 - maestro - despues FORK\n");
    printf("\tmessage_buffer_val     : %08X\n", message_buffer_val);
    printf("\tmessage_buffer_val_join: %08X\n", message_buffer_val_join);

    // Realiza matriz-vector en este nucleo
    // time2: marca tiempo inicial computo
    time[2] = alt_timestamp();

    // COMPUTO MAESTRO - Operacion matriz-vector
    // k: bucle de computo, realiza multiples veces matriz-vector en esta cpu
    int i, j;
    int local_n 	 = n / thread_count;
    int my_first_row = rank * local_n;		// 1ª fila asignada a este nucleo
    int my_last_row  = (rank+1) * local_n - 1;  // ultima fila asignada a este nucleo

    for (k = 0; k < Niter; k++) {
    	iteraciones++;
    	for (i=my_first_row; i<=my_last_row; i++){
    	   for(j=0; j<m; j++){
    		   y[i] += A[i*m+j] * x[j];
    	   }
    	}
    }

    // time3: marca tiempo del final computo
    time[3] = alt_timestamp();

    // sincronizacion JOIN - barrera para unificacion de hilos
    altera_avalon_mutex_lock(mutex,1);			  /* bloquea mutex */
    message_buffer_val_join = *(message_buffer_ptr_join); /* lee valor en RAM */
    message_buffer_val_join |= 0x1; 			  /* ID=1: sincronizacion Join, termina hilo 0 */
    *(message_buffer_ptr_join) = message_buffer_val_join; /* guarda en RAM el valor */
    altera_avalon_mutex_unlock(mutex); 			  /* libera mutex */

    printf("\nCPU1 - maestro llega a JOIN, iter: %i - message_buffer_val_join: %08X\n",
	iteraciones, message_buffer_val_join); 

    // time4: Nueva marca de tiempo (sincronizacion Join)
    time[4] = alt_timestamp();

    int vista = 0;
    while( (message_buffer_val != 6) ){
    	if (vista != 0){
		usleep(500000); // espera 0,5 seg.
    	}
	// Visualizacion de memoria
	altera_avalon_mutex_lock(mutex,1);		      /* bloquea mutex */
	Ini(1); 					      // printf valores
	message_buffer_val = *(message_buffer_ptr); 	      /* lee valor en RAM */
	message_buffer_val_join = *(message_buffer_ptr_join); /* lee valor en RAM */
	altera_avalon_mutex_unlock(mutex); 		      /* libera mutex */

	// PRINTFs
	printf("\nCPU1 - NiteracionesComputo: %i\n", iteraciones);
	printf("CPU1 - FORK - message_buffer_val     : %08X\n"  , message_buffer_val);
	printf("CPU1 - JOIN - message_buffer_val_join: %08X\n\n", message_buffer_val_join);

	for (k = 1; k < 5; k++){
		timeInterval = (time[k] - time[0])   * 1e-3 / freq;
		timeInterval2= (time[k] - time[k-1]) * 1e-3 / freq;
		alt_putstr("CPU1 - ");
		printf("%6s : time[%i]= %10u clk\t (%6u ms) intervalo= %6u ms\n",
			&etiqueta_time[k][0], k, time[k], timeInterval, timeInterval2);
	}

	if ( (message_buffer_val_join == 0x3 && thread_count == 2 ) ||
		 (message_buffer_val_join == 0x1 && thread_count == 1) ){
		dumy = 6;
		printf("\nCPU1 - CAMBIO!! - message_buffer_val: %08X\n\n", dumy);
		altera_avalon_mutex_lock(mutex,1);	/* bloquea mutex */
		*(message_buffer_ptr) = dumy; 		/* escribe valor en buffer */
		altera_avalon_mutex_unlock(mutex); 	/* libera mutex */
		message_buffer_val = dumy;
	}
	vista++;
    }

    // time4: Nueva marca de tiempo (sincronizacion Join)
    time[4] = alt_timestamp();

    for (k = 1; k < 5; k++){
	timeInterval = (time[k] - time[0])   * 1e-3 / freq;
	timeInterval2= (time[k] - time[k-1]) * 1e-3 / freq;
	alt_putstr("CPU1 - ");
	printf("%6s : time[%i]= %10u clk\t (%6u ms) intervalo= %6u ms\n",
		&etiqueta_time[k][0], k, time[k], timeInterval, timeInterval2);
    }

    timeInterval = (time[4] - time[0]) * 1e-3 / freq;
    printf("\nCPU1 - %6s : time[%i]= %10u clk\t TiempoTotal= %6u ms\n",
	&etiqueta_time[5][0], 5, time[4], timeInterval);
    alt_putstr("\n... ADIOS ...\n");

    return 0;
}
