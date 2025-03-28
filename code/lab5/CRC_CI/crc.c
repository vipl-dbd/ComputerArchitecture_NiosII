/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2008 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/


/**********************************************************************
 *
 * Filename:    crc.c
 * 
 * Description: Slow and fast implementations of the CRC standards.
 *
 * Notes:       The parameters for each supported CRC standard are
 *        defined in the header file crc.h.  The implementations
 *        here should stand up to further additions to that list.
 *
 * 
 * Copyright (c) 2000 by Michael Barr.  This software is placed into
 * the public domain and may be used for any purpose.  However, this
 * notice must not be changed or removed and no warranty is either
 * expressed or implied by its publication or distribution.
 **********************************************************************/
 
#include "crc.h"

// MIO
#include "stdio.h"
#define PRINT_RESULTS TRUE


/*
 * Derive parameters from the standard-specific parameters in crc.h.
 */
#define WIDTH    (8 * sizeof(crc))
#define TOPBIT   (1 << (WIDTH - 1))
#define DOWNBIT  0x7FFFFFFF

#if (REFLECT_DATA == TRUE)
#undef  REFLECT_DATA
#define REFLECT_DATA(X)     ((unsigned char) reflect((X), 8))
#else
#undef  REFLECT_DATA
#define REFLECT_DATA(X)     (X)
#endif

#if (REFLECT_REMAINDER == TRUE)
#undef  REFLECT_REMAINDER
#define REFLECT_REMAINDER(X)  ((crc) reflect((X), WIDTH))
#else
#undef  REFLECT_REMAINDER
#define REFLECT_REMAINDER(X)  (X)
#endif


/*********************************************************************
 *
 * Function:    reflect()
 * 
 * Description: Reorder the bits of a binary sequence, by reflecting
 *        them about the middle position.
 *
 * Notes:   No checking is done that nBits <= 32.
 *
 * Returns:   The reflection of the original data.
 *
 *********************************************************************/
static unsigned long
reflect(unsigned long data, unsigned char nBits)
{
  unsigned long  reflection = 0x00000000;
  unsigned char  bit;

  /*
   * Reflect the data about the center bit.
   */
  for (bit = 0; bit < nBits; ++bit)
  {
    /*
     * If the LSB bit is set, set the reflection of it.
     */
    if (data & 0x01)
    {
      reflection |= (1 << ((nBits - 1) - bit));
    }

    data = (data >> 1);
  }

  return (reflection);

} /* reflect() */


/*********************************************************************
 *
 * Function:    crcSlow()
 * 
 * Description: Compute the CRC of a given message.
 *
 * Notes:   
 *
 * Returns:   The CRC of the message.
 *
 *********************************************************************/
crc
crcSlow(unsigned char const message[], int nBytes)
{


  crc            remainder = INITIAL_REMAINDER;
  int            byte;
  unsigned char  bit;
  // MIO
  unsigned char  dumy;



    /*
     * Perform modulo-2 division, a byte at a time.
     */
    for (byte = 0; byte < nBytes; ++byte)
    {
  	if(PRINT_RESULTS)
  	{
  	  printf("crcSlow - byte= %i, input data= 0x%x, inicio= 0x%lx, pol= 0x%x\n", byte, message[byte], remainder, POLYNOMIAL);
  	}

        /*
         * Bring the next byte into the remainder.
         */
        remainder ^= (REFLECT_DATA(message[byte]) << (WIDTH - 8));

  	if(PRINT_RESULTS)
  	{
  	  printf("\tPre-bucle - remainder= 0x%lx, reflected data= 0x%x\n", remainder, REFLECT_DATA(message[byte]));
  	}

        /*
         * Perform modulo-2 division, a bit at a time.
         */
        for (bit = 8; bit > 0; --bit)
        {
            /*
             * Try to divide the current data bit.
             */
	    dumy = (unsigned char) ((remainder & TOPBIT)>>31); // dumy: bit mas significativo de la operacion

            if (remainder & TOPBIT)
            {
                remainder = (remainder << 1) ^ POLYNOMIAL;
            }
            else
            {
                remainder = (remainder << 1);
            }

  	    if(PRINT_RESULTS)
  	    {
  	      printf("\tEN-bucle - topbit= 0x%x, remainder= 0x%lx\n", dumy, remainder);
  	    }

        }
    }

    /*
     * The final remainder is the CRC result.
     */

    if(PRINT_RESULTS)
    {
      printf("\tFIN - reflect_remainder= 0x%lx, output= 0x%lx\n", REFLECT_REMAINDER(remainder), REFLECT_REMAINDER(remainder) ^ FINAL_XOR_VALUE);
    }

    return (REFLECT_REMAINDER(remainder) ^ FINAL_XOR_VALUE);

}   /* crcSlow() */


crc  crcTable[256];


/*********************************************************************
 *
 * Function:    crcInit()
 * 
 * Description: Populate the partial CRC lookup table.
 *
 * Notes:   This function must be rerun any time the CRC standard
 *        is changed.  If desired, it can be run "offline" and
 *        the table results stored in an embedded system's ROM.
 *
 * Returns:   None defined.
 *
 *********************************************************************/
