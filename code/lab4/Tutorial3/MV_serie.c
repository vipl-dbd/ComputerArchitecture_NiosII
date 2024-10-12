/*
 * AC - Practica 4
 *
 * "Multiplicacion Matriz x Vector"
 * Version secuencial
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

// Timer - incluir el timestamp en BSP: boton dcho en BSP folder, Nios2 > BSP editor > cambiar system timer y timestamp timer
#include <altera_avalon_timer.h>
#include <sys/alt_timestamp.h>
#include <alt_types.h>

#define Ta_m 16 // numero de columnas de matriz
#define Ta_n 16 // numero filas de matriz y tamaño del vector

int m		= Ta_m;
int n		= Ta_n;
int thread_count= 1;
int Niter	= 2000; // veces repite matriz-vector

// zona de memoria compartida para matriz y vectores
volatile int * x= (int *) 0x6440; // 16x1 x4=64B: 0x6440 - 0x647F
volatile int * y= (int *) 0x6480; // 16x1 x4=64B: 0x6480 - 0x64BF
volatile int * A= (int *) 0x6000; // 16x16x4=1KB: 0x6000 - 0x63FF

// Inicializa zona compartida
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
		   x[i] = (int)i;
		   y[i] = 0.0;
	   }
	   else if (ini_printf == 1){
		   // printf no soporta %f, por eso se hace printf del valor entero
		   printf("y[%2i]= %i"   , i, (int)y[i]);
		   printf("\tx[%2i]= %2i", i, (int)x[i]);
		   printf("\tA[%2i]= "   , i);
	   }
	   else if (ini_printf == 2){
		   printf("y[%i]= 0x%x"  , i, (unsigned int) &y[i]);
		   printf("\tx[%i]= 0x%x", i, (unsigned int) &x[i]);
		   printf("\tA[%i][]= "  , i);
	   }
	   for(j=0; j<m; j++){
		   if (ini_printf == 0){
			   A[i*m+j]=(int)j;
		   }
		   else if (ini_printf == 1){
			   printf("%i ", (int)A[i*Ta_m+j]);
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
	alt_u32 freq=0;
	unsigned int time[6], k;
	char etiqueta_time[6][6]={"tStar","tInic","tFork","tComp","tJoin","tFina"};
	int iteraciones = 0, timeInterval=0;

	alt_putstr("Matriz x Vector - Serie - BEGIN\n");

	// Inicializa el timestamp para medir tiempo en ciclos
	int start = alt_timestamp_start();
	if(start < 0) {
    		printf("\nTimestamp start -> FALLO!, %i\n", start);
	}
    	else{
    		freq = alt_timestamp_freq() / 1e6;
    		printf("\nTimestamp start -> OK!, frecuencia= %u MHz\n", (unsigned int) freq);
    	}

	// time1: marca tiempo inicial
	start = alt_timestamp_start(); // resetea el reg del timer pq se satura
	if(start < 0) {
    		printf("Timestamp start -> FALLO!, %i\n", start);
    	}
	time[0] = alt_timestamp();
	// Inicializacion Hilo Maestro: Matriz, Vector
	Ini(0); // inicializa valores
	//Ini(2); // printf direcciones
	Ini(1); // printf valores
	
	// FORK - Sincronizacion de Separacion: *MESSAGE_BUFFER_RAM_BASE = 15
	// time2: marca tiempo inicial FORK
	time[1] = alt_timestamp();

	// Realiza matriz-vector en esta cpu
	// time3: marca tiempo inicial computo
	time[2] = alt_timestamp();

	// k: bucle de computo
	// Realiza matriz-vector en esta cpu
	int i,j,rank=0;
	int local_n = n / thread_count;
	int my_first_row = rank * local_n;
	int my_last_row = (rank+1) * local_n - 1;

	for (k = 0; k < Niter; k++) {
		iteraciones++;
		for (i=my_first_row; i<=my_last_row; i++){
		   for(j=0; j<m; j++){
			   y[i] += A[i*m+j] * x[j];
		   }
		}
	}

	// time4: marca tiempo final computo
	time[3] = alt_timestamp();

	// time5: Nueva marca de tiempo (con sincronizacion Join)
	time[4] = alt_timestamp();

	printf("\nmiCPU1 - NiteracionesComputo: %i\n", iteraciones); /* printf valor */

	for (k = 0; k < 5; k++){
			timeInterval = (time[k] - time[0]) * 1e-3 / freq;
			alt_putstr("miCPU1 - ");
			printf("%6s : time[%i]= %10u clk\t interval= %6u ms\n", &etiqueta_time[k][0], k, time[k], timeInterval); 
	}

	time[5] = alt_timestamp();
	timeInterval = (time[5] - time[0]) * 1e-3 / freq;
	printf("\nmiCPU1 - %6s : time[%i]= %10u clk\t interval= %6u ms\n", &etiqueta_time[5][0], 5, time[5], timeInterval); 
	alt_putstr("\n... ADIOS ...\n");

	return 0;
}
