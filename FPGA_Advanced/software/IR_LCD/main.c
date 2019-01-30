#include <stdio.h>
#include "system.h"
#include "LCD1602_Qsys.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "alt_types.h"
#include "IR_Receiver.h"
#include "string.h"

unsigned int *pUser_GIO_PWM=USER_GIO_PWM_0_BASE; //定义指针指向在Qsys中生成的自定义LED亮度PWM控制模块
unsigned int *pIR_RECEIVE = IR_RECEIVE_0_BASE;
unsigned int check_ready = 0;
char* on_off[] = {"OFF", "ON"};
void delay();
unsigned char Led_ON_OFF=0;
unsigned int key = 0xff;
char disp_buf[15];
char mess_buf[15];
char *pName;
unsigned int Light_Value=10;
void ready_handler(void* context){
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_0_BASE, 0x1);
	printf("interrupt!\n");
	key = *pIR_RECEIVE;
//	check_ready = (check_ready >> 1) | (key & 0x80000000);
//	if ((check_ready & 0xf0000000) == 0xc0000000)
//	{
//		if (key == 0xff)
//			break;
		LCD_Clear();
		pName = getKeyName(key);
		sprintf(disp_buf, "Key: %s", getKeyName(key));
//			sprintf(disp_buf, "$s", getKeyName(key));
		LCD_Disp(1, 0, disp_buf, strlen(disp_buf));
		if (!strcmp(pName, "Power"))
		{
			printf("Power\n");
			if(Led_ON_OFF==1)
			{
				Led_ON_OFF=0;
				IOWR_ALTERA_AVALON_PIO_DATA(PIO_BASE,Led_ON_OFF); //LEDG0 熄灭
			}

			else
			{
				Led_ON_OFF=1;
				IOWR_ALTERA_AVALON_PIO_DATA(PIO_BASE,Led_ON_OFF);//LEDG0 点亮
			}
		}
		if (!strcmp(pName, "Vol Down"))//Vol Down
		{
			Light_Value += 5;
			Light_Value = (Light_Value < 105) ? Light_Value : 105;
			*(pUser_GIO_PWM)=Light_Value*10; //LEDR0 渐变效果，亮度逐渐减弱
		}
		else if (!strcmp(pName, "Vol Up"))//Vol Up
		{
			Light_Value -= 5;
			Light_Value = (Light_Value > 5) ? Light_Value : 5;
			*(pUser_GIO_PWM)=Light_Value*10; //LEDR0 渐变效果，亮度逐渐增强
		}
		else if (!strcmp(pName, "Mute"))//Mute
		{
			Light_Value = 105;
			*(pUser_GIO_PWM)=Light_Value*10;
		}
		delay();
		sprintf(mess_buf, "Int:%3d Pow:%s", 105 - Light_Value, on_off[Led_ON_OFF]);
		printf(mess_buf);
		LCD_Disp(2, 0, mess_buf, strlen(mess_buf));
		delay();
//	}
}

void ready_config(){
	IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_0_BASE, 0x1);
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_0_BASE, 0x0);
	alt_ic_isr_register(PIO_0_IRQ_INTERRUPT_CONTROLLER_ID, PIO_0_IRQ, ready_handler, NULL, 0x0);
}
int main()
{
//	unsigned char LCD_Data1[8] = {"Love"};
//	unsigned char LCD_Data2[8] = {"Lucy"};


	ready_config();
//	LCD_Disp(1, 0, LCD_Data1, 4);
//	delay();
//	LCD_Disp(2, 5, LCD_Data2, 4);

	LCD_Clear();
	printf("Hello from Nios II!\n");
	*(pUser_GIO_PWM)=Light_Value*10; //LEDR0 渐变效果，亮度逐渐减弱
	while(1)
	{


	}

  return 0;
}

//while(1)
//{
//	for(Delay_Time=0;Delay_Time<30000;Delay_Time++);
//	if(Light_Value<100)
//	{
//		*(pUser_GIO_PWM)=Light_Value*10; //LEDR0 渐变效果，亮度逐渐减弱
//		Light_Value++;
//	}
//
//	else
//	{
//		Light_Value=1;
//		if(Led_ON_OFF==1)
//		{
//			Led_ON_OFF=0;
//			IOWR_ALTERA_AVALON_PIO_DATA(PIO_BASE,Led_ON_OFF); //LEDG0 熄灭
//		}
//
//		else
//		{
//			Led_ON_OFF=1;
//			IOWR_ALTERA_AVALON_PIO_DATA(PIO_BASE,Led_ON_OFF);//LEDG0 点亮
//		}
//
//	}
//
//
//
//}

void delay()
{
	int t = 100000;
	while(t--);
}
