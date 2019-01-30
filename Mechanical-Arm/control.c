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
#include  "geometry.h"
unsigned char control[] = {0x00, 0xff, 0xff, 0xfe, 0x07, 0x03, 0x1e, 0x00, 0x02, 0x00, 0x02, 0xd5};
#include "control.h"
#include <project.h>

int IDS[] = {WAIST_ID, SHOUDER_ID, ELBOW_ID, WRIST_ID, PAW_ID, PAW_ROT_ID};
uint8 ID_HASH[] = {0, 0, 4, 2, 3, 1, 5, 0};
float angles[6] = {0};
void setAngle(uint8 id, int angle)
{
    if (angle < 0 || angle > 300)
        return;
    int angle_hex = angle * 1023 / 300;
    uint8 angle_H = angle_hex >> 8;
    uint8 angle_L = angle_hex & 0xff;
    uint8 checkSum = ~(id + 0x05 + 0x03 + 0x1e + angle_L + angle_H);
    uint8 control_word[] = {0x00, 0xff, 0xff, id, 0x05, 0x03, 0x1e, angle_L, angle_H, checkSum};
    UART_PutArray(control_word, 10);
    angles[ID_HASH[id]] = angle - 150;
}

//min velocity = 1, max velocity = 1023. 0 == 1023
void setVelocity(uint8 id, int velocity)
{
    uint8 v_H = velocity >> 8;
    uint8 v_L = velocity & 0xff;
    uint8 checkSum = ~(id + 0x05 + 0x03 + 0x20 + v_L + v_H);
    uint8 control_word[] = {0x00, 0xff, 0xff, id, 0x05, 0x03, 0x20, v_L, v_H, checkSum};
    UART_PutArray(control_word, 10);
}

void setAngleVelocity(uint8 id, int angle, int velocity)
{
    if (angle < 0 || angle > 300)
        return;
    int angle_hex = angle * 1023 / 300;
    uint8 angle_H = angle_hex >> 8;
    uint8 angle_L = angle_hex & 0xff;
    uint8 v_H = velocity >> 8;
    uint8 v_L = velocity & 0xff;
    uint8 checkSum = ~(id + 0x07 + 0x03 + 0x1e + angle_L + angle_H + v_L + v_H);
    uint8 control_word[] = {0x00, 0xff, 0xff, id, 0x07, 0x03, 0x1e, angle_L, angle_H, v_L, v_H, checkSum};
    UART_PutArray(control_word, 12);
    angles[ID_HASH[id]] = angle - 150;
    CyDelay(10);
}

void setAngleVelocityHex(uint8 id, int angle_hex, int velocity)
{
    if (angle_hex < 0 || angle_hex > 1023)
        return;
    uint8 angle_H = angle_hex >> 8;
    uint8 angle_L = angle_hex & 0xff;
    uint8 v_H = velocity >> 8;
    uint8 v_L = velocity & 0xff;
    uint8 checkSum = ~(id + 0x07 + 0x03 + 0x1e + angle_L + angle_H + v_L + v_H);
    uint8 control_word[] = {0x00, 0xff, 0xff, id, 0x07, 0x03, 0x1e, angle_L, angle_H, v_L, v_H, checkSum};
    UART_PutArray(control_word, 12);
    angles[ID_HASH[id]] = angle_hex * 300 / 1023 - 150;
    CyDelay(10);
}


void setAngleLim(uint8 id, int angle_min, int angle_max)
{
    if (angle_min < 0 || angle_max > 300 || angle_min >= angle_max)
        return;
    int angle_min_hex = angle_min * 1023 / 300;
    int angle_max_hex = angle_max * 1023 / 300;
    uint8 angle_min_H = angle_min_hex >> 8;
    uint8 angle_min_L = angle_min_hex & 0xff;
    uint8 angle_max_H = angle_max_hex >> 8;
    uint8 angle_max_L = angle_max_hex & 0xff;
    uint8 checkSum = ~(id + 0x07 + 0x03 + 0x06 + angle_min_L +
        angle_min_H + angle_max_L + angle_max_H);
    uint8 control_word[] = {0x00, 0xff, 0xff, id, 0x07, 0x03, 0x06, angle_min_L,
        angle_min_H, angle_max_L, angle_max_H, checkSum};
    UART_PutArray(control_word, 12);
}

void moveToPos(int theta, int x, int y, _Bool *flag, int v)
{
    setAngleVelocity(WAIST_ID, theta + 150, v);
    float alpha, beta;
    getAngleFromPos(x, y, &alpha, &beta, flag);
    if (!*flag)
        return;
    setAngleVelocity(SHOUDER_ID, 150 + alpha, v);
    CyDelay(10);
    setAngleVelocity(ELBOW_ID, 150 + beta, v);
    CyDelay(10);
    angles[1] = alpha;
    angles[2] = beta;
}

