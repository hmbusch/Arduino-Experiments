#define stepPin 4
#define dirPin 5
#define sensorPin 11
#define ledPin 13

#define ECHO_TO_SERIAL 1

int delayTime = 50000;
int sensorOffset = 0;
int stepsPerRevolution = 0;
int currentPos = 0;

void setup()
{
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(sensorPin, INPUT);
  pinMode(ledPin, OUTPUT);
  
  digitalWrite(dirPin, HIGH);
  digitalWrite(stepPin, LOW);
  
#if ECHO_TO_SERIAL
  Serial.begin (115200);
  Serial.println("Ready");
#endif 

  delay(10000);

  calibrate();
}

void loop()
{
  digitalWrite(ledPin, !digitalRead(sensorPin));
  delay(500);
}

void calibrate()
{
  //int oldDelay = delayTime;
  //delayTime = 50000;
  
  // Wenn Sensor schon an, dann erstmal wegdrehen
  while (digitalRead(sensorPin) == LOW)
  {
    step();
    delay(100);
  }
  
  while(digitalRead(sensorPin) == HIGH)
  {
    step();
    delay(100);
  }
  
  int sensorWidth = 1;
  sensorOffset = 1;
  
  while(digitalRead(sensorPin) == LOW)
  {
    sensorWidth++;
    step();
    delay(100);
  }
  
  if (sensorWidth > 1)
  {
    sensorOffset = sensorWidth/2;  
  }
  
#if ECHO_TO_SERIAL  
  Serial.print("Ermittelte Sensorbreite: ");
  Serial.println(sensorWidth, DEC);
  Serial.print("Sensorversatz: ");
  Serial.println(sensorOffset, DEC);
#endif
  
  changeDirection();
  step(sensorOffset);
  changeDirection();

  int calibrationPos = 0;

  while(digitalRead(sensorPin) == LOW)
  {
    step();
    delay(100);
    calibrationPos++;  
  }
  
  while(digitalRead(sensorPin) == HIGH)
  {
    step();
    delay(100);
    calibrationPos++;
  }
  
  stepsPerRevolution = calibrationPos + sensorOffset;
  
  step(sensorOffset);
  
  currentPos = 0;

#if ECHO_TO_SERIAL  
  Serial.print("Anzahl Schritte pro Drehung: ");
  Serial.println(stepsPerRevolution, DEC);
#endif  
  
  //delayTime = oldDelay;

#if ECHO_TO_SERIAL
  Serial.print("Verifiziere...");
#endif

  step(stepsPerRevolution * 20);

#if ECHO_TO_SERIAL
  if (digitalRead(sensorPin) == LOW)
  {
    Serial.println("   erfolgreich");  
  }
  else
  {
    Serial.println("   fehlgeschlagen");
  }
#endif    
}

void step(int count)
{
  if (count > 0)
  {
    for (int i = 0; i < count; i++)
    {
      step();
    }
  }
}

void step()
{
  digitalWrite(stepPin, HIGH);
  delay(3);
  digitalWrite(stepPin, LOW);
  delay(3);
  currentPos++;
  if (currentPos > stepsPerRevolution)
  {
    currentPos = 0;
  }
}

void returnHome()
{
  while(currentPos != 0)
  {
    step();
  }
}

void changeDirection()
{
  digitalWrite(dirPin, !digitalRead(dirPin));
}