void
crcInit(void)
{
    crc        remainder;
  int        dividend;
  unsigned char  bit;


    /*
     * Compute the remainder of each possible dividend.
     */
    for (dividend = 0; dividend < 256; ++dividend)
    {
        /*
         * Start with the dividend followed by zeros.
         */
        remainder = dividend << (WIDTH - 8);

        /*
         * Perform modulo-2 division, a bit at a time.
         */
        for (bit = 8; bit > 0; --bit)
        {
            /*
             * Try to divide the current data bit.
             */     
            if (remainder & TOPBIT)
            {
                remainder = (remainder << 1) ^ POLYNOMIAL;
            }
            else
            {
                remainder = (remainder << 1);
            }
        }

        /*
         * Store the result into the table.
         */
        crcTable[dividend] = remainder;
    }

}   /* crcInit() */


/*********************************************************************
 *
 * Function:    crcFast()
 * 
 * Description: Compute the CRC of a given message.
 *
 * Notes:   crcInit() must be called first.
 *
 * Returns:   The CRC of the message.
 *
 *********************************************************************/
crc
crcFast(unsigned char const message[], int nBytes)
{
    crc            remainder = INITIAL_REMAINDER;
    unsigned char  data;
  int            byte;


    /*
     * Divide the message by the polynomial, a byte at a time.
     */
    for (byte = 0; byte < nBytes; ++byte)
    {
        data = REFLECT_DATA(message[byte]) ^ (remainder >> (WIDTH - 8));
      remainder = crcTable[data] ^ (remainder << 8);
    }

    /*
     * The final remainder is the CRC.
     */
    return (REFLECT_REMAINDER(remainder) ^ FINAL_XOR_VALUE);

}   /* crcFast() */


/*********************************************************************
 *
 * Function:    crcCIsimulado()
 * 
 * Description: Simula en C la implementacion Verilog.
 *
 * Notes:   	1/4/2022
 *
 * Returns:   	The CRC of the message.
 *
 *********************************************************************/

crc 
crcCIsimulado(unsigned char const message[], int nBytes)
{

  crc            remainder = INITIAL_REMAINDER;
  crc		 dumy2, dato_desplazado;
  int            byte;
  unsigned char  bit;
  // MIO
  unsigned char  dumy;

    /*
     * Perform modulo-2 division, a byte at a time.
     */
    for (byte = 0; byte < nBytes; ++byte)
    {
  	if(PRINT_RESULTS)
  	{
  	  printf("crcSimulado - byte= %i, input data= 0x%x, inicio= 0x%lx, pol= 0x%x\n", byte, message[byte], remainder, POLYNOMIAL);
  	}

        /*
         * Bring the next byte into the remainder.
         */

  	if(PRINT_RESULTS)
  	{
  	  printf("\tPre-bucle - remainder= 0x%lx, reflected data= 0x%x\n", remainder, REFLECT_DATA(message[byte]));
  	}

        /*
         * Perform modulo-2 division, a bit at a time.
         */

	// El dato de entrada se alinea con el bit mas significativo del remainder

	dato_desplazado = (REFLECT_DATA(message[byte]) << (WIDTH - 8));

        for (bit = 8; bit > 0; --bit)
        {
            /*
             * Try to divide the current data bit.
             */

	    // new_bit= dato_desplazado[31]
	    // stage_input[31]= remainder[31]
	    // dumy   = stage_output[0]= (new_bit ^ stage_input[31]) >> 31
	    // dumy2  = new_bit ^ stage_input[31]
 
            dumy2 = remainder ^ dato_desplazado;
	    dumy  = (unsigned char) ((dumy2 & TOPBIT)>>31);

	    // si stage_output[0] ==? 1
 
            if (dumy) // stage_output[0] ==? 1
            {
                remainder = (remainder & DOWNBIT) ^ (POLYNOMIAL >> 1);
            }

	    // en todos los casos, nuevo remainder= (remainder << 1) | dumy
            remainder = (remainder << 1) | dumy;

  	    if(PRINT_RESULTS)
  	    {
  	      printf("\tEN-bucle - dato_despla= 0x%lx, topbit= 0x%x, remaind= 0x%lx\n", dato_desplazado, dumy, remainder);
  	    }

	    // en todos los casos, el dato de entrada se desplaza a la izquierda
	    dato_desplazado = (dato_desplazado << 1);

        }
    }

    /*
     * The final remainder is the CRC result.
     */

    if(PRINT_RESULTS)
    {
      printf("\tFIN - reflect_remainder= 0x%lx, output= 0x%lx\n", REFLECT_REMAINDER(remainder), REFLECT_REMAINDER(remainder) ^ FINAL_XOR_VALUE);
    }

    return (REFLECT_REMAINDER(remainder) ^ FINAL_XOR_VALUE);

}   /* crcCIsimulado() */
