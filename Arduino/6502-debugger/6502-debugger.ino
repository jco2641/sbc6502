#include <Arduino.h>
#include <stdio.h>

/* 
  Based on original by Ben Eater https://eater.net/6502/
  Opcode decoding credit to: https://github.com/dpm-343/6502-monitor/blob/master/6502-monitor.ino 
*/

// Address & data pin connections - pin order below is MSB to LSB
// Values are collected by adding with left shift in order of defined array
const char ADDR[] = {22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52};
// Address 65C02 pins 25 .. 22, 20 .. 9
// Data 65C02 pins 26 .. 33
const char DATA[] = {39, 41, 43, 45, 47, 49, 51, 53};
const char opcodeMatrix[256][5] = {
             "BRK", "ORA", ""   , "", "TSB", "ORA", "ASL", "RMB0", "PHP", "ORA", "ASL", ""   , "TSB", "ORA", "ASL", "BBR0",
             "BPL", "ORA", "ORA", "", "TRB", "ORA", "ASL", "RMB1", "CLC", "ORA", "INC", ""   , "TRB", "ORA", "ASL", "BBR1",
             "JSR", "AND", ""   , "", "BIT", "AND", "ROL", "RMB2", "PLP", "AND", "ROL", ""   , "BIT", "AND", "ROL", "BBR2",
             "BMI", "AND", "AND", "", "BIT", "AND", "ROL", "RMB3", "SEC", "AND", "DEC", ""   , "BIT", "AND", "ROL", "BBR3",
             "RTI", "EOR", ""   , "", ""   , "EOR", "LSR", "RMB4", "PHA", "EOR", "LSR", ""   , "JMP", "EOR", "LSR", "BBR4",
             "BVC", "EOR", "EOR", "", ""   , "EOR", "LSR", "RMB5", "CLI", "EOR", "PHY", ""   , ""   , "EOR", "LSR", "BBR5",
             "RTS", "ADC", ""   , "", "STZ", "ADC", "ROR", "RMB6", "PLA", "ADC", "ROR", ""   , "JMP", "ADC", "ROR", "BBR6",
             "BVS", "ADC", "ADC", "", "STZ", "ADC", "ROR", "RMB7", "SEI", "ADC", "PLY", ""   , "JMP", "ADC", "ROR", "BBR7",
             "BRA", "STA", ""   , "", "STY", "STA", "STX", "SMB0", "DEY", "BIT", "TXA", ""   , "STY", "STA", "STX", "BBS0",
             "BCC", "STA", "STA", "", "STY", "STA", "STX", "SMB1", "TYA", "STA", "TXS", ""   , "STZ", "STA", "STZ", "BBS1",
             "LDY", "LDA", "LDX", "", "LDY", "LDA", "LDX", "SMB2", "TAY", "LDA", "TAX", ""   , "LDY", "LDA", "LDX", "BBS2",
             "BCS", "LDA", "LDA", "", "LDY", "LDA", "LDX", "SMB3", "CLV", "LDA", "TSX", ""   , "LDY", "LDA", "LDX", "BBS3",
             "CPY", "CMP", ""   , "", "CPY", "CMP", "DEC", "SMB4", "INY", "CMP", "DEX", "WAI", "CPY", "CMP", "DEC", "BBS4",
             "BNE", "CMP", "CMP", "", ""   , "CMP", "DEC", "SMB5", "CLD", "CMP", "PHX", "STP", ""   , "CMP", "DEC", "BBS5",
             "CPX", "SBC", ""   , "", "CPX", "SBC", "INC", "SMB6", "INX", "SBC", "NOP", ""   , "CPX", "SBC", "INC", "BBS6",
             "BEQ", "SBC", "SBC", "", ""   , "SBC", "INC", "SMB7", "SED", "SBC", "PLX", ""   , ""   , "SBC", "INC", "BBS7"
            };

                        // 65C02 Pin number
#define CLOCK       2   // 37 or 39
#define READ_WRITE  3   // 34
#define IRQ         4   // 4
#define NMI         5   // 6
#define SYNC        6   // 7

void setup() {
  for (int n = 0; n < 16; n += 1) {
    pinMode(ADDR[n], INPUT);
  }
  for (int n = 0; n < 8; n += 1) {
    pinMode(DATA[n], INPUT);
  }
  pinMode(CLOCK, INPUT);
  pinMode(READ_WRITE, INPUT);
  pinMode(IRQ, INPUT);
  pinMode(NMI, INPUT);
  pinMode(SYNC, INPUT);

  attachInterrupt(digitalPinToInterrupt(CLOCK), onClock, RISING);
  
  Serial.begin(57600);
}

void onClock() {
  char output[60];

  unsigned int address = 0;
  for (int n = 0; n < 16; n += 1) {
    int bit = digitalRead(ADDR[n]) ? 1 : 0;
    address = (address << 1) + bit;
  }
 
  unsigned int data = 0;
  for (int n = 0; n < 8; n += 1) {
    int bit = digitalRead(DATA[n]) ? 1 : 0;
    data = (data << 1) + bit;
  }

  sprintf(output, "Addr: %04x R/W: %c IRQ: %c NMI: %c Data: %02x  %4s",
          address, 
          digitalRead(READ_WRITE) ? 'r' : 'W',
          digitalRead(IRQ) ? 'H' : 'L',
          digitalRead(NMI) ? 'H' : 'L',
          data,
          digitalRead(SYNC) ?  opcodeMatrix[data] : "  "
        );
  Serial.println(output);
}

void loop() {
}
