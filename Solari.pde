final float scale = 0.666;

final int lowASCII = 32;
final int highASCII = 90;

final int flapHeight = 65;
final int flapWidth = 50;

PFont flapFont = createFont("Helvetica", 50);

PGraphics[] flaps = new PGraphics[highASCII - lowASCII + 1];


void createflaps() {
  //Populates the flaps array
  
  for (int i=0; i < highASCII - lowASCII + 1; i++) {
    flaps[i] = createGraphics(flapWidth, flapHeight);
    flaps[i].beginDraw();
    flaps[i].background(0);
    flaps[i].fill(255);
    flaps[i].textAlign(CENTER, CENTER);
    flaps[i].textFont(flapFont);
    flaps[i].text((char)(i + lowASCII), flapWidth / 2, flapHeight / 2);
    flaps[i].endDraw();
  }
}
PGraphics getFlap(byte c) {
  // Returns the correct file for a given ASCII code
  
  return flaps[c - lowASCII];
}


class SolariDigit {
  
  // PI/ms
  final float flipVelocity = 16.0 / 1000.0;
  
  // ASCII code of the digit currently showing, or about to show (if a flip is in progress)
  byte digit = lowASCII;
  
  // ASCII code of the digit we're seeking
  byte seekDigit = lowASCII;
  
  // Angle of the current flip
  float angle = 0;
  
  // Buffers for the current (top) digit and the previous (bottom) digit
  PGraphics topFlap, bottomFlap;


  SolariDigit() { 
    topFlap = getFlap(digit);
    bottomFlap = getFlap(digit);
  }
  
  void seekDigit(char d) {
     seekDigit = (byte)d;
  }
  
  void advanceDigit() {
    bottomFlap = getFlap(digit);
    
    digit++;
    if (digit > highASCII)
      digit = lowASCII;

    topFlap = getFlap(digit);
  }
  
  void flipStep(int ms) {
    if (angle == 0)
      advanceDigit();
      
    image(topFlap.get(0, 0, flapWidth, flapHeight / 2), -flapWidth/2, -flapHeight/2);
    image(bottomFlap.get(0, flapHeight / 2, flapWidth, flapHeight / 2), -flapWidth/2, 0); 
    
    pushMatrix();
    if (angle < 0.5) {
      rotateX(-angle * PI);
      image(bottomFlap.get(0, 0, flapWidth, flapHeight / 2), -flapWidth/2, -flapHeight/2);
    }
    else {
      rotateX(-(angle - 1.0) * PI);
      image(topFlap.get(0, flapHeight / 2, flapWidth, flapHeight / 2), -flapWidth/2, 0); 
    }
    popMatrix();
    
    angle += ms * flipVelocity;
    if (angle > 1) {
      angle = 0;
    }
  }
  
  void display(int ms) {
    
    if (digit == seekDigit && angle == 0)
      image(topFlap, -flapWidth/2, -flapHeight/2);
    else
      flipStep(ms);
  }
}




class SolariDigitLine {
  int length;
  SolariDigit[] digits;
  
  SolariDigitLine(int l) { 
    length = l;
    digits = new SolariDigit[length];
    for (int i=0; i<length; i++) {
      digits[i] = new SolariDigit();
    }
  }
  
  void setText(String str) {
    char[] chars = str.toUpperCase().toCharArray();
    for (int i=0; i<min(chars.length, length); i++) {
      digits[i].seekDigit(chars[i]);
    }
  }
  
  void display(int ms) {
    for (int i=0; i<length; i++) {
      pushMatrix();
      translate(52 * i, 0);
      digits[i].display(ms);
      popMatrix();
    }
  }

}



SolariDigitLine ln;
int lastDraw;

void setup() {
  frameRate(60);
  
  // Full Size
  //size(1920, 1080, P3D);

  // Half Size
  size(int(1920 * scale), int(1080 * scale), P3D);
  
  createflaps();
  
  ln = new SolariDigitLine(20);
  ln.setText("Hello World!");
  
  lastDraw = millis();
}



void draw() {
  translate(50, 50);
  scale(scale);
  
  background(100);
  
  ln.display(millis() - lastDraw);

  lastDraw = millis();
}


