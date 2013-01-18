final float scale = 0.666;


class AirportDigit {
  final int digitHeight = 65;
  final int digitWidth = 50;
  PFont digitFont;
  
  // ASCII code of the digit currently showing, or about to show (if a flip is in progress)
  byte digit = 32;
  
  // ASCII code of the digit we're seeking
  byte seekDigit = 32;
  
  // Angle of the current flip
  float angle = 0;
  
  // Buffers for the current (top) digit and the previous (bottom) digit
  PGraphics topImage, bottomImage;


  AirportDigit() { 
    digitFont = createFont("Helvetica", 50);
    topImage = createGraphics(digitWidth, digitHeight);
    drawDigit(topImage, digit);
    bottomImage = createGraphics(digitWidth, digitHeight);
    drawDigit(bottomImage, digit);
  }
  
  void seekDigit(char d) {
     seekDigit = (byte)d;
  }
  
  void drawDigit(PGraphics g, byte d) {
    g.beginDraw();
    g.background(0);
    g.fill(255);
    
    g.textAlign(CENTER, CENTER);
    g.textFont(digitFont);
    g.text((char) d, digitWidth / 2, digitHeight / 2);
    g.endDraw();
  }
  
  void advanceDigit() {
    drawDigit(bottomImage, digit);
    
    digit++;
    if (digit > 90)
      digit = 32;

    drawDigit(topImage, digit);
  }
  
  void flipStep() {
    if (angle == 0)
      advanceDigit();
      
    image(topImage.get(0, 0, digitWidth, digitHeight / 2), -digitWidth/2, -digitHeight/2);
    image(bottomImage.get(0, digitHeight / 2, digitWidth, digitHeight / 2), -digitWidth/2, 0); 
    
    pushMatrix();
    if (angle < 0.5) {
      rotateX(-angle * PI);
      image(bottomImage.get(0, 0, digitWidth, digitHeight / 2), -digitWidth/2, -digitHeight/2);
    }
    else {
      rotateX(-(angle - 1.0) * PI);
      image(topImage.get(0, digitHeight / 2, digitWidth, digitHeight / 2), -digitWidth/2, 0); 
    }
    popMatrix();
    
    angle += 0.1;
    if (angle > 1) {
      angle = 0;
    }
  }
  
  void display() {
    background(100);
    
    if (digit == seekDigit && angle == 0)
      image(topImage, -digitWidth/2, -digitHeight/2);
    else
      flipStep();
  }
}


AirportDigit dig;

void setup() {
  frameRate(30);
  
  // Full Size
  //size(1920, 1080, P3D);

  // Half Size
  size(int(1920 * scale), int(1080 * scale), P3D);
  
  dig = new AirportDigit();
}

void draw() {
  translate(width*2/3, height*2/3);
  scale(scale);
  
  background(100);
  
  stroke(0);
  strokeWeight(0.1);
  dig.display();

}

void keyPressed() {
  dig.seekDigit(key); 
}
