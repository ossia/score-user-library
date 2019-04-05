import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress scoreLocation;

int shade = 64;

void setup() {
  size(400,400);
  frameRate(25);
  
  /* start listening on OSC port 12000 */
  oscP5 = new OscP5(this,12000);
  
  /* Send messages to score on port 6000 */
  scoreLocation = new NetAddress("127.0.0.1", 6000);
}

void draw() {
  background(shade);  
}

/* When the mouse is clicked / moved, send the information to score */
void mousePressed() {
  OscMessage myMessage = new OscMessage("/mouse");
  myMessage.add(mouseX);
  myMessage.add(mouseY);
  oscP5.send(myMessage, scoreLocation); 
}

void mouseMoved() {
  OscMessage myMessage = new OscMessage("/mouse");
  myMessage.add(mouseX);
  myMessage.add(mouseY);
  oscP5.send(myMessage, scoreLocation); 
}

/* score will convert the mouse position into another 
OSC message, and send it back to Processing, which catches it 
in the following function */
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.addrPattern().equals("/shade")) {    
    shade = theOscMessage.get(0).intValue();
  }
}
