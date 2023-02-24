import processing.opengl.*;
import promidi.*;
import JMyron.*;

JMyron webcam;

MidiIO midiIO;
MidiOut midiOut;

int wwidth = 320, wheight = 240; // camera width/height
int swidth = 1200, sheight = 900; // screen width/height

float updateRate = .25; // in hz
float tempo = 1500; // in ms

int steps = 8;
int[] notes = {36, 42, 40, 37, 43, 48};

ArrayList sensors;
boolean positionCamera = false;

void setup() {
  frameRate(60);
  colorMode(RGB, 1);
  ellipseMode(CENTER);
  size(swidth, sheight, OPENGL);
  
  webcam = new JMyron();
  webcam.start(wwidth, wheight);
  webcam.findGlobs(0);
  
  midiIO = MidiIO.getInstance(this);
  midiOut = midiIO.openOutput(2);
  
  sensors = new ArrayList();
  for(int row = 0; row < notes.length; row++) {
    float y = (row + 1) / (float) (notes.length + 1);
    for(int i = 0; i < steps; i++) {
      float x = ((float) i / steps) + (1 / (2. * steps));
      CircleSensor cur = new CircleSensor();
      cur.setPosition(x, y);
      cur.setSize(.5 / (float) (steps + 1), .01);
      cur.setNote(notes[row]);
      cur.initialize(wwidth, wheight);
      sensors.add(cur);
    }
  }
}

float curt = 0, lastt = 0;

void draw() {
  if(frameCount % (int) (frameRate * updateRate) == 0)
    webcam.update();
    
  int[] img = webcam.image();
  
  background(1);
  if(positionCamera) {
    PImage wimg = new PImage(wwidth, wheight);
    wimg.loadPixels();
    wimg.pixels = img;
    wimg.updatePixels();
    image(wimg, 0, 0, swidth, sheight);
  }
  
  // draw time
  int time = millis();
  curt = map(time % tempo, 0, tempo, 0, 1);
  int position = (int) (width * curt);
  strokeWeight(5);
  line(position, 0, position, height);
  
  for(int i = 0; i < sensors.size(); i++) {
    Sensor cur = (Sensor) sensors.get(i);
    cur.sense(img);
    cur.render();
    if(cur instanceof CircleSensor)
      ((CircleSensor) cur).sound(lastt, curt);
  }
  
  lastt = curt;
}

void keyPressed() {
  if(key == 'b') {
    int n = (int) map(mouseX, 0, width, 0, 128);
    println(n);
    trigger(n);
  }
  if(key == 's')
    webcam.settings();
  if(key == 'c')
    calibrate();
  if(key == 'p')
    positionCamera = !positionCamera;
}

void calibrate() {
  for(int i = 0; i < sensors.size(); i++) {
    Sensor cur = (Sensor) sensors.get(i);
    cur.calibrate(webcam.image());
  }
}
