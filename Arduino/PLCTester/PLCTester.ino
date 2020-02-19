const char ADDR[] = {22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52}; // A15..A0
const char DATA[] = {39, 41, 43, 45, 47, 49, 51, 53};                                 // D7..D0

#define CLOCK   2
#define RW      3

#define WE      23
#define OE      25
#define ROM     27
#define CS4     29
#define CS3     31
#define CS2     33
#define CS1     35
#define RAM     37


void setAddress(word address) {
  for ( int i=15; i >= 0; i-- ) {
    digitalWrite(ADDR[i], address & 1);
    address = address >> 1;
  }
}

void checkPrint(word address) {
  bool wri_EN = digitalRead(WE);
  bool out_EN = digitalRead(OE);
  bool rom_CS = digitalRead(ROM);
  bool ram_CS = digitalRead(RAM);;
  bool va1_CS = digitalRead(CS1);
  bool va2_CS = digitalRead(CS2);
  bool va3_CS = digitalRead(CS3);
  bool va4_CS = digitalRead(CS4);

  char output[128];

  sprintf(output, " Address %04x - OE:%c WE:%c RAM:%c CS1:%c CS2:%c CS3:%c CS4:%c ROM:%c",
          address,
          out_EN ? '+' : '-',
          wri_EN ? '+' : '-',
          ram_CS ? '+' : '-',
          va1_CS ? '+' : '-',
          va2_CS ? '+' : '-',
          va3_CS ? '+' : '-',
          va4_CS ? '+' : '-',
          rom_CS ? '+' : '-');

  Serial.println(output);
}

void setup() {

//Pin modes
  for( int i = 0; i < 16; i++ ) {
    pinMode(ADDR[i], OUTPUT);
  }
  for( int i = 0; i < 8; i++ ) {
    pinMode(DATA[i], INPUT);
  }

  for(int i=0; i<16; i++) {
    digitalWrite(ADDR[i], LOW);
  }

  pinMode(CLOCK,OUTPUT);
  pinMode(RW,OUTPUT);

  digitalWrite(CLOCK, LOW);
  digitalWrite(RW, HIGH);

  pinMode(WE,INPUT);
  pinMode(OE,INPUT);
  pinMode(ROM,INPUT);
  pinMode(CS4,INPUT);
  pinMode(CS3,INPUT);
  pinMode(CS2,INPUT);
  pinMode(CS1,INPUT);
  pinMode(RAM,INPUT);

  Serial.begin(57600);

  Serial.println("Read RAM 0x0000");
  setAddress(0x0000);
  digitalWrite(RW, HIGH);
  digitalWrite(CLOCK, HIGH);
  checkPrint(0x0000);

  Serial.println("Write RAM 0x0101");
  setAddress(0x0101);
  digitalWrite(RW, LOW);
  checkPrint(0x0101);

  Serial.println("Top of RAM");
  setAddress(0x7FFF);
  digitalWrite(RW, HIGH);
  checkPrint(0x7FFF);

  Serial.println("Interface #1");
  setAddress(0x8000);
  checkPrint(0x8000);

  Serial.println("Interface #2");
  setAddress(0x8010);
  checkPrint(0x8010);

  Serial.println("Interface #3");
  setAddress(0x8020);
  checkPrint(0x8020);

  Serial.println("Interface #4");
  setAddress(0x8030);
  checkPrint(0x8030);

  Serial.println("Bottom of ROM");
  setAddress(0x8040);
  checkPrint(0x8040);

  Serial.println("Top of ROM");
  setAddress(0xFFFF);
  checkPrint(0xFFFF);

}

void loop() {
}
