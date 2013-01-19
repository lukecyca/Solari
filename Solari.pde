final float scale = 0.666;

final int lowASCII = 32;
final int highASCII = 90;

final int flapHeight = 65;
final int flapWidth = 50;

final PFont flapFont = createFont("Helvetica", 50);

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
    flaps[i].text((char)(i + lowASCII), flapWidth>>1, flapHeight>>1);
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
      
    image(topFlap.get(0, 0, flapWidth, flapHeight>>1), -flapWidth>>1, -flapHeight>>1);
    image(bottomFlap.get(0, flapHeight>>1, flapWidth, flapHeight>>1), -flapWidth>>1, 0); 
    
    pushMatrix();
    if (angle < 0.5) {
      rotateX(-angle * PI);
      image(bottomFlap.get(0, 0, flapWidth, flapHeight>>1), -flapWidth>>1, -flapHeight>>1);
    }
    else {
      rotateX(-(angle - 1.0) * PI);
      image(topFlap.get(0, flapHeight>>1, flapWidth, flapHeight>>1), -flapWidth>>1, 0); 
    }
    popMatrix();
    
    angle += ms * flipVelocity;
    if (angle > 1) {
      angle = 0;
    }
  }
  
  void display(int ms) {
    
    if (digit == seekDigit && angle == 0)
      image(topFlap, -flapWidth>>1, -flapHeight>>1);
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
    // Blank them all
    for (int i=0; i<length; i++) {
      digits[i].seekDigit(' ');
    }
    
    // Copy characters in
    char[] chars = str.toUpperCase().toCharArray();
    for (int i=0; i<min(chars.length, length); i++) {
      digits[i].seekDigit(chars[i]);
    }
  }
  
  void display(int ms) {
    for (int i=0; i<length; i++) {
      pushMatrix();
      translate(flapWidth * 1.1 * i, 0);
      digits[i].display(ms);
      popMatrix();
    }
  }

}


Twitter twitter;
Query query;

void initTwitterSearch() {
  String conf[] = loadStrings("twitter.conf");
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey(conf[0]);
  cb.setOAuthConsumerSecret(conf[1]);
  cb.setOAuthAccessToken(conf[2]);
  cb.setOAuthAccessTokenSecret(conf[3]);
  twitter = new TwitterFactory(cb.build()).getInstance();
  query = new Query("@sidneyyork");
  query.setCount(10);
}

Status getTweet() {
  try {
    QueryResult result = twitter.search(query);
    return result.getTweets().get(int(random(result.getCount())));
  }
  catch (TwitterException te) {
    println("Couldn't connect: " + te);
    return null;
  }
}

int nColumns = 32;
int nLines = 4;
SolariDigitLine[] lines = new SolariDigitLine[nLines];
int lastDraw;



  
String getMultilinePartition(String str, int lineNum) {
  return str.substring(min(lineNum * nColumns, str.length()), min((lineNum + 1) * nColumns, str.length()));
}

void setup() {
  frameRate(60);
  
  // Full Size
  //size(1920, 1080, P3D);

  // Half Size
  size(int(1920 * scale), int(1080 * scale), P3D);
  
  createflaps();
  
  for (int i=0; i<nLines; i++) {
    lines[i] = new SolariDigitLine(nColumns);
  }
  
  lastDraw = millis();
  
  initTwitterSearch();
  
  String str = getTweet().getText();
  println(str);
  for (int i=0; i<nLines; i++) {
    lines[i].setText(getMultilinePartition(str, i));
  }
}


int nextTwitterSearch = 20000;

void draw() {
  translate(50, 50);
  scale(scale);
  
  background(100);
  
  if (millis() > nextTwitterSearch) {
    String str = getTweet().getText();
    println(str);
    for (int i=0; i<nLines; i++) {
      lines[i].setText(getMultilinePartition(str, i));
    }
    nextTwitterSearch = millis() + 20000;
  }
  
  for (int i=0; i<nLines; i++) {
    pushMatrix();
    translate(0, flapHeight * 1.1 * i);
    lines[i].display(millis() - lastDraw);
    popMatrix();
  }
  lastDraw = millis();
}


