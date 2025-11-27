import processing.serial.*;

Serial myPort;          // Create Serial object
String val;             // Store incoming serial data

int successCount = 0;   // Count of successful holds
boolean handOpened = false;   // Whether the hand is fully open
boolean handClosed = false;   // Whether the hand is within the target range
boolean cycleCompleted = false; // Whether a full cycle is completed
int thumbValue = -1;    // Current sensor value, initialized with an invalid number

boolean firstExercise = true;      // Track if this is the first exercise
boolean firstPromptShown = false;  // Track if initial instructions have been shown

boolean exerciseStarted = false;   // Whether exercise session has started
boolean exerciseEnded = false;     // Whether exercise session has ended

int exerciseRange = 60;   // Default exercise threshold range
boolean dragging = false; // Whether the slider is being dragged
boolean countdownActive = false; // Whether the hold countdown is active

int countdown = 3;              // Duration of the hold countdown in seconds
int countdownStartFrame = 0;    // Store frame count when countdown starts

void setup() {
  size(500, 500);   // Set window size
  String[] portList = Serial.list();   // List available serial ports

  for (int i = 0; i < portList.length; i++) {
    println(i + ": " + portList[i]);   // Print port index and name
  }

  String portName = "/dev/cu.usbmodem11301"; // Choose correct serial port
  myPort = new Serial(this, portName, 9600); // Open serial communication

  textSize(16);        // Set text size
  textAlign(CENTER, CENTER);  // Center text alignment
}

void draw() {
  background(255);  // White background
  fill(0);          // Black text

  // Initial interface: Start button + Range slider
  if (!exerciseStarted && !exerciseEnded) {
    drawButton("Start", 200, 320, 100, 40);
    text("Set Exercise Range", width / 2, 150);
    drawSlider(100, 200, 300, 20, exerciseRange);
  }
  
  // Main exercise interface
  if (exerciseStarted && !exerciseEnded) {
    text("Thumb Sensor: " + thumbValue, width / 2, 30);
    text("Success Count: " + successCount, width / 2, 150);

    // Draw progress bar
    int progressBarWidth = 300;
    int progressBarHeight = 20;
    int progressBarX = (width - progressBarWidth) / 2;
    int progressBarY = 200;

    fill(200);
    rect(progressBarX, progressBarY, progressBarWidth, progressBarHeight);

    fill(0, 0, 255);
    int progress = int(map(thumbValue, 0, 100, 0, progressBarWidth));
    progress = constrain(progress, 0, progressBarWidth);
    rect(progressBarX, progressBarY, progress, progressBarHeight);

    // Hand state detection
    if (thumbValue >= 90 && thumbValue <= 100) {
      text("Hand fully open, please close your hand.", width / 2, 60);

      if (handClosed) {
        cycleCompleted = true; // Transition from closed to open
      }
      handOpened = true;
      handClosed = false;

    } else if (thumbValue <= exerciseRange) {
      text("Hand in target range.", width / 2, 60);
      handClosed = true;
      handOpened = false;

      // Start hold countdown when entering the range
      if (!countdownActive) {
        countdownActive = true;
        countdownStartFrame = frameCount;
      }

    } else if (handOpened) {
      text("Please close your hand.", width / 2, 60);
    }

    // Hold countdown visualisation
    if (countdownActive) {
      int secondsElapsed = (frameCount - countdownStartFrame) / 60;
      countdown = 3 - secondsElapsed;

      if (countdown > 0) {
        text("Hold for " + countdown + " seconds", width / 2, 100);

      } else {
        text("Please open your hand.", width / 2, 100);
        countdownActive = false;

        if (handClosed) {
          successCount++;
          cycleCompleted = false;
          handClosed = false;
        }
      }
    }

    drawButton("End", 200, 420, 100, 40);

    // Serial data reading
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

  // Ending screen
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
  if (mouseX > 200 && mouseX < 300 && mouseY > 320 && mouseY < 360) {
    exerciseStarted = true;
  }
  if (mouseX > 200 && mouseX < 300 && mouseY > 420 && mouseY < 460) {
    exerciseEnded = true;
  }

  // Start dragging slider
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
