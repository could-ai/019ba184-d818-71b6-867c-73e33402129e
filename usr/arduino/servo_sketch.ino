#include <Servo.h>

Servo myservo;  // Create servo object to control a servo

void setup() {
  myservo.attach(9);  // Attaches the servo on pin 9 to the servo object
  Serial.begin(9600); // Initialize serial communication for Bluetooth (HC-05/HC-06 default is often 9600)
}

void loop() {
  // Check if data is available to read
  if (Serial.available() > 0) {
    int angle = Serial.read(); // Read the incoming byte
    
    // Basic validation to ensure it's a valid servo angle
    // Note: Serial.read() returns a single byte (0-255), which fits our 0-180 range perfectly
    if (angle >= 0 && angle <= 180) {
      myservo.write(angle);    // Tell servo to go to position in variable 'angle'
      delay(15);               // Waits 15ms for the servo to reach the position
    }
  }
}
