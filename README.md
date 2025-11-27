🖐️ Hand Rehabilitation Device – Prototype Code Repository

This repository contains the source code developed for the hand rehabilitation prototype, which explores how flex-sensor data and interactive software can support home-based rehabilitation. The project includes both hardware-side Arduino code and software-side Processing applications for real-time visualisation, gesture detection, and interaction testing.

📁 Repository Structure

The project is organised into two main branches:

🔧 1. Arduino Branch

Branch name: Arduino

Purpose: Code running on the Arduino board to read the flex sensor values from each finger (primarily the thumb in this prototype), process the data, and send it via Serial or Bluetooth to the connected computer.
Key functions include:

Reading flex-sensor raw values

Mapping sensor values to a normalised scale (0–100)

Sending processed data via:

USB Serial

Bluetooth (HC-05/HC-06)

Threshold-based update filtering to reduce noise

Optional bi-directional serial communication for AT-command testing

This branch contains different versions of sensor-reading logic (wired and wireless) used during Prototype 1 and Prototype 2 development.

🎨 2. Processing Branch

Branch name: Processing
Purpose:
Processing sketches for visualising live sensor data, guiding rehabilitation exercises, and testing interaction concepts.

This branch includes multiple program versions such as:

✔️ Basic Open–Close Detection
	•	Live flex-sensor display
	•	Visual progress bar
	•	Counts successful open→close→open cycles
	•	Used for early gesture detection testing

✔️ Keyboard Mapping Mode
	•	Converts hand gestures into selected keyboard input
	•	Allows users to control slides, games, or tasks using hand movements
	•	Supports real-time key selection

✔️ Hold Exercise Mode
	•	Requires the user to hold a closed-hand posture for a fixed duration
	•	Includes countdown, success detection, and performance feedback
	•	Designed for strength and endurance-based rehabilitation

Each sketch was created to test different rehabilitation interaction strategies under the Research-through-Design framework.
🔌 How Arduino and Processing Work Together
	1.	Flex sensor detects bending movement
	2.	Arduino maps sensor values to a clean 0–100 scale
	3.	Arduino sends data to Processing (USB or Bluetooth)
	4.	Processing visualises, interprets, and interacts with the data
	5.	Processing provides feedback or triggers actions (e.g., keyboard events)

📚 Usage

1. Upload the Arduino code

Select the matching .ino file from the Arduino branch and upload it to Arduino Mega or Uno.

2. Run the Processing sketch

Open a .pde file from the Processing branch, select the correct serial port, and run the program.

🏗️ Project Purpose

This codebase supports the development of a design-led robotic rehabilitation device.
The programs are used to test:
	•	Sensor accuracy
	•	User interaction modes
	•	Real-time feedback
	•	Home-based rehabilitation scenarios
	•	Integration of rehabilitation into everyday activities

These prototypes form part of a larger research study on enabling hand grasp rehabilitation in home settings.

✉️ Contact

Author: Hao (Horace) Yan

PhD Researcher – Human-Centred Robotic Rehabilitation Design

Queensland University of Technology (QUT)
