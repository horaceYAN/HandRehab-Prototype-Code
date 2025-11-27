import processing.serial.*;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.event.KeyEvent;

Serial myPort;        // Serial object for communication
String val;           // Store incoming serial data

int successCount = 0;         // Count of successful gesture cycles
boolean handOpened = false;   // Whether hand is fully opened
boolean handClosed = false;   // Whether hand is fully closed
boolean fullCycleCompleted = false;   // Whether a full open–close cycle is completed
int thumbValue = -1;         // Current sensor value, initialised as an invalid number

boolean firstExercise = true;      // Track if this is the user's first exercise cycle
boolean firstPromptShown = false;  // Track if initial instructions have been shown

boolean exerciseStarted = false;   // Whether exercise has started
boolean exerciseEnded = false;     // Whether exercise has ended

int exerciseRange = 60;      // Default threshold range for flex sensor
boolean dragging = false;    // Whether slider is being dragged

Robot robot;                 // Robot object for simulating keyboard input
char selectedKey = 'W';      // Default key to trigger on gesture completion

void setup() {
  size(500, 500);     // Window size

  // List all available serial ports
  String[] portList = Serial.list();
  for (int i = 0; i < portList.length; i++) {
    println(i + ": " + portList[i]);
  }

  // Select the correct port (adjust based on printed list)
  String portName = "/dev/cu.usbmodem11301";
  myPort = new Serial(this, portName, 9600);

  textSize(16);                // Text size
  textAlign(CENTER, CENTER);   // Text alignment

  // Initialise Robot for keyboard simulation
  try {
    robot = new Robot();
  } catch (AWTException e) {
    e.printStackTrace();
  }
}

void draw() {
  background(255);
  fill(0);

  // Display the currently selected keyboard key
  text("Selected Key: " + selectedKey, width / 2, 450);

  // Display Start button and slider before exercise begins
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
    int progress = int(map(thumbValue, 0, exerciseRange, 0, progressBarWidth));
    progress = constrain(progress, 0, progressBarWidth);
    rect(progressBarX, progressBarY, progress, progressBarHeight);

    // First-time instructions
    if (firstExercise && !firstPromptShown) {
      text("Are you ready? Let's start the first exercise!", width / 2, 60);
      text("Please clench your fist.", width / 2, 90);
      firstPromptShown = true;

    } else {
      // Hand gesture detection logic
      if (thumbValue >= 0 && thumbValue <= exerciseRange) {
        text("Well done! Please open your hand.", width / 2, 60);
        handClosed = true;
        handOpened = false;

      } else if (thumbValue >= 90 && thumbValue <= 100) {
        text("Well done! Please close your hand.", width / 2, 90);
        handOpened = true;

        if (handClosed) {
          fullCycleCompleted = true;
        }
      } 
      else if (handOpened) {
        text("Please close your hand.", width / 2, 60);
      }

      // Once a full open–close cycle is detected
      if (fullCycleCompleted) {
        successCount++;
        println("Success count increased to: " + successCount);

        fullCycleCompleted = false;
        handOpened = false;
        handClosed = false;
        firstExercise = false;

        // Trigger selected keyboard key
        robot.keyPress(KeyEvent.getExtendedKeyCodeForChar(selectedKey));
        robot.keyRelease(KeyEvent.getExtendedKeyCodeForChar(selectedKey));
      }
    }

    // Draw End button
    drawButton("End", 200, 420, 100, 40);

    // Read serial data from Arduino
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
  // Start button
  if (mouseX > 200 && mouseX < 300 && mouseY > 320 && mouseY < 360) {
    exerciseStarted = true;
  }
  // End button
  if (mouseX > 200 && mouseX < 300 && mouseY > 420 && mouseY < 460) {
    exerciseEnded = true;
  }
  // Slider interaction detection
  if (mouseY > 200 && mouseY < 220) {
    dragging = true;
  }
}

void mouseReleased() {
  dragging = false;
}

void mouseDragged() {
  // Update slider position
  if (dragging) {
    exerciseRange = int(map(mouseX, 100, 400, 20, 100));
    exerciseRange = constrain(exerciseRange, 20, 100);
  }
}

// Select keyboard key
void keyPressed() {
  selectedKey = key;
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
