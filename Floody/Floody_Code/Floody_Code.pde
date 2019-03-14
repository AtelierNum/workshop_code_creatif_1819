import processing.sound.*;
SoundFile file;

/*SoundFile bulle1;*/

int gameIndex = 0;
int espace_largeur = 15000;
int espace_hauteur = 15000;
int fenetre_largeur, fenetre_hauteur;
int origine_x, origine_y;
int etatPerso = 0;
//int etat_forme = 0;



ArrayList<Boule> boules;
int max_boules = 400;
int max_triangles = 400;
int max_carres = 400;
ArrayList<Carre> carres;
ArrayList<Triangle> triangles;



// center point
float centerX = 0, centerY = 0;
float radius = 45, rotAngle = -90;
float accelX, accelY;
float springing = .0009, damping = .98;

//corner nodes
int nodes = 40;
float nodeStartX[] = new float[nodes];
float nodeStartY[] = new float[nodes];
float[]nodeX = new float[nodes];
float[]nodeY = new float[nodes];
float[]angle = new float[nodes];
float[]frequency = new float[nodes];


// soft-body dynamics
float organicConstant = 1;

//pour le petit score
int score;

// pour utiliser la carte microbit
import processing.serial.*;
Serial port; 
MicroSensor micro;
JSONObject json;

float position_x, position_y;

boolean DEBUG = true; // passer à false pour que les infos de debug ne s'affichent pas

void setup() {

  // Load a soundfile from the /data folder of the sketch and play it back
  file = new SoundFile(this, "underwater.wav");
  file.play();
  file.loop();

  /*bulle1 = new SoundFile(this, "bulle1.wav"); */



  fenetre_largeur = width;
  fenetre_hauteur = height;

  origine_x = 7500;
  origine_y = 7500;

  // créer les objets sur l'espace virtuel
  boules = new ArrayList<Boule>();
  for (int i=0; i < max_boules; i++) {
    boules.add(new Boule(espace_largeur, espace_hauteur));
  }

  carres = new ArrayList<Carre>();
  for (int i=0; i < max_boules; i++) {
    carres.add(new Carre(espace_largeur, espace_hauteur));
  }

  triangles = new ArrayList<Triangle>();
  for (int i=0; i < max_boules; i++) {
    triangles.add(new Triangle(espace_largeur, espace_hauteur));
  }
  size(1920, 1080);
  //center shape in window
  centerX = width/2;
  centerY = height/2;
  // iniitalize frequencies for corner nodes
  for (int i=0; i<nodes; i++) {
    frequency[i] = random(5, 12);
  }
  noFill();
  stroke(250);
  strokeWeight(3);
  frameRate(120);
  colorMode(RGB);

  // initialisation de la communication via usb depuis arduino
  // ATTENTION à bien utiliser le port adapté
  printArray(Serial.list());
  String portName = Serial.list()[3]; //<= bien utiliser le bon numéro de port ici !!
  port = new Serial(this, portName, 115200);
  micro = new MicroSensor(port);

  // Affichage debug
  textSize(12);
}

