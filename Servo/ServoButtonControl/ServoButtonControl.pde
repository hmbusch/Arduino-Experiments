/*
 * Code snippet to demonstrate the control of a servo using three push-buttons.
 * One button makes the servo turn right by 5 degrees, another makes it turn left
 * and the third one moves the servo to the next of three presets of 0, 90 and 
 * 180 degrees.
 *
 * Circuit used: the servo control line is connected to pin 9 of the Arduino,
 * left button is connected to pin 2, preset select button to pin 3 and right
 * button to pin 4, each button using a pull-down resistor of about 10K.
 * The servo itself is of course connected to an appropriate power supply.
 */
#include <Servo.h> 
 
Servo myservo;

/*
 * Stores the current servo position in degrees with a range from 0 to 180
 */
int servoPos = 90;

/*
 * Stores the previous servo position. By comparison with the current value, the 
 * program determines wether to move the servo or not.
 */
int oldServoPos = 0;

/*
 * Array with the three preset of 0, 90 and 180 degrees.
 */
int presets[] = {0, 90, 180};

/*
 * The index of the preset currently in use.
 */
int preset = 1;

/*
 * Pin definition for the buttons
 */
int leftPin = 2;
int middlePin = 3;
int rightPin = 4;

void setup() 
{ 
  pinMode(leftPin, INPUT);
  pinMode(middlePin, INPUT);
  pinMode(rightPin, INPUT);
  
  Serial.begin(9600);
  Serial.println("begin program");
  
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 
}

void loop()
{
  // Read each button twice with a short delay to ensure a proper debouncing
  byte statesA[3];
  byte statesB[3];
  statesA[0] = digitalRead(leftPin);
  statesA[1] = digitalRead(middlePin);
  statesA[2] = digitalRead(rightPin);
  delay(5);
  statesB[0] = digitalRead(leftPin);
  statesB[1] = digitalRead(middlePin);
  statesB[2] = digitalRead(rightPin);
  
  // Determine the next servo position from the button presses
  if (statesA[0] == HIGH && statesA[0] == statesB[0])
  {
    changePos(false);
  }
  else if (statesA[1] == HIGH && statesA[1] == statesB[1])
  {
    goToNextPreset();
  }
  else if (statesA[2] == HIGH && statesA[2] == statesB[2])
  {
    changePos(true);  
  }
  
  // Move the servo to the newly calculated position
  if (servoPos != oldServoPos)
  {
    Serial.print("position: ");
    Serial.println(servoPos, DEC);
    myservo.write(servoPos);
    oldServoPos = servoPos;
  }
  delay(250);
}

/*
 * Adjusts the servo position to the next preset value.
 */
void goToNextPreset()
{
  preset += 1;
  if (preset > 2)
  {
    preset = 0;
  }
  servoPos = presets[preset];
}

/*
 * Changes the servo position by 5 degrees either up or down, depending
 * on the value of 'up'. The function ensures that the servo will not
 * be moved to a position lower than 0 or higher than 180 degrees.
 */
void changePos(boolean up)
{
  if(5 <= servoPos && servoPos <= 175)
  {
    if (up)
    {
      servoPos += 5;
    }
    else
    {
      servoPos -= 5;
    }
  }
  else if(servoPos <= 5 && up)
  {
    servoPos += 5;
  }
  else if(servoPos >= 175 && !up)
  {
    servoPos -= 5;
  }  
}
