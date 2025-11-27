import processing.serial.*;

Serial myPort;        // Create Serial object
String val;           // Store incoming serial data

int successCount = 0; // Count successful cycles
boolean handOpened = false;     // Whether the hand is fully open
boolean handClosed = false;     // Whether the hand is fully closed
boolean cycleCompleted = false; // Whether a full open-close cycle is completed
int thumbValue = -1;  // Current sensor value, initialised with an invalid value

boolean firstExercise = true;      // Whether this is the first exercise attempt
boolean firstPromptShown = false;  // Whether the initial prompt has been shown

boolean exerciseStarted = false;   // Whether the exercise has started
boolean exerciseEnded = false;     // Whether the exercise has ended

int exerciseRange = 60;  // Default target exercise range
boolean dragging = false; // Whether the slider is being dragged

void setup() {
  size(500, 500);  // Set window size
  String[] portList = Serial.list();  // List all available serial ports

  for (int i = 0; i < portList.length; i++) {
    println(i + ": " + portList[i]);  // Print each port with its index
  }

  String portName = "/dev/cu.usbmodem213301";  // Select the correct port
  myPort = new Serial(this, portName, 9600);   // Open serial connection

  textSize(16);       // Set text size
  textAlign(CENTER, CENTER); // Center text alignment
}

void draw() {
  background(255);  // Set background to white
  fill(0);          // Text colour black

  // Start interface: button + slider
  if (!exerciseStarted && !exerciseEnded) {
    drawButton("Start", 200, 320, 100, 40);
    text("Set Exercise Range", width / 2, 150);
    drawSlider(100, 200, 300, 20, exerciseRange);
  }
  
  // Exercise interface
  if (exerciseStarted && !exerciseEnded) {
    text("Thumb Sensor: " + thumbValue, width / 2, 30);  // Display sensor value
    text("Success Count: " + successCount, width / 2, 150); // Display count

    // Draw progress bar
    int progressBarWidth = 300;
    int progressBarHeight = 20;
    int progressBarX = (width - progressBarWidth) / 2;
    int progressBarY = 200;

    fill(200);  // Background of progress bar
    rect(progressBarX, progressBarY, progressBarWidth, progressBarHeight);

    fill(0, 0, 255); // Foreground of progress bar
    int progress = int(map(thumbValue, 0, 100, 0, progressBarWidth));
    progress = constrain(progress, 0, progressBarWidth);
    rect(progressBarX, progressBarY, progress, progressBarHeight);

    // State recognition: open / closed
    if (thumbValue >= 90 && thumbValue <= 100) {
      text("Hand fully open, please close your hand.", width / 2, 60);

      if (handClosed) {
        cycleCompleted = true;  // Transition from closed → open
      }
      handOpened = true;
      handClosed = false;

    } else if (thumbValue >= 0 && thumbValue <= 30) {
      text("Hand fully closed, please hold it for 3s then open your hand.", width / 2, 60);
      handClosed = true;
      handOpened = false;

    } else if (handOpened && !handClosed) {
      text("Please close your hand.", width / 2, 60);
    }

    // Cycle detection: one full movement completed
    if (cycleCompleted) {
      successCount++;
      println("Success count increased to: " + successCount);
      cycleCompleted = false;
    }

    // End button
    drawButton("End", 200, 420, 100, 40);

    // Read incoming serial data
    if (myPort.available() > 0) {
      val = myPort.readStringUntil('\n');  // Read until newline
      if (val != null) {
        int newThumbValue = int(trim(val)); // Convert to integer
        if (newThumbValue != thumbValue) {  // Only update if changed
          thumbValue = newThumbValue;
        }
      }
    }
  }

  // End screen
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
