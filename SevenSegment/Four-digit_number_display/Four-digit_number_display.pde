/*
 * Circuit used: 
 * 2x 2-digit seven segment diplays, common anode
 * each of the four anodes is hooked up to a NPN transistor
 * using 10K resistors on the base and 150 ohm resistor on
 * the emitter. The collector is connected to +5V.
 * The four cathodes of the digits that represent the 
 * same segment are connected together and hooked up 
 * to one of eight outputs of a darlington array (ULN2305). 
 * The inputs of the darlington array are connected to 
 * the output A-H of an 8-bit serial to parallel shift register.
 * Clock, Latch and Data pin are connected to the Arduino
 * as well ad the 4 base pin of the NPN transistors.
 */


int clockPin = 6;
int latchPin = 5;
int dataPin = 4;

byte digitPins[] = {2, 9, 3, 8};

byte digits[10] = {
  B11111100,  // 0
  B01100000,  // 1
  B11011010,  // 2
  B11110010,  // 3
  B01100110,  // 4
  B10110110,  // 5
  B10111110,  // 6
  B11100000,  // 7
  B11111110,  // 8
  B11110110
};

int number = 1111;

void setup()
{
  for (int i = 0; i < 4; i++)
  {
    pinMode(digitPins[i], OUTPUT);
  }
  pinMode(clockPin, OUTPUT);
  pinMode(latchPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
}

void loop()
{
  byte displayDigits[4];
  displayDigits[0] = number / 1000;
  displayDigits[1] = (number - displayDigits[0] * 1000) / 100;
  displayDigits[2] = (number - displayDigits[0] * 1000 - displayDigits[1] * 100) / 10;
  displayDigits[3] = (number - displayDigits[0] * 1000 - displayDigits[1] * 100 - displayDigits[2] * 10);
  
  for (int i = 0; i < 4; i++)
  {
    for (int j = 0; j < 4; j++)
    {
      if (i == j)
      {
        digitalWrite(digitPins[j], HIGH);
      }
      else
      {
        digitalWrite(digitPins[j], LOW);
      }
    }
    displayDigit(displayDigits[i]);
    delay(3);
  }
  
  delay(1);
  if (number > 0)
  {
    number--;
  }
}

void displayDigit(byte digit)
{
  digitalWrite(latchPin, LOW);
  shiftOut(dataPin, clockPin, LSBFIRST, digits[digit]);
  digitalWrite(latchPin, HIGH);
}

void clearDigit()
{
  digitalWrite(latchPin, LOW);
  shiftOut(dataPin, clockPin, LSBFIRST, 0);
  digitalWrite(latchPin, HIGH);
}

/*
void pulse(int pin)
{
  delayMicroseconds(20);
  digitalWrite(pin, HIGH);
  delayMicroseconds(20);
  digitalWrite(pin, LOW);
}
*/
