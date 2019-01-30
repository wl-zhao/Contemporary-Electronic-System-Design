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
#include "geometry.h"
#include "math.h"
int a = 78;
int b = 69;
int h = 140;

int getAngleValue(int Angle)
{
    return (Angle - 150) / 300 * 1024 + 512;
}

void getAngleFromPos(float x, float y, float *alpha, float *beta, _Bool *flag)
{
    *flag &= (x * x + (y - h) * (y - h) >= (a * a + b * b));
    if (*flag != 1)
        return;
    *beta = (acos((x * x + (y - h) * (y - h) - a * a - b * b) / ( 2 * a * b)));
    *alpha = 90 - (atan((y - h) / x)) / pi * 180 
    - (atan(b * sin(*beta) / (a + b * cos(*beta)))) / pi * 180;
    *beta = *beta / pi * 180;
}

/* [] END OF FILE */
