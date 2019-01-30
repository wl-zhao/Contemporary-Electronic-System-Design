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
#ifndef CONTROL_H_
#define CONTROL_H_
#define WAIST_ID 7
#define SHOUDER_ID 5
#define ELBOW_ID 3
#define WRIST_ID 4
#define PAW_ID 6
#define PAW_ROT_ID 2 
#define DEFALT_OFFSET 36
#define DEFAULT_X 112
    

    
#include <project.h>
    
void setAngleLim(uint8 id, int angle_min, int angle_max);
void setAngle(uint8 id, int angle);
void setAngleHex(uint8 id, int angle_hex);
void setVelocity(uint8 id, int velocity);
void setAngleVelocityHex(uint8 id, int angle, int velocity);
void setAngleVelocity(uint8 id, int angle, int velocity);
void adjustPaw(int v, int offset);
void moveToPos(int theta, int x, int y, _Bool *flag, int v);
void paw_action(_Bool grab);
void init();
void findPlatform(int *angle, int *height);
void findTarget(int *angle, int start_angle);
void findPlatformTarget(int *angle1, int *angle2, int *height2);
int USRead();
int USRead1();
int abs(int a);
_Bool grabTest(int angle2, int height2);
#endif
/* [] END OF FILE */
