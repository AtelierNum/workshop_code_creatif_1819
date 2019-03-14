//début caméra 
import gab.opencv.*;      //importation de biblipthèques 
import java.awt.Rectangle;
import processing.video.*;
import controlP5.*;

OpenCV opencv;
Rectangle[] faces;
Capture cam;
//fin caméra


//début picoboard
import processing.serial.*;
PicoSensors pico;
Serial port;              // Create object from Serial class
int teinte_base = 60;     //créer une variable pour la variation de couleur
//fin picoboard


//début renommer sons
import processing.sound.*;
SoundFile[] sons = new SoundFile[5];  //Création d'un tableau de sons dans lequel on insert 5 sons =>détection de visages
SoundFile bson;      //son actionné par le bouton
SoundFile cson;      //son constant, là dès le debut pour attirer les personnes
SoundFile slider;    //son constant avec le slider
//fin renommer sons


//début variable pour changer d'état
boolean buttonState = false;
boolean pButtonState = false;

float lastDebounceTime = 0;  // the last time the output pin was toggled
float debounceDelay = 50;    // the debounce time; increase if the output flickers
//fin variable pour changer d'état


//début variable état : ligne lumière
PVector position = new PVector();
float lumMin = 256 ;
float lumMax = 0 ;
//fin variable état : ligne lumière


//début variable état : pixels
int cell = 5;       //taille  des pixels
int cols, rows;     //taille de la grille
float taille = 0.5; //float taillemod = 0.5; //déclarer mon futur slider
//fin variable état : pixels


boolean drawT = false;  //ariable flash
int lumiere; //variable de la lumière pour l'effet B

/*************************************************************************************************/

void setup() {
  fullScreen();
  //size(800, 930);
  String[] cameras = Capture.list();    //Liste caméras disponibles et reconnues par l'ordi
  printArray(cameras);
  cam = new Capture(this, 800, 950, cameras[1]); //caméra utilisée
  cam.start();
  opencv = new OpenCV(this, cam);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  //background(0);
  String picoPort = Serial.list()[1];
  println(Serial.list());
  port = new Serial(this, picoPort, 38400); 
  pico = new PicoSensors(port);


  //début sons
  bson = new SoundFile(this, "bson.wav");      // son du bouton
  cson = new SoundFile(this, "cson.wav");      // son premier permettant d'attirer le publique (tourne en boucle) 
  cson.loop();
  slider = new SoundFile(this, "slider.wav");  // son qui varie avec le slider
  slider.loop();
  //déclaration des sons du tableau de détection de visages 
  sons[0] = new SoundFile(this, "son1.wav");
  sons[1] = new SoundFile(this, "son2.wav");
  sons[2] = new SoundFile(this, "son3.wav");
  sons[3] = new SoundFile(this, "son4.wav");
  sons[4] = new SoundFile(this, "son5.wav");
  //fin déclaration des son du tableau de détection du visage
  //fin sons


  //début donées état "pixels"
  frameRate(30);  //nombre d'images par sec
  cols = cam.width / cell; //définition  des colonnes
  rows = cam.height / cell; //définition des lignes
  rectMode(CENTER);
  //fin données "pixels"
}

/*************************************************************************************************/

void draw() {
  pico.update();
  background(0);


  if (cam.available() == true) { //appeler la camera 
    cam.read();
    opencv.loadImage(cam);
    faces = opencv.detect();
    sonore(faces.length);    // lier la camera à la détection des visages pour jouer les sons
    cson();
    slider();

    pushMatrix();
    lumiere = pico.getLight();
    println("lumiere : " + lumiere);
    println("slider : " + pico.getLight());
    translate(width / 2, height / 2);


    if (buttonState == true) { //Condition, si le bouton est pressé, apparition de l'effet a
      effeta();  //appeler le code de cet effet
    } else {     //sion
      rotate(PI/lumiere);  //effecter une rotation de moitié par rapport à la lumière
      effetb();            //en appelant le void de l'effet b
    }
    popMatrix();

    if (pico.getButton() == 0) {  //SI le bouton est en position bas 
      flash(); // apparitiond'un flash
      // passes d'un état à un autre lorsqu'on appuye sur le bouton (en boucle)
      if (buttonState == true && pButtonState == buttonState) { //Faire en sorte de pouvoir passer d'une animation à l'autre
        buttonState = false;
      } else if (buttonState == false && pButtonState == buttonState) {
        buttonState = true;
      }
    } else {
      pButtonState = buttonState;
    }
  }
}
/****************** Les deux effets controlés par le bouton, joués alternativememt **********************/


