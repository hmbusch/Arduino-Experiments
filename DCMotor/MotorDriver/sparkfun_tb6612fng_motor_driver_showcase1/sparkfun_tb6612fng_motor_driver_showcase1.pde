/*
 * This is a test sketch written for the SparkFun TB6612FNG Dual 1A DC motor driver breakout. 
 * You will require a least a Toshiba TB6612FNG chip for this sketch to work properly. 
 * In addition, this sketch assumes that you use a 3 Volt motor and power it from a 5 Volt
 * power supply.
 * Using weaker or stronger motors and/or another supply voltage requires changes in the
 * PWM value calculation. Do this before using the sketch, motors running havoc arent't
 * really nice to you precious circuits.
 */ 

#define PIN_A_PWM 11
#define PIN_A_IN1 7
#define PIN_A_IN2 8
#define PIN_STANDBY 12

// This is the voltage limit of the motor. The sketch powers the driver with 5 Volts
// but the motor can only take 3 Volts so we have to limit the power going to the motor.
// We do this by not exceeding the 3 Volt rating while mapping it to the PWM value
// with a 0 to 5 Volt scale so even at maximum we will only PWM at 3/5 of the maximum 
// value.
#define VOLTAGE_LIMIT_MV 3000

#define SUPPLY_VOLTAGE_MV 6000

boolean turnClockwise = true;

void setup()
{
  pinMode(PIN_A_PWM, OUTPUT);
  pinMode(PIN_A_IN1, OUTPUT);
  pinMode(PIN_A_IN2, OUTPUT);
  pinMode(PIN_STANDBY, OUTPUT);
  
  // enable the mto
  digitalWrite(PIN_STANDBY, HIGH);
}

void loop()
{
  for (int i = 0; i <= 100; i++)
  {
    setSpeedA(i);
    delay(50);
  }
  
  delay(3000);
  stopA();
  delay(5000);
  
  for (int i = 0; i >= -100; i--)
  {
    setSpeedA(i);
    delay(50);
  }
  
  delay(3000);
  stopA();
  delay(5000);
}

/*
 * Stops the motor by pulling IN1 and IN2 low and ending the current PWM signal.
 */
void stopA()
{
  digitalWrite(PIN_A_PWM, LOW);
  digitalWrite(PIN_A_IN1, LOW);
  digitalWrite(PIN_A_IN2, LOW);
}

/*
 * Sets the speed of the motor. The speed can be given in a range between 0 and 100 with
 * 100 being the fastest speed and 0 meaning stop. This method computes the appropriate PWM
 * value and PWMs the driver accordingly. If the specified maximum motor voltage is lower
 * than the given supply voltage, the PWM value is constrained accordingly. Example:
 * 
 * Supply voltage: 10 Volts
 * Maximum motor voltage: 5 Volts
 * Selected Speed: 50
 * => computed PWM value: 64
 *
 * Note: a speed lesser than 0 is treated as 0, a speed higher than 100 is treated as 100.
 * Calling this method with a value of 0 is not equal to calling the stopBrake() method, 
 * because the latter requires setting the direction anew to resume operation.
 */
void setSpeedA(int speed)
{
  byte pwmValue;
  int trueSpeed = abs(speed) > 100 ? 100 : abs(speed);
  boolean clockwise = speed > 0;
  if (trueSpeed != 0)
  {
    if (VOLTAGE_LIMIT_MV < SUPPLY_VOLTAGE_MV)
    {
      int constrainedSpeed = map(trueSpeed, 0, 100, 0, VOLTAGE_LIMIT_MV);
      pwmValue = map(constrainedSpeed, 0, SUPPLY_VOLTAGE_MV, 0, 255);
    }
    else
    {
      pwmValue = map(trueSpeed, 0, 100, 0, 255);
    }
    setDirectionA(clockwise);  
    analogWrite(PIN_A_PWM, pwmValue);
  }
  else
  {
    stopA();
  }
}

void setDirectionA(boolean clockwise)
{
  if (clockwise)
  {
    digitalWrite(PIN_A_IN1, HIGH);
    digitalWrite(PIN_A_IN2, LOW);
  }
  else
  {
    digitalWrite(PIN_A_IN1, LOW);
    digitalWrite(PIN_A_IN2, HIGH);
  }
}
