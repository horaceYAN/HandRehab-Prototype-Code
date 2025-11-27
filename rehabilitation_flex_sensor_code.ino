const int thumbPin = A1;
const int flexMin = 200;  // Analogue reading when the sensor is fully extended
const int flexMax = 700;  // Analogue reading when the sensor is fully bent

int lastThumbPos = -1;  // Stores the last transmitted value, initialised to an impossible number
const int threshold = 5;  // Only transmit when the change exceeds this threshold

void setup() {
  Serial.begin(9600);
}

void loop() {
  int thumbVal = analogRead(thumbPin);

  // Map the raw sensor value to a simplified range of 0–100
  int thumbPos = map(thumbVal, flexMin, flexMax, 0, 100);

  // Constrain the mapped value to stay within 0 to 100
  thumbPos = constrain(thumbPos, 0, 100);

  // Transmit data only when the flexion change exceeds the defined threshold
  if (abs(thumbPos - lastThumbPos) >= threshold) {
    Serial.println(thumbPos);
    lastThumbPos = thumbPos;
  }

  delay(500);
}