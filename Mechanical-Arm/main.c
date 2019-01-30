/* ========================================
 *
 * Copyright YOUR COMPANY, THE YEAR
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/
#include <project.h>
#include "control.h"



int main()
{
    CyGlobalIntEnable; /* Enable global interrupts. */
    int h;
    int i;
    _Bool flag = 1;
    int width = 112;
    int height1 = 72;
    int height2 = 220;
    int angle1 = -150;
    int distance = 0;
    int last_distance = 0;
    int angle2 = -150;
    _Bool grab_test;
    /* Place your initialization/startup code here (e.g. MyInst_Start()) */
    
    UART_Start();
    UART_1_Start();
    LCD_Start();
    Control_Reg_Write(0);
    init();
    CyDelay(4000);
    distance = last_distance = USRead1();
    UART_1_PutChar('G');
    while(1)
    {
        distance = USRead1();
        LCD_ClearDisplay();
        LCD_PrintNumber(distance);
        if (abs(last_distance - distance) > 50)
        {
            UART_1_PutChar('S');
            break;
        }
        UART_1_PutChar('G');
        last_distance = distance;
    }
    //init
    moveToPos(-150, width, height2, &flag, 200);
    adjustPaw(300, DEFALT_OFFSET);
    CyDelay(2000);
    findPlatformTarget(&angle1, &angle2, &height2);
    while(1)
    {
        moveToPos(angle1, 112, 220, &flag, 100);
        adjustPaw(300, DEFALT_OFFSET);
        CyDelay(2000);
        moveToPos(angle1, 112, height1, &flag, 100);
        adjustPaw(300, DEFALT_OFFSET);
        CyDelay(1000);
        paw_action(1);
        CyDelay(2000);
        moveToPos(angle1, 112, 180 , &flag, 100);
        moveToPos(angle1, 112, 220 , &flag, 100);
        adjustPaw(300, DEFALT_OFFSET);
        CyDelay(2000);
        grab_test = grabTest(angle2, height2 + 50);
        if (grab_test == 0)
        {
            paw_action(0);
            findTarget(&angle1, angle1 - 20);
            CyDelay(3000);
        }
        else
            break;
    }
    
    moveToPos(angle2, 112, 220, &flag, 100);
    adjustPaw(500, DEFALT_OFFSET);
    CyDelay(2000);
    paw_action(0);
    setAngleHex(WRIST_ID, 1023);
    CyDelay(2000);
    init();
    for (i = 0; i < 4; i++)
    {
        UART_1_PutChar('G');
    }
     
    
    
//    //find platform
//    findPlatform(&angle2, &height2);
//    CyDelay(1000);
//    //find target
//    findTarget(&angle1);
//    //move to target
//    moveToPos(angle1, 112, height1, &flag, 100);
//    adjustPaw(200, DEFALT_OFFSET);
//    CyDelay(2000);
//    //grab
//    paw_action(1);
//    CyDelay(1000);
//    //move to platform, divided into 4 frames
//    moveToPos(angle1, 112, 220, &flag, 100);
//    adjustPaw(200, DEFALT_OFFSET);
//    CyDelay(1000);
//    moveToPos(angle2, 112, 220, &flag, 100);
//    adjustPaw(200, DEFALT_OFFSET);
//    CyDelay(2000);
//    moveToPos(angle2, 112, height2, &flag, 100);
//    adjustPaw(200, DEFALT_OFFSET);
//    CyDelay(2000);
    //loose
//    paw_action(0);
//    moveToPos(angle2, 112, 220, &flag, 100);
//    CyDelay(2000);
    while(1);
}


/* [] END OF FILE */