void setAngleHex(uint8 id, int angle_hex)
{
    uint8 angle_H = angle_hex >> 8;
    uint8 angle_L = angle_hex & 0xff;
    uint8 checkSum = ~(id + 0x05 + 0x03 + 0x1e + angle_L + angle_H);
    uint8 control_word[] = {0x00, 0xff, 0xff, id, 0x05, 0x03, 0x1e, angle_L, angle_H, checkSum};
    UART_PutArray(control_word, 10);
}

void adjustPaw(int v, int offset)
{
    angles[3] = 180 - angles[1] - angles[2] - offset;
    setAngleVelocity(WRIST_ID, 150 - angles[3], v);
}

void init()
{
    setAngleVelocityHex(WAIST_ID,614, 0x100);
    CyDelay(10);
    setAngleVelocityHex(SHOUDER_ID, 367, 0x100);
    CyDelay(10);
    setAngleVelocityHex(ELBOW_ID, 826, 0x100);
    CyDelay(10);
    setAngleVelocityHex(WRIST_ID, 454, 0x100);
    CyDelay(10);
    setAngleVelocityHex(PAW_ROT_ID, 844, 0x100);
    CyDelay(10);
    setAngleVelocityHex(PAW_ID, 503, 0x100);
    CyDelay(10);
}

void paw_action(_Bool grab)
{
    if (grab)
        setAngleVelocity(PAW_ID, 100, 100);
    else
        setAngleVelocity(PAW_ID, 150, 300);
}

int USRead()
{
    int data = 0;
    int i;
    Control_Reg_1_Write(1);
    CyDelayUs(45);
    Control_Reg_1_Write(0);
    for (i = 0; i < 300000; i++)
    {
        if (Echo_Read())
        {
            data++;
        }
        CyDelayUs(1);
    }
    return data * 0.47642 + 20.43505;
}

void findPlatform(int *theta, int *height)
{
    _Bool flag;
    int angle = -150;
    int height1 = 220;
    int distance;
    int last_distance[] = {0, 0, 0, 0};
    int threshold = 20;
    moveToPos(-150, 112, height1, &flag, 100);
    CyDelay(1000);
    while(1)
    {
        moveToPos(angle, 112, height1, &flag, 100);
        distance = USRead();
        if (distance > height1)
        {
            angle += 5;
            continue;
        }
        LCD_ClearDisplay();
        if (angle == -150)
        {
            last_distance[0] = last_distance[1] = last_distance[2] = last_distance[3] = distance;
        }
        else
        {
            last_distance[0] = last_distance[1];
            last_distance[1] = last_distance[2];
            last_distance[2] = last_distance[3];
            last_distance[3] = distance;
        }
        LCD_PrintNumber(last_distance[0]);
        LCD_PutChar(' ');
        LCD_PrintNumber(last_distance[1]);
        LCD_PutChar(' ');
        LCD_Position(1u, 0u);
        LCD_PrintNumber(last_distance[2]);
        LCD_PutChar(' ');
        LCD_PrintNumber(last_distance[3]);
        LCD_PutChar(' ');
        if ((abs(last_distance[0] - last_distance[1]) > threshold) &&
        (abs(last_distance[1] - last_distance[2]) < threshold) &&
        (abs(last_distance[2] - last_distance[3]) < threshold))
        {
            LCD_ClearDisplay();
            LCD_PrintNumber(last_distance[0]);
            LCD_PutChar(' ');
            LCD_PrintNumber(last_distance[1]);
            LCD_PutChar(' ');
            LCD_Position(1u, 0u);
            LCD_PrintNumber(last_distance[2]);
            LCD_PutChar(' ');
            LCD_PrintNumber(last_distance[3]);
            LCD_PutChar(' ');
            break;
        }
        CyDelay(10);
        angle += 5;
    }
    *theta = angle;
    *height = height1 - distance + 90;
//    moveToPos(angle, 112, *height, &flag, 100);
//    adjustPaw(200, DEFALT_OFFSET);
    CyDelay(100);
}

