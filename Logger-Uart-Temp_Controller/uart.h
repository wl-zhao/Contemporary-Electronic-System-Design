/*
 * uart.h
 *
 *  Created on: 2018-7-7
 *      Author: John Williams
 */

#ifndef UART_H_
#define UART_H_

#include "inc/hw_ints.h"
#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
#include "driverlib/debug.h"
#include "driverlib/fpu.h"
#include "driverlib/gpio.h"
#include "driverlib/interrupt.h"
#include "driverlib/sysctl.h"
#include "driverlib/uart.h"
#include "driverlib/rom.h"
#include "grlib/grlib.h"
#include "drivers/cfal96x64x16.h"

void
UARTSend(const unsigned char *pucBuffer, unsigned long ulCount);
void
UARTInit(void);
#endif /* UART_H_ */
