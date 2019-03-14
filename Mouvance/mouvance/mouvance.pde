import processing.serial.*;

Snow[] flakes = new Snow[1000];


//variable pluie
ArrayList<Goutte> gouttes;

PImage photo;
PImage mask;
//PImage chaleur; //Images des climats
//PImage froid;

float v;
import processing.sound.*;
SoundFile file;

/*Vent*/
ArrayList<Particle> particles = new ArrayList<Particle>();
int particleNum = 8000;
/*Vent*/

float magnetRadius = 100;
float rippleRadius = 0;
float equatorRadius = 400;
float domeRadius = 2000;

float noiseOndulation = 200;
float noiseVariation = 1000;
float noiseInterval = 250;
float noiseResistance = 1000;

int maxTrembleTime = 20;
int particleSpiral = 0;

Boolean ripple = false;
Boolean vortex = false;
Boolean inverted = false;
Boolean falling = false;
Boolean rotating = false;
Boolean innerCircle = false;
Boolean outerCircle = false;
Boolean initializing = false;

ArrayList<PVector> emitters = new ArrayList<PVector>();

float maxSpeedModifier = 4;



//Cycle jour
float xRed = 255, xGreen = 255, xBlue = 255;
float yRed = 10, yGreen = 0, yBlue = 61;

boolean backwards=false;
int timeLapse=24000;
int timeTrack;
//fin cycle jour

//nuages
int numcols = 190;
int numrows = 100;
int gap = 7;
float xspacing;
float yspacing;
float xoff = 0; 
float yoff = 0;
float driftXN = 0; 
float driftYN = 0;
//fin nuages


PicoSensors pico;
Serial port;

void setup() {

  fullScreen(P2D);
  file = new SoundFile(this, "ambiant.mp3"); //son ambiant
  file.loop();
  photo = loadImage("map1.jpg"); //carte fond


  timeTrack=millis()+timeLapse;
  mask = loadImage("mask.png"); //carte ressortir les noirs
  mask.resize(1920, 1080);

  //chaleur = loadImage("chaleur.jpg");
  //froid = loadImage("froid.jpg");

//port picoboard
  println(Serial.list() );
  String picoPort = Serial.list()[0];
  port = new Serial(this, picoPort, 38400); 
  pico = new PicoSensors(port);
  //port picoboard

//Vent
  for (int i=0; i<particleNum; i++) {
    particles.add(new Particle(domeRadius * cos(0) + width/2, domeRadius * sin(0) + height/2, random(0.5, 2), random(0.05, 0.1), i));
  }

  for (Particle p : particles) {
    falling = false;
    p.stopped = false;
    p.pos.x = random(width);
    p.pos.y = random(height);
  }
  textSize(20);
//Vent


  gouttes = new ArrayList<Goutte>(); //anim pluie


 xspacing = (width-gap) / numcols;
  yspacing = (height-gap) / numrows;
  drawGrid();
  
  
  }
  