void findTarget(int *theta, int start_angle)
{
    _Bool flag;
    int angle = start_angle;
    int height1 = 220;
    int distance;
    int last_distance[] = {0, 0, 0, 0};
    int threshold = 20;
    moveToPos(angle, 112, height1, &flag, 100);
    adjustPaw(200, DEFALT_OFFSET);
    CyDelay(2000);
    while(angle < 150)
    {
        moveToPos(angle, 112, height1, &flag, 100);
        adjustPaw(200, DEFALT_OFFSET);
        distance = USRead();
        if (distance >  5 * height1)
            break;
        CyDelay(10);
        angle += 5;
    }
    *theta = angle;
    CyDelay(100);
}

void findPlatformTarget(int *angle1, int *angle2, int *height2)
{
    _Bool flag;
    uint8 finished_flag = 0;
    int angle = -150;
    int height = 220;
    int distance;
    int last_distance[] = {0, 0, 0, 0};
    int threshold = 60;
    int stable_thres = 20;
    int last_stable_state = 0;
    int stable_state = 0;
    int count = 0;
    int putPosCount = 4;
    _Bool count_en = 0;
    moveToPos(-150, 112, height, &flag, 100);
    CyDelay(4000);
    while(1)
    {
        if (finished_flag == 0x11)
            return;
        moveToPos(angle, 112, height, &flag, 100);
        distance = USRead();
        if (distance > 5 * height && (!(finished_flag & 0x1)))
        {
            *angle1 = angle;
            angle += 5;
            finished_flag |= 0x1;
            continue;
        }
        LCD_ClearDisplay();
        if (angle == -150)
        {
            last_distance[0] = last_distance[1] = last_distance[2] = last_distance[3] = distance;
            last_stable_state = distance;
            stable_state = distance;
        }
        else
        {
            last_distance[0] = last_distance[1];
            last_distance[1] = last_distance[2];
            last_distance[2] = last_distance[3];
            last_distance[3] = distance;
            if (abs(distance - last_distance[2]) < stable_thres)
            {
                stable_state = distance;
            }
        }
        LCD_Position(0u, 0u);
        LCD_PrintNumber(last_distance[0]);
        LCD_PutChar(' ');
        LCD_PrintNumber(last_distance[1]);
        LCD_PutChar(' ');
        LCD_PrintNumber(last_stable_state);
        LCD_Position(1u, 0u);
        LCD_PrintNumber(last_distance[2]);
        LCD_PutChar(' ');
        LCD_PrintNumber(last_distance[3]);
        LCD_PutChar(' ');
        LCD_PrintNumber(stable_state);
//        if ((abs(last_distance[0] - last_distance[1]) > threshold) &&
//        (abs(last_distance[1] - last_distance[2]) < threshold) &&
//        (abs(last_distance[2] - last_distance[3]) < threshold))
        if ((abs(last_stable_state - stable_state) > threshold) && ((finished_flag & 0x10) == 0x00))
        {
            if (angle < -115)
            {   
                angle+=5;
                continue;
            }
            count_en = 1;
            LCD_Position(0u, 0u);
            LCD_PrintNumber(last_distance[0]);
            LCD_PutChar(' ');
            LCD_PrintNumber(last_distance[1]);
            LCD_PutChar(' ');
            LCD_PrintNumber(last_stable_state);
            LCD_Position(1u, 0u);
            LCD_PrintNumber(last_distance[2]);
            LCD_PutChar(' ');
            LCD_PrintNumber(last_distance[3]);
            LCD_PutChar(' ');
            LCD_PrintNumber(stable_state);
//            *angle2 = angle;
//            *height2 = height - distance + 80;
//            finished_flag |= 0x10;
        }
        if (count_en && ((finished_flag & 0x10) == 0x00))
        {
            count++;
        }
        if (count == putPosCount && ((finished_flag & 0x10) == 0x00))
        {
            *angle2 = angle;
            *height2 = height - distance + 80;
            finished_flag |= 0x10;
        }
        CyDelay(10);
        angle += 5;
        last_stable_state = stable_state;
    }
    CyDelay(200);
}

_Bool grabTest(int angle2, int height2)
{
    _Bool flag = 1;
    moveToPos(angle2, DEFAULT_X, height2, &flag, 200);
    adjustPaw(200, DEFALT_OFFSET);
    CyDelay(2000);
    if (USRead() > height2 || USRead() > height2 || USRead() > height2)
        return 1;
    return 0;
}

int USRead1()
{
    int data = 0;
    int i;
    Control_Reg_2_Write(1);
    CyDelayUs(45);
    Control_Reg_2_Write(0);
    for (i = 0; i < 300000; i++)
    {
        if (Echo_1_Read())
        {
            data++;
        }
        CyDelayUs(1);
    }
    return data * 0.47642 + 20.43505;
}

int abs(int a)
{
    return (a > 0) ? a : -a; 
}

/* [] END OF FILE */
