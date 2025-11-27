#include <SoftwareSerial.h>

// Define the flex sensor pin
const int thumbPin = A1;

// Define the minimum and maximum sensor values
const int flexMin = 200;  // Analogue value when the sensor is fully straightened
const int flexMax = 700;  // Analogue value when the sensor is fully bent

int lastThumbPos = -1;  // Previous output value, initialised to a number that will not occur
const int threshold = 5;  // Threshold; only update when the change exceeds this value

// Software serial setup: RX on pin 10 and TX on pin 11
SoftwareSerial BTSerial(10, 11); // RX, TX

void setup() {
  Serial.begin(9600);  // For serial monitor
  BTSerial.begin(9600);  // Baud rate for communication with the Bluetooth module

  Serial.println("Enter AT commands:");
}

void loop() {
  // Read the analogue value from the flex sensor
  int thumbVal = analogRead(thumbPin);

  // Map the flex sensor value to a range between 0 and 100
  int thumbPos = map(thumbVal, flexMin, flexMax, 0, 100);

  // Constrain the mapped value to stay within the 0–100 range
  thumbPos = constrain(thumbPos, 0, 100);

  // Send data only when the change exceeds the threshold
  if (abs(thumbPos - lastThumbPos) >= threshold) {
    Serial.println(thumbPos);  // Print to the serial monitor
    BTSerial.println(thumbPos);  // Send the value to the Bluetooth device
    lastThumbPos = thumbPos;
  }

  // Check if the Bluetooth module has received new data
  if (BTSerial.available()) {
    Serial.write(BTSerial.read());  //  Read and forward to the serial monitor
  }

  // 检查串口监视器是否有新的数据
  if (Serial.available()) {
    BTSerial.write(Serial.read());  // Read and send to the Bluetooth module
  }

  delay(500);  // Delay 500 ms to avoid sending data too frequently
}