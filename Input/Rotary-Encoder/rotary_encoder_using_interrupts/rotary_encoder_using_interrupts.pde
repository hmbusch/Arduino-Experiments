/*
 * This small sketch reads a rotary encoder using two interrupt lines.
 * By using the interrupts, the changes in the encoder value can be 
 * applied almost immediately to the currently running program without 
 * having to wait for any other operation to finish.
 * The interrupts call the handleEncoderAdjustment() method. Whatever
 * you want to do with the encoder reading, this is the place to start.
 *
 * The code in this sketch was adapted from 
 * http://www.circuitsathome.com/mcu/reading-rotary-encoder-on-arduino 
 * and combined with some suggestions in the commentaries there
 * to craft a fully working sketch.
 *
 * I also took the liberty of simplifying things like variable types
 * from e.g. by changing uint8_t to byte and so on. Makes it more
 * readable ;-)
 *
 * Circuit:
 * - encoder pin A connected to digital pin 2
 * - encoder pin B connected to digital pin 3
 * - encoder common pin (sometimes also called pin C) connected to ground
 * - circuit uses internal pull-up resistors on pins 2 & 3
 */
 
// The digital pin that pin A of the encoder is connected to
#define ENC_PINA 2

// The digital pin that pin B of the encoder is connected to
#define ENC_PINB 3

// The AVR port that those pins belong to. For more details, please
// to http://www.arduino.cc/en/Reference/PortManipulation
// The required value here is PINX and not PORTX because we are going
// to read the input state, not the output state
#define ENC_PORT PIND

// Many encoder send more than one line level change per click when
// turning. Each change results in an interrupt. To determine the 
// actual steps, we need to know how many HI/LO or LO/HI transistions
// occur per click.
// My rotary encoder (Noble RE0124PVB17.7FINB-24) send 4 changes per 
// click. Refer to your datasheet for this information.
#define ENC_IMPULSES_PER_CLICK 4

// Enables serial logging for debugging purposes. Be sure to set 
// your terminal baudrate to 115200
#define ECHO_TO_SERIAL 1

// The current and the previous encoder 'position'. These two numbers are
// compared with regard to the ENC_IMPULSES_PER_CLICK to determine wether
// a full click has occurred.
byte counter = 0;
byte oldCounter = 0;

// The 'real' encoder value. One click from the encoder increments or
// decrements this value by 1. We start with 500 as the middle between
// 0 and 999. Adjust this and the constrain() command in the 
// handleEncoderAdjustment() method to your likings.
int encoderValue = 500;

/*
 * Initializes the encoder pins and enables the internal pull-up
 * resistors for these pins. To track the encoder changes, interrupts
 * are registered for changes on the two pins.
 * For more information on interrupts and the pin usage, please refer
 * to http://www.arduino.cc/en/Reference/AttachInterrupt
 */
void setup() {
  // setup encoder pin A and enable internal pull-up resistor
  pinMode(ENC_PINA, INPUT);
  digitalWrite(ENC_PINA, HIGH);
  
  // setup encoder pin B and enable internal pull-up resistor
  pinMode(ENC_PINB, INPUT);
  digitalWrite(ENC_PINB, HIGH);

  // make the Arduino watch changes on encoder pin A
  attachInterrupt(0, handleEncoderAdjustment, CHANGE);

  // make the Arduino watch changes on encoder pin B
  attachInterrupt(1, handleEncoderAdjustment, CHANGE);
  
  // begin serial communication (if enabled)
#if ECHO_TO_SERIAL
  Serial.begin (115200);
  Serial.println("Example sketch for reading a rotary encoder");
  Serial.println("https://github.com/hmbusch/Arduino-Experiments/Input/Rotary-Encoder/");
#endif  
}

/* 
 * Let your program do whatever it wants in here. loop()
 * is not required for reading the rotary encoder.
 */
void loop() {
}

/*
 * Reads the encoder state, compares it to the previous state and
 * determines wether it was moved forward, backward or to some transition
 * state. The function returns -1, 0 or 1 depending on the calculation.
 * This method evaluates impulses, not clicks.
 * 
 * Adapted from http://www.circuitsathome.com/mcu/reading-rotary-encoder-on-arduino
 */
int readEncoder()
{
  static int encStates[] = {0,-1,1,0,1,0,0,-1,-1,0,0,1,0,1,-1,0};
  static byte oldAB = 0;
  byte newAB = ENC_PORT;

  newAB >>= 2; //Shift the bits two positions to the right
  oldAB <<= 2;

  oldAB |= ( newAB & 0x03 ); //add current state
  return ( encStates[( oldAB & 0x0f )]);
}

/*
 * This method is called upon interrupt. It evaluates the encoder state
 * by calling readEncoder() and calculates if a full click has already been
 * reached or not (keeping track via counter and oldCounter). If a click
 * has been reached, the current delay is adjusted by 100 microseconds
 * accordingly. To protect the motor, the delay cannot be lower than 500
 * microseconds and not higher than 15000.
 * By using this evaluation in an interrupt, the adjusted speed takes effect
 * more or less immediately.
 */
void handleEncoderAdjustment()
{
  // read the encoder state
  int encoderState = readEncoder(); 
  
  // only handle 'real' changes
  if(encoderState != 0) 
  {
    // Add the encoder state to the counter. Since this method will be called
    // per impulse and not only per click, addition may happen multiple times.
    counter += encoderState;
    
    // A full click is reached when the oldCounter (containing the counter value when the
    // previous click has been reached) deviates from counter by exactly clicksPerStep-1,
    // either higher or lower.
    if(ENC_IMPULSES_PER_CLICK == 1 || ENC_IMPULSES_PER_CLICK > 1 && (counter > oldCounter + ENC_IMPULSES_PER_CLICK - 1 || counter < oldCounter - ENC_IMPULSES_PER_CLICK - 1))
    {
      // Adjust the encoder value accordingly. If you have the feeling the encoder
      // value changes 'the wrong way' (e.g. increases when you turn counter-clockwise)
      // just switch the pins for the encoder or remove the * -1 from the expression.
      encoderValue += -1 * encoderState;
      
      // Perhaps you might want to keep the encoder value within a certain limit?
      encoderValue = constrain(encoderValue, 0, 999);

      // make sure we replace the oldCounter with the current one to detect further clicks
      oldCounter = counter;
      
#if ECHO_TO_SERIAL
      Serial.print("New encoder value: ");
      Serial.println(encoderValue, DEC);
#endif
    } 
  }
}
