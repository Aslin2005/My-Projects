#include <LiquidCrystal.h>
#include <Arduino.h>
#include <math.h>

#define PI 3.14159265358979323846

// LCD pins: RS, E, D4, D5, D6, D7
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

// Number buttons (0-9)
const int numButtons[] = {6, 7, 8, 9, 10, A0, A1, A2, A3, A4};

// Multi-function buttons
const int opButton = A5;      // Cycles through arithmetic operations (+, -, *, /, =)
const int trigButton = 13;    // Cycles through trig/inverse functions (sin, cos, tan, asin, acos, atan)

char normalMode[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
char arithmeticOps[] = {'+', '-', '*', '/', '='};
String trigFuncs[] = {"sin", "cos", "tan", "asin", "acos", "atan"};

String input = "";
int opIndex = 0;  // Track arithmetic operation cycling
int trigIndex = 0;  // Track trig function cycling

void setup() {
  lcd.begin(16, 2);
  Serial.begin(9600);

  // Setup buttons with internal pull-ups
  for (int i = 0; i < 10; i++) pinMode(numButtons[i], INPUT_PULLUP);
  pinMode(opButton, INPUT_PULLUP);
  pinMode(trigButton, INPUT_PULLUP);

  lcd.print("Calculator Ready");
  delay(1000);
  lcd.clear();
}

void loop() {
  // Handle number inputs
  for (int i = 0; i < 10; i++) {
    if (digitalRead(numButtons[i]) == LOW) {
      delay(50);
      while (digitalRead(numButtons[i]) == LOW);
      input += normalMode[i];
      updateLCD();
    }
  }

  // Handle arithmetic operations cycling
  if (digitalRead(opButton) == LOW) {
    delay(50);
    while (digitalRead(opButton) == LOW);
    if (arithmeticOps[opIndex] == '=') {
      evaluateExpression();
    } else {
      input += arithmeticOps[opIndex];
    }
    opIndex = (opIndex + 1) % 5;  // Cycle through +, -, *, /, =
    updateLCD();
  }

  // Handle trigonometric functions cycling
  if (digitalRead(trigButton) == LOW) {
    delay(50);
    while (digitalRead(trigButton) == LOW);
    input += trigFuncs[trigIndex] + "(";
    trigIndex = (trigIndex + 1) % 6;  // Cycle through sin, cos, tan, asin, acos, atan
    updateLCD();
  }
}

void updateLCD() {
  lcd.clear();
  lcd.print(input.length() <= 16 ? input : input.substring(input.length() - 16));
}

// Evaluate arithmetic expression (basic)
void evaluateExpression() {
  float result = atof(input.c_str());  // Convert to float (basic handling)
  input = String(result, 3);
  updateLCD();
  delay(2000);
  input = "";
  opIndex = 0;
  trigIndex = 0;
}

