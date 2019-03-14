import processing.sound.*;

/*import ddf.minim.*;
 Minim minim;
 AudioPlayer clicka, clickb;*/

SoundFile clicka, clickb, push, blade; //inclue les sons



ArrayList<Anim> boules; //ce type de liste permet de crééer un grand nombre de particules en meme temps
ArrayList<Anim> carres;
ArrayList<Rect> rectangle;
ArrayList<Star> stars;
ArrayList<Explosion> explosions;
int maximum = 1; //maximum de particules créées en un lancement d'animation
//float cv =0; 

int ajout_boule = 0;
int ajout_carre = 0;


////////////micro
import processing.serial.*;
Serial port;  
MicroSensor micro;
JSONObject json;


void setup() {

  clicka = new SoundFile(this, "lance7.wav"); //on inclue les sons
  clickb = new SoundFile(this, "lance12.wav");
  push = new SoundFile(this, "explosion3.wav");
  blade = new SoundFile(this, "bladerunner.mp3");

  fullScreen();

  boules = new ArrayList<Anim>();
  carres = new ArrayList<Anim>();
  explosions = new ArrayList<Explosion>();
  rectangle = new ArrayList<Rect>();
  stars = new ArrayList<Star>();
  rectMode(CENTER);

  blade.play(); //jouer le son de fond quand on ouvre le programme

  //////////micro
  printArray(Serial.list());
  String portName = Serial.list()[0]; //<= bien utiliser le bon numéro de port ici !!
  port = new Serial(this, portName, 115200);
  micro = new MicroSensor(port);
}

void draw() {

  //fill( 100,micro.getXMag(), micro.getYMag(), 20);
  fill( micro.getXMag(), micro.getXMag(), micro.getXMag(), 20); //couleur fond dépend de l'inclinaison gauche-droite de la carte
  noStroke();
  rect(width/2, height/2, width, height); //fond de plus en plus opaque --> effet trainé

  micro.update();

  if (micro.getAnalog0() > 500) { //si bouton vert est appuyé
   // if (clickb.isPlaying() == false) { //seulement si le son n'est pas déja en train de jouer (évite les sons chiants)
      carres.add(new Anim(true, width, random(-5, -1))); //déclenche l'anim carrés 
      if (!clickb.isPlaying()) clickb.play();   // son déclenché
   // }
  }

  if (micro.getAnalog1() > 500) { //si bouton blanc est appuyé
    //if (clicka.isPlaying() == false) { //seulement si le son n'est pas déja en train de jouer
      boules.add(new Anim(false, 0, random(5, 1))); //déclenche l'anim boules 
      if (!clicka.isPlaying()) clicka.play();   // son déclenché
   // }
  }


  for (int i=0; i < boules.size(); i++) {
    Anim a = boules.get(i); //déclare l'anim et ses fonctions
    a.afficher();
    a.deplacer();
  }

  for (int i=0; i < carres.size(); i++) {
    Anim b = carres.get(i); //déclare l'anim et ses fonctions
    b.deplacer(); 
    b.afficher(); 
    
    boolean supp = false;
    for (int j=0; j < boules.size(); j++) { //on parcourt l'autre liste
      
      
      if (dist(boules.get(j).x, boules.get(j).y, carres.get(i).x, carres.get(i).y) < 30) { // si la distance entre les 2 particules différentes est inférieure à leur rayon, alors couleur de fond change
        // cv = random(255);
        explosions.add(new Explosion(boules.get(j).x, boules.get(j).y)); //anim de l'explosion en récupérant les coordonnées d'une des particules explosées

        if (!push.isPlaying()) push.play(); //joue le son de l'explosion

        boules.remove(j); //arreter l'anim des particules explosées 
        supp = true;
      }
    }
    if(supp) carres.remove(i);
  }


  for (int i = 0; i < explosions.size(); i++) { //anim de l'explosion
    Explosion e = explosions.get(i);
    e.display();
    e.update();
    if (e.life> 108) {
      explosions.remove(i); // si anim d'explosion à 108, stop l'anim
    }
  }
}