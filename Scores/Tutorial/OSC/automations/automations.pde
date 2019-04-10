import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress scoreLocation;

int side = 100;
color bg, fg;

void setup() {
  size(400,400);
  frameRate(25);
  
  /* start listening on OSC port 12000 */
  oscP5 = new OscP5(this,12000);
  
  /* Send messages to score on port 6000 */
  scoreLocation = new NetAddress("127.0.0.1", 6000);
}

void draw() {
  background(bg);
  stroke(fg);
  fill(fg);
  rect(150, 150, side, side);
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

/* score will send various controls to Processing */
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.addrPattern().equals("/background")) {    
    float r = theOscMessage.get(0).floatValue();
    float g = theOscMessage.get(1).floatValue();
    float b = theOscMessage.get(2).floatValue();
    bg = color(r,g,b);
  }
  else if(theOscMessage.addrPattern().equals("/foreground")) {    
    float r = theOscMessage.get(0).floatValue();
    float g = theOscMessage.get(1).floatValue();
    float b = theOscMessage.get(2).floatValue();
    
    fg = color(r,g,b);
  }
  else if(theOscMessage.addrPattern().equals("/side")) {    
    side = theOscMessage.get(0).intValue();
  }
}