void draw() { 
  
  pico.update();
  noStroke();
  
 
  image(photo, 0, 0, width, height);

  /*if (pico.getA() > 400) {
    float v =constrain( map(pico.getA(), 350, 500, 0, 255), 0, 255);
    tint(255, 0+v);
    image(chaleur, 0, 0, width, height);
  }
  if (pico.getA() < 300) {

    float v =constrain( map(pico.getA(), 150, 0, 0, 255), 0, 255);
    tint(255, 0+v);
    image(froid, 0, 0, width, height);
  }*/



  if (millis()>timeTrack) {
    timeTrack=millis()+timeLapse;
    backwards=!backwards;
  }

  float per = (timeTrack-millis())/float(timeLapse);  
  if (backwards==true) {  
    per = 1-per;
  }
  surface.setTitle(nf(per*100, 3, 2)+"% Flag="+backwards);
  fill(lerpColor(color(xRed, xGreen, xBlue), color(yRed, yGreen, yBlue), per), 180);
  rect(0, 0, 1920, 1080);

  // Masque pour conserver des noirs profonds
  
image(mask,0 ,0);

//ANIM VENT

  for (PVector e : emitters) {
    particles.add(new Particle(e.x, e.y, random(0.5, 2), random(0.1, 0.5), frameCount));
  }

  for (Particle p : particles) {
    if (p.attracting) p.magnet(mouseX, mouseY, magnetRadius, 50);
    if (p.flowing) p.flow();
    if (falling) p.fall();

    if (initializing && particleSpiral > particleNum - 10) {
      initializing = false;
      p.flowing = true;
    } 

    if (millis()%((p.index*5)+1)==0 && !p.start) {
      p.start = true;
    }

    if (rotating) {
      p.flowing = false;
      p.circleRotation(p.distanceFromCenter);
    } else {
      p.flowing = true;
    }

    if (ripple) {
      p.ripple();
    } else {
      p.rippling = false;
      p.ripplingSize = 0;
    }

    if (initializing) {
      //p.emit();
      p.run();
      initializing = false;
    }
    p.run();
  }

  if (ripple) {
    rippleRadius += 5;
    if (rippleRadius > domeRadius) ripple = false;
  }

  if (pico.getSound() > 800) {
    for (Particle p : particles) {
      ripple = true;
      rippleRadius = 10;
    }
  }
  
  //ANIM VENT FIN
  
  
  //ANIM Eclair
println(pico.getLight());
  pushMatrix(); //Eclair
  if (pico.getButton() == 0) {
    file = new SoundFile(this, "eclair.wav");
    file.play();
    noStroke();
    fill(255, 200);
    rect(0, 0, width, height);
  }
  popMatrix();

  //ANIM Eclair FIN

  

//ANIM PLUIE
  if (pico.getSlider() > 300)
  {
    //file = new SoundFile(this, "rain.wav");
    //file.play();
    
    float sliderp = map(pico.getSlider(), 0, 1000, 0, 1000); 
    //boucle for = nb de gouttes qui appraissent par frame
    for (int i = 0; i < sliderp; i++) {
      gouttes.add(new Goutte(random(width), random(height)));
    }
  }

  //boucle for permettant d'afficher chaque goutte
  for (int i = 0; i < gouttes.size(); i++) {
    Goutte g = gouttes.get(i);
    g.dessiner();
    g.update();

    if (g.life < 0) {
      gouttes.remove(i);
    }
  }
  
  //ANIM PLUIE
  
  //ANIM NUAGES
  
  if (pico.getLight() > 1000) {
    driftXN += 0.1;
  driftYN += 0.1;
  xoff += (noise(driftXN) * 0.2) - 0.1;
  yoff += (noise(driftYN) * 0.2) - 0.1;
  drawGrid();
  }
  
  //ANIM NUAGES FIN
  
  //ANIM NEIGE
  
  if (pico.getA() > 100) {
    
  for (int i = 0; i<flakes.length; i++) { 
    flakes[i] = new Snow(random(2, 8));
  }
  for (int i = 0; i < flakes.length; i++) {
    flakes[i] .display();
  }
  //ANIM NEIGE FIN

  // Texte de DEBUG
  
}

}


/*void mousePressed() {
  for (Particle p : particles) {
    falling = false;
    p.stopped = false;
    p.pos.x = random(width);
    p.pos.y = random(height);
  }*/


void drawGrid() { // GRILLE NUAGES POINTS
  float xpos = 0;
  float ypos = 0; 
  
  float inc = 0.04;
  float xnoise = xoff + inc;
  float ynoise = yoff + inc;
  for (int y = 0; y <= numrows +10; y+=1) {
    for (int x = 0; x < numcols; x+=1) {
      drawShape(xpos, ypos, xspacing-gap, yspacing-gap, noise(xnoise,ynoise));
      xpos += xspacing;
      xnoise += inc;
    }
    xpos = 10;
    xnoise = xoff + inc;
    ypos += yspacing;
    ynoise += inc;
  }
}

void drawShape(float x, float y, float wid, float hei, float factor) {
  int fillval = int(factor * 300);
  fill(fillval, 255);
  pushMatrix();
  translate(x, y);
  int rot = int(factor * 1000);
  rotate(radians(rot));
  scale(factor * 3);
  rect(0, 0, wid, hei);
  popMatrix();
}



class Goutte { //CLASSE GOUTTES PLUIE

  float x;
  float y;
  int life;

  Goutte(float x, float y) {
    this.x = x;
    this.y = y;
    life = 20;
  }

  void dessiner() {
    fill(0, 113, 188, 90);
    noStroke();
    ellipse(x, y, 10, 10);
  }

  void update() {
    life = life - 1;
  }
}

class Snow {
  float esize = random(2, 20);
  boolean pulse = false;
  float x2; 
  float y2;
  float alpha;
  float diameter;
  float xspeed = random(-.2, .2);
  float yspeed = random(-.2, .2);
  float descentX;

  Snow (float tempD) {
    x2 = random(-50, width+50);
    y2 = random(height);
    diameter = tempD;
  }

   
  void display() {
    noStroke();
  fill(255, 75);
    ellipse(x2, y2, esize, esize);
    y2 = y2 + yspeed;
    x2 = x2 + xspeed;
    
 if (pulse == false){
        esize = esize - random(.04, .06);
        if (esize < 0) {
          pulse = true;
        }
      }
}
}
