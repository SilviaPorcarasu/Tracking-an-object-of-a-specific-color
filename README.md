# Real-Time Color-Based Object Tracking

This project implements a real-time system for tracking a user-selected object color (red, blue, or green) using MATLAB. The system identifies and follows the target object based on its dominant color while ignoring other objects in the scene.

## Scenario

A student holds a red object in one hand and a blue one in the other. The system is instructed to track only the red object in real-time, based on the selected color from a dropdown menu.

## Main Features

- Real-time image acquisition via webcam
- GUI-based user interaction
- Color selection (Red, Blue, Green)
- Dynamic tracking of the target object using bounding boxes
- Noise filtering and region detection

## Project Structure

### 1. GUI for Real-Time Video

- Built using MATLAB `uifigure`, `uipanel`, and `axes` components
- Dropdown for selecting tracking color
- Start/Stop buttons for controlling video input
- Live video preview using the `preview()` function

### 2. Color Tracking Algorithm

- Video frames are captured with `getsnapshot`
- Color channel extraction and grayscale difference highlight selected color
- Median filtering and binary thresholding remove noise
- Connected components are analyzed to find object contours
- Object with largest area is selected and tracked using a bounding box
- Object tracking updates only if displacement is below a set threshold

### 3. Interface Output

- Bounding box is shown around the tracked object
- If the object disappears or moves too far, tracking resets
- Real-time display is continuously updated

## Implementation Notes

- GUI developed with MATLAB App Designer components
- Preview used instead of `start()` due to version/toolbox limitations
- Tracking is robust to small displacements using a displacement threshold
- Limitation: RGB color space struggled with detecting subtle greens
  - Suggestion: convert to HSV color space for improved color distinction

##  Challenges & Solutions

- Initially, the system did not track objects, only showing their centroid in a new window.  
  Solved by integrating tracking rectangle directly into the GUI.  
- Rectangle didn’t disappear when object was lost.  
  Solved using displacement logic to validate object persistence.  
- Difficulty in detecting green in RGB.  
  Proposed use of HSV color space for better separation of hues.