void draw() {

  switch(etatPerso) {
  case 0: // boule
    nodes = 40;
    break;
  case 1: // carré
    nodes = 4;
    break;
  case 2:
    nodes = 3;
    break;
  }

  if (gameIndex == 0) { // attente d'une nouvelle partie
    initialiser();
  }

  if (gameIndex == 1) { // la partie est en cours

    micro.update();
    position_x = micro.getXAccel();
    position_y = micro.getYAccel();
    //Boutons A ET B
    if (micro.getAnalog0() == 2) {
      etatPerso ++;
      if (etatPerso > 2) etatPerso = 0;
    }
    if (micro.getAnalog1() == 1) {
      etatPerso--;
      if (etatPerso < 0) etatPerso = 2;
    }


    radius = constrain(radius - 0.1, 10, 80);


    // fond d'ecran gradient
    colorMode(RGB);
    color a = color(0, 255, 161);
    color k = color(20, 74, 255);
    for (int y = 0; y < height; y++) {
      color c = lerpColor(a, k, map(y, 0, height, 0, 1));
      stroke(c);
      line(0, y, width, y);
    }

    drawShape();
    moveShape();
    textSize(20);

    {  
      // Afficher uniquement les objets qui sont visibles dans la fenêtre BOULE
      if (etatPerso == 0) {
        for (int i=0; i < boules.size(); i++) {
          Boule b = boules.get(i);
          //if (b.visible(origine_x, origine_y, fenetre_largeur, fenetre_hauteur)) b.dessiner(origine_x, origine_y);
          if (dist(b.x -origine_x, b.y- origine_y, centerX + position_x, centerY +position_y) < radius + 10) {
            radius += 15;

            /* if (bulle1.isPlaying() == false) {
             bulle1.play();
             }*/
            boules.remove(i);
          }
        }
      }

      // Afficher uniquement les objets qui sont visibles dans la fenêtre CARRE
      if (etatPerso == 1) {
        for (int i=0; i < carres.size(); i++) {
          Carre b = carres.get(i);
          //if (b.visible(origine_x, origine_y, fenetre_largeur, fenetre_hauteur)) b.dessiner(origine_x, origine_y);
          if (dist(b.x -origine_x, b.y- origine_y, centerX + position_x, centerY +position_y) < radius + 10) {
            radius += 15;
            carres.remove(i);
          }
        }
      }

      // Afficher uniquement les objets qui sont visibles dans la fenêtre TRIANGLE
      if (etatPerso == 2) {
        for (int i=0; i < triangles.size(); i++) {
          Triangle b = triangles.get(i);
          //if (b.visible(origine_x, origine_y, fenetre_largeur, fenetre_hauteur)) b.dessiner(origine_x, origine_y);
          if (dist(b.x -origine_x, b.y- origine_y, centerX + position_x, centerY +position_y) < radius + 10) {
            radius += 15;
            triangles.remove(i);
          }
        }
      }

      // Affichage des éléments : boule, triangle, carré
      for (int i=0; i < boules.size(); i++) {
        Boule b = boules.get(i);
        if (b.visible(origine_x, origine_y, fenetre_largeur, fenetre_hauteur)) b.dessiner(origine_x, origine_y);
      }

      for (int i=0; i < carres.size(); i++) {
        Carre c = carres.get(i);
        if (c.visible(origine_x, origine_y, fenetre_largeur, fenetre_hauteur)) c.dessiner(origine_x, origine_y);
      }

      for (int i=0; i < triangles.size(); i++) {
        Triangle t = triangles.get(i);
        if (t.visible(origine_x, origine_y, fenetre_largeur, fenetre_hauteur)) t.dessiner(origine_x, origine_y);
      }

      // Afficher quelques infos utiles
      noFill();
    }
    //fade background
    rectMode(CORNER);
    fill(0, 0);
    rect(0, 0, width, height);
    drawShape();
    moveShape();

    if (radius <= 10) {
      gameIndex = 2;
    }
  }

  if (gameIndex == 2) { // Game Over!

    PFont police;
    police= loadFont("HelveticaNeue-Bold-48.vlw");
    textFont(police, 80);

    textSize(80);
    text("GAME OVER", width / 3.4, height / 2.9);
  }

  PFont police;
  police= loadFont("HelveticaNeue-Bold-48.vlw");
  textFont(police, 15);

  textSize(15);
  if (DEBUG) {
    fill(255);
    text("gameIndex : " + gameIndex, 20, 50);
    text("origine de la fenêtre : " + origine_x + " / " + origine_y, 20, 70);
    text("radius : " + radius, 20, 90);
    text("etatPerso : " + etatPerso, 20, 110);
    text("bouton A : " + micro.getButtonA(), 20, 130);
    text("bouton B : " + micro.getButtonB(), 20, 150);
  }
}


void initialiser() {

  radius = 45;

  // créer les objets sur l'espace virtuel
  boules = new ArrayList<Boule>();
  for (int i=0; i < max_boules; i++) {
    boules.add(new Boule(espace_largeur, espace_hauteur));
  }

  carres = new ArrayList<Carre>();
  for (int i=0; i < max_boules; i++) {
    carres.add(new Carre(espace_largeur, espace_hauteur));
  }

  triangles = new ArrayList<Triangle>();
  for (int i=0; i < max_boules; i++) {
    triangles.add(new Triangle(espace_largeur, espace_hauteur));
  }
  //size(1500, 1200);
  //center shape in window
  centerX = width/2;
  centerY = height/2;
  // iniitalize frequencies for corner nodes
  for (int i=0; i<nodes; i++) {
    frequency[i] = random(5, 12);
  }
}
