
const char ADDR[] = {22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52};
const char DATA[] = {39, 41, 43, 45, 47, 49, 51, 53};

#define CLOCK 2
#define READ_WRITE 3
#define RESET 4

#define MICRODELAY 50
#define MILLIDELAY 50
// Microseconds delay per clock level.
// Double this value for period.
// Take reciprocal of period for frequency.
// 25 us = 20kHz
// 50 us = 10kHz
// 100 us = 5 kHz
// 1000 us = 500 Hz
// 5000 us = 100 Hz
// For slower replace delayMicroseconds() with delay() for milliseconds
// 100 ms = 10 Hz

void setup() {
  for (int i = 0; i < 16; i++) {
    pinMode(ADDR[i], INPUT);
  }
  for (int i = 0; i < 8; i++) {
    pinMode(DATA[i], INPUT);
  }
  pinMode(CLOCK, OUTPUT);
  pinMode(READ_WRITE, INPUT);
  pinMode(RESET, OUTPUT);
  digitalWrite(RESET, HIGH);

  Serial.begin(230400);
  while (!Serial) {
    ; // Wait for serial monitor to get opened and established
  }
  Serial.println("Enter a number of clock cycles to run, 0 to reset.");
}

void printPins() {
  char output[15];

  unsigned int address = 0;
  for (int i = 0; i < 16; i++) {
    int bit = digitalRead(ADDR[i]) ? 1 : 0;
    Serial.print(bit);
    address = (address << 1) + bit;
  }

  Serial.print("   ");

  unsigned int data = 0;
  for (int i = 0; i < 8; i++) {
    int bit = digitalRead(DATA[i]) ? 1 : 0;
    Serial.print(bit);
    data = (data << 1) + bit;
  }

  sprintf(output, "  %04x   %c   %02x", address, digitalRead(READ_WRITE) ? 'r' : 'W', data);
  Serial.println(output);
  if (address >= 0x8000 && address <= 0x800F) {
    Serial.println("");
  }
}

void clockPulse(bool print) {
  digitalWrite(CLOCK, HIGH);
  //delayMicroseconds(MICRODELAY);
  delay(MILLIDELAY);
  if (print)
    printPins();
  digitalWrite(CLOCK, LOW);
  //delayMicroseconds(MICRODELAY);
  delay(MILLIDELAY);
}

void doReset() {
  Serial.println("Resetting");
  // set reset pin
  digitalWrite(RESET, LOW);
  //two clock cycles
  clockPulse(false);
  clockPulse(false);
  // clear reset pin
  digitalWrite(RESET, HIGH);
  //init cycle 9 clocks until pc is set
  for (int i = 0; i < 9; i++) {
    clockPulse(true);
  }
}

void serialEvent() {
  int cycles = Serial.parseInt();

  if (cycles == 0) {
    doReset();
  } else {
    char output[15];
    sprintf(output, "Running %d cycles", cycles);
    Serial.println(output);
    for (int i = 0; i < cycles; i++) {
      clockPulse(false);
    }
  }
  Serial.println("Enter a number of clock cycles to run, 0 to reset.");
}

void loop() {
}
