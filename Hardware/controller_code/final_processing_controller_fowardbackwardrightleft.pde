
import processing.serial.*;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import javax.swing.KeyStroke;
import java.io.IOException;

Serial myPort;

String data="";
float roll, pitch;
String fire = "";

void setup() {
  size (960, 640, P3D);
  myPort = new Serial(this, "COM3", 9600); // starts the serial communication
  myPort.bufferUntil('\n');
}

void draw(){
  translate(width/2, height/2, 0);
  background(33);
  textSize(22);
  text("Roll: " + int(roll) + "     Pitch: " + int(pitch), -100, 265);
  text("Movement : ", -250, 225);
  
  if(roll<-25){
    text("Left", 20, 225);
  }
  if(roll>25){
    text("Right", 20, 225);
  }
  if(pitch<-25){
    text("Backward", -100, 225);
  }
  if(pitch>25){
    text("Forward", -100, 225);
  }
  // Rotate the object
  rotateX(radians(roll));
  rotateZ(radians(-pitch));
  
  // 3D 0bject
  textSize(30);  
  fill(0, 76, 153);
  box (386, 40, 200); // Draw box
  textSize(25);
  fill(255, 255, 255);
  text("Controller Demo", -183, 10, 101);

  //delay(10);
  //println("ypr:\t" + angleX + "\t" + angleY); // Print the values to check whether we are getting proper values
}

// Read data from the Serial Port
void serialEvent (Serial myPort) throws Exception { 
  // reads the data from the Serial Port up to the character '.' and puts it into the String variable "data".
  data = myPort.readStringUntil('\n');
  
  Robot Arduino = new Robot();//Constructor of robot class
  // if you got any bytes other than the linefeed:
  if (data != null) {
    data = trim(data);
    // split the string at "/"
    String items[] = split(data, '/');
    if (items.length > 1) {
      if(items[0].equals("Fire")){
        Arduino.mousePress(InputEvent. BUTTON1_DOWN_MASK);
        delay(15);
        Arduino.mouseRelease(InputEvent. BUTTON1_DOWN_MASK);
      }
      else{
      //--- Roll,Pitch in degrees
        roll = float(items[0]);
        pitch = float(items[1]);
      }
    }
  }
  
 
 if(roll<-25 && (-25<pitch && pitch<25)){
    text("Left", 20, 225);
    Arduino.keyPress(KeyEvent.VK_A);
    delay(15);
    Arduino.keyRelease(KeyEvent.VK_A);
  }
  else if(roll>25 && (-25<pitch && pitch<25)){
    text("Right", 20, 225);
    Arduino.keyPress(KeyEvent.VK_D);
    delay(15);
    Arduino.keyRelease(KeyEvent.VK_D);
  }
  else if(pitch<-25 && (-25<roll && roll<25)){
    text("Backward", -100, 225);
    Arduino.keyPress(KeyEvent.VK_S);
    delay(15);
    Arduino.keyRelease(KeyEvent.VK_S);
  }
  else if(pitch>25 && (-25<roll && roll<25)){
    text("Forward", -100, 225);
    Arduino.keyPress(KeyEvent.VK_W);
    delay(15);
    Arduino.keyRelease(KeyEvent.VK_W);
  } 
}
