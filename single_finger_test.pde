import processing.serial.*;

Serial myPort;  // Create Serial object
String val;     // Store incoming serial data

int successCount = 0;        // Count of successful repetitions
boolean handOpened = false;  // Whether the hand has fully opened
boolean handClosed = false;  // Whether the hand has fully closed
int thumbValue = -1;         // Current sensor value, initialised to an invalid number

boolean firstExercise = true;       // Track whether this is the first exercise
boolean firstPromptShown = false;   // Track whether the initial prompt has been shown

boolean exerciseStarted = false;    // Whether the exercise has started
boolean exerciseEnded = false;      // Whether the exercise has ended

int exerciseRange = 60;     // Default exercise range
boolean dragging = false;   // Track whether the slider is being dragged

void setup() {
  size(500, 500);  // Set window size

  // List all available serial ports
  String[] portList = Serial.list();
  for (int i = 0; i < portList.length; i++) {
    println(i + ": " + portList[i]);
  }

  // Select the correct serial port
  String portName = "/dev/cu.usbmodem213301";
  myPort = new Serial(this, portName, 9600);  // Initialise serial communication

  textSize(16);           // Set text size for visibility
  textAlign(CENTER, CENTER);  // Centre text alignment
}

void draw() {
  background(255);  // White background
  fill(0);          // Black text

  // Draw Start button and slider before exercise begins
  if (!exerciseStarted && !exerciseEnded) {
    drawButton("Start", 200, 320, 100, 40);
    text("Set Exercise Range", width / 2, 150);
    drawSlider(100, 200, 300, 20, exerciseRange);
  }
  
  // Main exercise screen
  if (exerciseStarted && !exerciseEnded) {
    text("Thumb Sensor: " + thumbValue, width / 2, 30);   // Display sensor value
    text("Success Count: " + successCount, width / 2, 150);  // Display success count

    // Draw progress bar
    int progressBarWidth = 300;
    int progressBarHeight = 20;
    int progressBarX = (width - progressBarWidth) / 2;
    int progressBarY = 200;
    fill(200);  // Background bar colour
    rect(progressBarX, progressBarY, progressBarWidth, progressBarHeight);
    fill(0, 0, 255);  // Foreground bar colour

    int progress = int(map(thumbValue, 0, exerciseRange, 0, progressBarWidth));
    progress = constrain(progress, 0, progressBarWidth);
    rect(progressBarX, progressBarY, progress, progressBarHeight);

    // First-time exercise prompts
    if (firstExercise && !firstPromptShown) {
      text("Are you ready? Let's start the first exercise!", width / 2, 60);
      text("Please clench your fist.", width / 2, 90);
      firstPromptShown = true;

    } else {
      // Guidance logic based on sensor value
      if (thumbValue >= 0 && thumbValue <= exerciseRange) {
        text("Well done! Please open your hand.", width / 2, 60);
        handClosed = true;

      } else if (thumbValue >= 90 && thumbValue <= 100) {
        text("Well done! Please close your hand.", width / 2, 90);
        handOpened = true;

      } else if (handOpened) {
        text("Please close your hand.", width / 2, 60);
      }

      // Detect a full open–close cycle
      if (handOpened && handClosed) {
        successCount++;
        handOpened = false;
        handClosed = false;
        firstExercise = false;
      }
    }

    // Draw End button
    drawButton("End", 200, 420, 100, 40);

    // Read serial data
    if (myPort.available() > 0) {
      val = myPort.readStringUntil('\n');
      if (val != null) {
        int newThumbValue = int(trim(val));
        if (newThumbValue != thumbValue) {
          thumbValue = newThumbValue;
        }
      }
    }
  }

  // End-of-exercise screen
  if (exerciseEnded) {
    fill(255, 0, 0);
    text("Success Count: " + successCount, width / 2, 150);

    textSize(20);
    fill(0, 128, 0);
    text("Great job! Keep up the good work!", width / 2, 250);
    textSize(16);
  }
}

void mousePressed() {
  // Start button
  if (mouseX > 200 && mouseX < 300 && mouseY > 320 && mouseY < 360) {
    exerciseStarted = true;
  }

  // End button
  if (mouseX > 200 && mouseX < 300 && mouseY > 420 && mouseY < 460) {
    exerciseEnded = true;
  }

  // Slider interaction
  if (mouseY > 200 && mouseY < 220) {
    dragging = true;
  }
}

void mouseReleased() {
  dragging = false;
}

void mouseDragged() {
  if (dragging) {
    exerciseRange = int(map(mouseX, 100, 400, 20, 100));
    exerciseRange = constrain(exerciseRange, 20, 100);
  }
}

void drawButton(String label, int x, int y, int w, int h) {
  fill(200);
  rect(x, y, w, h, 7);
  fill(0);
  textAlign(CENTER, CENTER);
  text(label, x + w / 2, y + h / 2);
}

void drawSlider(int x, int y, int w, int h, int val) {
  fill(200);
  rect(x, y, w, h);
  fill(0, 0, 255);
  int sliderPos = int(map(val, 20, 100, x, x + w));
  rect(sliderPos - 5, y - 5, 10, h + 10);
  fill(0);
  text("Range: " + val, width / 2, y + 40);
}