void effeta() {   //Création de l'effet "ligne horizontales" sur fond noir
  int space = 16;                     //l'espace entre les lignes
  int son = pico.getSound();          //variable du micro du picoboard
  //println("son : " + pico.getSound());
  int slider = pico.getSlider();      //variable du slider du picoboard
  //println("slider : " + pico.getSlider());
  pico.update();


  fill(0);
  noFill();
  colorMode(HSB, 360, 100, 100);  //utilisation d'un autre couleur Mode : Teinte, saturation, niveau
  stroke(                         //la couleur du contour dépendera du son
    teinte_base + map(son, 0, 800, 0, 300), 
    80 + map(son, 0, 800, 0, 20), 
    60 + map(son, 0, 800, 0, 40)
    );
  strokeWeight(map(slider, 0, 1023, 0, 8)); // la taille du contour dépendera du slider
  // créer un cadrillage / grille 
  pushMatrix ();  //Effet mirroir

  float mod = map(lumiere, 0, 1000, 1.2, 2); //Création d'un effet en rapport avec la luminosité
  translate(-cam.width / 2 * mod, - cam.height / 2 * mod); //grossissement
  scale(mod, mod);    //grossissement

  for (int y = space / 2; y < cam.height; y = y + space) { //espace entre les lignes. On dit que b doit etre égal à la ligne /2 soit 7, de plus la boucle fonctionne tant que b inf à la hauteur de la fenêtre et qu'entre chaque ligne il y a un même espace
    beginShape();
    for (int x = space / 2; x < cam.width; x = x + 6) { // sur l'axe horizontal, que a évolue et calcul tou les 4 pixels
      color col = cam.get(x, y); // récupérer la valeur du  pixel
      float _brightness = (0.3 * red(col) + 0.59 * green(col) + 0.11 * blue(col)) / 255 * 100; //calcul de la luminosité

      vertex(x, y + _brightness); //forme varie en fonction des pixels et de la luminosité
    }
    endShape();
  }
  popMatrix();
}



void effetb() {  //création de l'effet d'image pixelisée avec couleurs dans les bleux/violets

  float son = map(pico.getSound(), 0, 1023, 0, 360); //variable du micro du picoboard

  for (int i = 0; i < cols; i++) { //création de la grille
    for (int j = 0; j < rows; j++) {
      int x = i*cell;
      int y = j*cell;
      int loc = (cam.width - x - 1) + y*cam.width; //faire comme un mirroir

      //int slider = pico.getSound();
      float slider = map(pico.getSlider(), 0, 1023, 0, 8); //Gerer le son slider.wav avec le slider
      pico.update();

      float h = red(cam.pixels[loc]);   
      float s = green(cam.pixels[loc]);
      float b = blue(cam.pixels[loc]);
      color c = color(h, s, b, 75);  //définition des couleurs + opacité

      if (h < 180 && s < 100 && b < 100) { //Si le rouge inferieur à 180 et le vert et bleu inferieur à 100 alors ...

        pushMatrix();
        translate( -cam.width / 2, -cam.height / 2);
        translate(x+cell/4, y+cell/4); //déplacer le point d'origine
        rotate((  1 * PI * brightness(c) / 500.0)); //tourner les pixels sur  eux  même
        rectMode(CENTER);
        fill(c); //rentrer la couleurs défninie plus haut
        noStroke();

        if (random(100) > 50) { //Mélanger les ronds et carrés

          fill(son, random(50, 100), random(60, 100), 30); //changer la couleur des ronds
          ellipse(0, 0, (cell+4) * slider, (cell+4) * slider); //mettre 50% des ellipses
        } else {
          rect(0, 0, (cell+4) * slider, (cell+4) * slider ); //mettre 50% des carrés
        }
        popMatrix();
      }
    }
  }
}


/*************************** Ce qui est controlé par le bouton *****************************************/

void flash() {    // fonctions de la transition liées au bouton => flash multicolor + son bson  
  noFill();
  noStroke();
  color c1 = color(360, 100, 100);
  color c2 = color(280, 10, 10);

  if (bson.isPlaying()==false) {
    bson.play();
    float amplitude = 3;
    bson.amp(amplitude);
  }

  float maxd = 1000;                         // rayon de l'éllipse
  for (int d = 0; d < maxd; d++) {           //données caractéristiques au rayon de l'élipse
    float n = map(d, 0, maxd, 0, 1);
    color newc = lerpColor(c1, c2, n);
    stroke(newc);
    ellipse(width / 2, height / 2, d, d);
    ellipseMode(CENTER);
  }
}

void cson() {
  if (cson.isPlaying()==false) { //Si le son ne joue pas
    cson.play();                 //ALors jouer le son
    float amplitude = 0.3;       //Le son cson.wav reste constant tout au long.
    cson.amp(amplitude);
  }
}

/*************************** Ce qui est controlé par le slider *****************************************/

void slider() {
  float amplitude = map(pico.getSlider(), 0, 1023, 0, 1.0);  //le slider peut aussi controler l'amplitude  du son slider.wav
  slider.amp(amplitude);
}

/************************ Ce qui doit se faire lors de la reconnaissance d'une figure *****************************/


void sonore(int visages) {
  if ( (visages > 0) && ( visages <= sons.length) ) { 
    // Un tableau commence toujours à l'index 0, on enlève 1 pour que le premier visage détecté soit à l'index O et non -1
    // lance le son d'index 0, le second visage lance le son d'index 1, etc.
    if (sons[visages-1].isPlaying() == false) {
      sons[visages-1].play();
    }
  }
}
