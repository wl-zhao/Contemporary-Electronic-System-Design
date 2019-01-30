/*
 * IR_Receiver1.c
 *
 *  Created on: 2018Äê7ÔÂ9ÈÕ
 *      Author: LAB512
 */
#include "IR_Receiver.h"
#include <stdio.h>
char* keys[] = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
				"A", "B", "C", "Power", "CH Up", "CH Down", "Vol Up", "Vol Down",
				"Mute", "Menu", "Return", "Play", "Ad Left", "Ad right"};
char* getKeyName(unsigned int key_code)
{
	unsigned int raw = (key_code & 0x00ff0000) >> 16;
	printf("raw data: %x", raw);
	if (raw < 0x0a)
		return keys[raw];
	int index = 0;
	switch(raw)
	{
	case 0x0f:
		index = 10;
		break;
	case 0x13:
		index = 11;
		break;
	case 0x10:
		index = 12;
		break;
	case 0x12:
		index = 13;
		break;
	case 0x1a:
		index = 14;
		break;
	case 0x1e:
		index = 15;
		break;
	case 0x1b:
		index = 16;
		break;
	case 0x1f:
		index = 17;
		break;
	case 0x0c:
		index = 18;
		break;
	case 0x11:
		index = 19;
		break;
	case 0x17:
		index = 20;
		break;
	case 0x16:
		index = 21;
		break;
	case 0x14:
		index = 22;
		break;
	case 0x18L:
		index = 23;
		break;
	default:
		break;
	}
	return keys[index];
}




