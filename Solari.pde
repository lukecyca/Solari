final float scale = 1;

final int lowASCII = 32;
final int highASCII = 90;

final int flapHeight = 57;
final int flapWidth = 50;

final PFont flapFont = createFont("Helvetica", 46);

PGraphics[] flaps = new PGraphics[highASCII - lowASCII + 1];

PImage titleImg;

int digitsAnimating = 0;

final int maxDigitsAnimating = 17;

// PI/ms
final float flipVelocity = 9.0 / 1000.0;

final float misfireProbability = 0.2;

final int nColumns = 34;
final int nLines = 13;

SolariDigitLine[] lines = new SolariDigitLine[nLines];

int lastDraw;

import java.util.List;
import java.util.Collections;
import ddf.minim.*;

void createflaps() {
  //Populates the flaps array
  
  for (int i=0; i < highASCII - lowASCII + 1; i++) {
    flaps[i] = createGraphics(flapWidth, flapHeight);
    flaps[i].beginDraw();
    flaps[i].background(40);
    flaps[i].fill(225, 255, 50);
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
    if (angle == 0) {
      if (digitsAnimating > maxDigitsAnimating || random(1) < misfireProbability) {
        image(topFlap, -flapWidth>>1, -flapHeight>>1);
        return;
      }
      advanceDigit();
    }
    
    image(topFlap.get(0, 0, flapWidth, flapHeight>>1), -flapWidth>>1, -flapHeight>>1);
    image(bottomFlap.get(0, flapHeight>>1, flapWidth, flapHeight>>1), -flapWidth>>1, 0); 
    
    pushMatrix();
    if (angle < 0.5) {
      rotateX(-angle * PI);
      image(bottomFlap.get(0, 0, flapWidth, flapHeight>>1), -flapWidth>>1, -flapHeight>>1);
    }
    else {
      rotateX(-(min(angle, 1) - 1.0) * PI);
      image(topFlap.get(0, flapHeight>>1, flapWidth, flapHeight>>1), -flapWidth>>1, 0); 
    }
    popMatrix();
    
    angle += ms * flipVelocity;
    if (angle > 1) {
      angle = 0;
    }
    
    digitsAnimating++;
  }
  
  void display(int ms) {
    
    if (angle > 0 || digit != seekDigit)
      flipStep(ms);
    else
      image(topFlap, -flapWidth>>1, -flapHeight>>1);
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

List<Status> getTweets(int n) {
  try {
    QueryResult result = twitter.search(query);
    List<Status> tweets = result.getTweets();
    Collections.shuffle(tweets);
    return tweets.subList(0, n);
  }
  catch (TwitterException te) {
    println("Couldn't connect: " + te);
    return Collections.emptyList();
  }
}
  
String getMultilinePartition(String str, int lineNum) {
  return str.substring(min(lineNum * nColumns, str.length()), min((lineNum + 1) * nColumns, str.length()));
}

void showMerch() {
  lines[0].setText( "Destination      Flt#      Remarks");
  lines[1].setText( "");
  lines[2].setText( "CD               $ 10      On Time");
  lines[3].setText( "Vinyl            $ 20      On Time");
  lines[4].setText( "T-Shirt          $ 10      On Time");
  lines[5].setText( "Luggage Tag      $  5      On Time");
  lines[6].setText( "Stickers         3/$1      On Time");
  lines[7].setText( "2 CD Pack        $ 15      Special");
  lines[8].setText( "CD+T-Shirt       $ 15      Special");
  lines[9].setText( "Vinyl+T-Shirt    $ 25      Special");
  lines[10].setText("Buttons          FREE      W/Email");
  lines[11].setText("");
  lines[12].setText("        www.sidneyyork.com        ");
}

void showTweets(List<Status> tweets) {
  lines[0].setText( "Tweet @sidneyyork 2 win free stuff");
  lines[1].setText( "");
  lines[2].setText(tweets.get(0).getUser().getName() + " says:");
  lines[3].setText(getMultilinePartition(tweets.get(0).getText(), 0));
  lines[4].setText(getMultilinePartition(tweets.get(0).getText(), 1));
  lines[5].setText(getMultilinePartition(tweets.get(0).getText(), 2));
  lines[6].setText(getMultilinePartition(tweets.get(0).getText(), 3));
  lines[7].setText( "");
  lines[8].setText(tweets.get(1).getUser().getName() + " says:");
  lines[9].setText(getMultilinePartition(tweets.get(1).getText(), 0));
  lines[10].setText(getMultilinePartition(tweets.get(1).getText(), 1));
  lines[11].setText(getMultilinePartition(tweets.get(1).getText(), 2));
  lines[12].setText(getMultilinePartition(tweets.get(1).getText(), 3));
  
  System.out.println(tweets.get(0).getText());
  System.out.println(tweets.get(1).getText());
}





void setup() {
  frameRate(45);
  noiseDetail(4, 0.25);
  size(int(1920 * scale), int(1080 * scale), P3D);
  
  createflaps();
  
  titleImg = loadImage("title.png");
  
  // Init the matrix
  for (int i=0; i<nLines; i++) {
    lines[i] = new SolariDigitLine(nColumns);
  }
  
  initTwitterSearch();
  
  lastDraw = millis();
}



List<Status> tweets;
int nextFramerateDisplay = 5000;
int nextScreenChange = 0;
int nextScreen = 0;

void draw() {
  directionalLight(255, 255, 255, .5, 1, -.5);
  lightSpecular(255, 255, 255);
  ambientLight(150, 150, 150);
  ambient(150, 150, 150);
  
  background(20);
  
  scale(scale);
  
  pushMatrix();
  translate(258, 30);
  image(titleImg, 0, 0);
  popMatrix();
  
  if (millis() > nextScreenChange) {
    if (nextScreen == 0) {
      showMerch();
    } 
    if (nextScreen == 1) {
      tweets = getTweets(4);
      showTweets(tweets.subList(0, 2));
    }
    if (nextScreen == 2) {
      showTweets(tweets.subList(2, 4));
    }
    
    nextScreen = (nextScreen+1) % 3;
    nextScreenChange = millis() + 80000;
  }
  
  if (millis() > nextFramerateDisplay) {
    println(frameRate);
    nextFramerateDisplay = millis() + 5000;
  }
  
  
  // Animate the matrix
  pushMatrix();
  digitsAnimating = 0;
  translate(51, 293);
  for (int i=0; i<nLines; i++) {
    pushMatrix();
    translate(0, flapHeight * 1.1 * i);
    lines[i].display(millis() - lastDraw);
    popMatrix();
  }
  popMatrix();
  
  lastDraw = millis();
}

