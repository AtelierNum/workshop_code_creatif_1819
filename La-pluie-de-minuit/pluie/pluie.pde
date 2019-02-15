//importation des librairies utilisées
import processing.serial.*;
import processing.sound.*;

PicoSensors pico;
Serial port;
SoundFile file;
SoundFile file1;
SoundFile file2;


//Drop [] drops = new Drop[1000];
ArrayList<Drop> drops; // Analyser le drop
int nombre_drop = 1000;
int stab2;  // Variable son

float whiteLevel;// type de donnée de l'éclair
float couleur_fond = 0;// couleur du fond original pour l'éclair


float modificateur_vitesse;// type de donner pour modifier la vitesse

void setup() {
  //size(1600, 1300);
  fullScreen();
  drops = new ArrayList<Drop>(); // faire fonctionner le drop


  for (int i = 0; i < drops.size(); i++) {// Condition pour relancer la boucle drop 
    drops.add(new Drop());
  }



  println(Serial.list() ); // importer le port
  String picoPort = Serial.list()[0];
  port = new Serial(this, picoPort, 38400); 
  pico = new PicoSensors(port);

  textSize(10);


  file = new SoundFile(this, "7608.wav");// Import des sons
  file.loop();
 

  file2 = new SoundFile(this, "3099.wav");
}


void draw() {
  background(couleur_fond);
  pico.update();
  pico.getSound();


  modificateur_vitesse = (((float)pico.getA() / 497)-0.85) / 5 +1;  // transformer la valeur du slider en modificateur de vitesse
 
  
  
  file.rate(modificateur_vitesse); // gérer la vitesse grâce à la boucle for ci-dessous

  for (int i =0; i < drops.size(); i++) {
    drops.get(i).modifierVitesse(modificateur_vitesse);
    drops.get(i).show();
    drops.get(i).fall();
  }


  if (pico.getD() == 0) {
    if (frameCount%3 == 0) couleur_fond = random(180,255);// Contrôler les frames des éclairs et mettre une couleur random
    else couleur_fond = 0;
  } else {
    couleur_fond = 0;
  }
  if (pico.getD() == 0) {

    file2.play();// jouer le son "file2"
  }

  //pico.getButton();
  fill(255);
  // infos de debug
 // text("valeur du bouton : " + pico.getButton(), 10, 70);
  //text("valeur du slider : " + pico.getSlider(), 10, 40);
  // text("modificateur de vitesse : " + modificateur_vitesse, 10, 85);


 
  int modificateur_quantiter = pico.getSlider() + 10; // transformer la valeur du slider en modificateur de quantité
 // text("modificateur de quantité : " + modificateur_quantiter, 10, 55);

  if (modificateur_quantiter > drops.size()) { // on ajoute des drops
    // combien à ajouter ?
    int ajout = modificateur_quantiter - drops.size();
    for (int i = 0; i < ajout; i++) {
      drops.add(new Drop());
    }
  } 
  if (modificateur_quantiter < drops.size()) { // on enlève des drops
    // combien à enlever
    int entrop = drops.size() - modificateur_quantiter;
    for (int i = 0; i < entrop; i++) {
      drops.remove(0);
    }
  } 


  }
