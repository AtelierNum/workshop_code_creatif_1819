import processing.serial.*;
import processing.sound.*;
import processing.video.*;


Serial port;
MicroSensorDeNous micro;
int gameIndex = 0;
JSONObject json ;




/*----------------------------------------
 |                                         |
 |                 VARIABLES               |
 |                                         |
 ------------------------------------------*/


// Variables pour la page d'acceuil
PImage ImageAccueil1 ;
PImage ImageAccueil2 ;
PImage Start ;
boolean imageTitre = true;
Movie OhoHistory;


// Variables pour le tuto Joueur 1
PImage TutoJoueur1 ; // + fin
PImage Oho ;
PImage Next ;
int spacing = 400; // +jeu
float position_oho, position_oho_avant; // + jeu


// Variables pour le tuto Joueur 2
PImage TutoJoueur2 ; // + fin
float position_murs, position_murs_avant; // + jeu


// Variables pour la page de démarage du jeu/compte à rebourd
PFont police;
PImage Goal;
int Decompte = 3;
int m = 0;


// Variables pour le jeu
Animation animation1, animation2, animation3;
PImage viefull;
PImage photo;
int lifeCounter =3;
boolean lifeLost = false;
boolean gameOver = false;
int Timer = 60;
int j = 0;
int timer_vies = 3;
boolean play_animation = true;
PImage Oho_Explosion ; 
float position_Oho_Explosion, position_Oho_Explosion_avant;
PImage Oho_PasContent ; 
float position_Oho_PasContent, position_Oho_PasContent_avant;
SoundFile ArcadeGameMusic;
SoundFile OhoTheme;
SoundFile Outch;
SoundFile OhoDead;


// Variable pour la fin
int sp = 70;
int finIndex = 0;
PImage Retry;
int Attente = 15;
int n = 0;

// Variable pour la fin : Joueur 1 gagnant
PImage Joueur1gagnant;

// Variable pour la fin : Joueur 1 perdant
PImage Joueur1perdant;





/*----------------------------------------
 |                                         |
 |                   SETUP                 |
 |                                         |
 ------------------------------------------*/


void setup () {
  fullScreen () ;
  background (0) ;


  //intialisation du controlleur micro:bit
   printArray (Serial.list());
   String portName = Serial.list()[0];
   port = new Serial(this, portName, 115200);
  micro = new MicroSensorDeNous (port);


  // initialisation des variables pour la page d'accueil
  ImageAccueil1 = loadImage ("ecran_titre_1F.png");
  ImageAccueil2 = loadImage("ecran_titre_2T.png");
  Start = loadImage("Start.png");
  OhoHistory = new Movie(this, "OhoHistory.mp4");
  OhoHistory.loop();

  // initialisation des variables pour le tuto Joueur 1
  Oho = loadImage ("Oho + bulle.png") ;
  Next = loadImage ("Next.png") ; // + tuto joueur 2
  TutoJoueur1 = loadImage ("ecran-tuto_joueur_1.png");
  position_oho = width*0.5;

  // initialisation des variables pour le tuto Joueur 2
  TutoJoueur2 = loadImage ("ecran-tuto_joueur_2.png");
  position_murs = width*0.35;
  

  // Variables pour la page de démarage du jeu/compte à rebourd
  Goal = loadImage ("Objectif du jeu.png");
  police = createFont ("Electrolize-Regular.ttf", 250);
  textFont (police);


  // initialisation des variables pour le jeu
  photo = loadImage("Oho.png");
  frameRate(24);//combien d'image par seconde pour les vies
  animation1 = new Animation("stopmotion_vie_1/vie1_", 30);
  animation2 = new Animation("stopmotion_vie_2/vie2_", 30);
  animation3 = new Animation("stopmotion_vie_3/vie3_", 30);
  Oho_PasContent = loadImage("CoupDeJus.gif");
  Oho_Explosion = loadImage("Splash.png");
  ArcadeGameMusic = new SoundFile(this, "ArcadeGameMusic.wav");
  OhoTheme  = new SoundFile(this, "oho.wav");
  Outch  = new SoundFile(this, "outch.wav");
  OhoDead  = new SoundFile(this, "ohofin.wav");


  // initialisation des variables pour la fin
  Retry = loadImage ("RETRY.png");
  
  // Variable pour la fin : Joueur 1 gagnant
  Joueur1gagnant = loadImage ("ecran_gameover_j1_gagnant.png");
  
  // Variable pour la fin : Joueur 1 perdant
  Joueur1perdant = loadImage ("ecran_gameover_j1_perdant.png");
  textSize(14);
}





/*----------------------------------------
 |                                         |
 |            FONCTIONS RANDOM             |
 |                                         |
 ------------------------------------------*/


// Fonction necesaire pour le dessin du mur - page tuto joueur 2
void drawBackShape(float sw, color c) {
  beginShape(); // flou gauche
  stroke(c);
  strokeWeight(sw);
  noFill();
  vertex(-1200, height*0.6);
  vertex(width*0.6, height*0.6);
  vertex(width*0.4, height*0.3);
  vertex(-1200, height*0.3);
  //filter(BLUR, x);
  endShape();
}


// Fonction necesaire pour la couleur et l'effet de néons des murs - jeu
void drawBackShapes(float sw, color c) {
  beginShape(); // flou gauche
  stroke(c);
  strokeWeight(sw);
  noFill();
  vertex(-1200, height/9);
  vertex(width/3, height/9);
  vertex(width/2, height/1.15);
  vertex(-1200, height/1.15);
  endShape();
  beginShape(); // flou droit
  stroke(c);
  strokeWeight(sw);
  noFill();
  vertex(width+ 1200, height/9);
  vertex(width/3 + spacing, height/9);
  vertex(width/2 + spacing, height/1.15);
  vertex(width+ 1200, height/1.15);
  endShape();
}


// Fonction necesaire pour la couleur et l'effet de néons des murs - fin
void drawBackShapess(float sw,color c) {
  beginShape(); // mur droit
  stroke(c);
  strokeWeight(sw);
  noFill();
  vertex(width+ 1200, height/9);
  vertex(width/3 + sp, height/9);
  vertex(width/2 + sp, height/1.3);
  vertex(width+ 1200, height/1.3);
  endShape();
}


// Fonction necesaire pour la couleur et l'effet de néons des murs - fin
void drawBackShapess2(float sw, color c) {
  beginShape();  // mur gauche
  stroke(c);
  strokeWeight(sw);
  noFill();
  vertex(-1200, height/9);
  vertex(width/3, height/9);
  vertex(width/2, height/1.3);
  vertex(-1200, height/1.3);
  endShape();
}

void movieEvent(Movie m) { // Fonction pour la viéo de l'histoire d'Oho
  m.read();
}


/*----------------------------------------
 |                                         |
 |              FONCTION DRAW              |
 |                                         |
 ------------------------------------------*/


void draw () {


  // Conditions de bases/constantes
  micro.update();
  background (0) ;
  if (!ArcadeGameMusic.isPlaying()) {
    ArcadeGameMusic.play();
  }

  // 0 - Page d'acceuil
  if (gameIndex == 0) {
    imageMode (CENTER);
    image(OhoHistory,width/4, height/4); 
    if (frameCount %25 == 0) { // on fait varier les deux images, une fois l'une, une fois l'autre 
      imageTitre = !imageTitre;
    }
    if (imageTitre == true) {
      image (ImageAccueil1, 0, 0, width, height);
    } else {
      image (ImageAccueil2, 0, 0, width, height);
    }
    image (Start, width/2, height/5*4, width/3, 2663*width/3/7218); // commande du bouton start
    if (micro.getAnalog0()>500) {
      gameIndex = 1; // on va à l'écran du tuto Oho 
    }
  }


  // 1 - tuto Joueur 1
  else if (gameIndex == 1) { // Nous sommes sur l'écran du tuto de Oho 
    imageMode (CENTER) ;// on intoduit nos images 
    image (Next, width/4*3.5, height/4*1.9, width/5, 2663*width/5/7218);
    image (TutoJoueur1, 0, 0, width, height);
    pushMatrix();
    float mouvement_oho = map(micro.getXAccel(), 20, -80, 0, width); // on calibre le mouvement de Oho en fonction des valeurs de l'accélérométre de la carte micro-bit 
    position_oho = (mouvement_oho - position_oho_avant) / 120 + position_oho_avant; // on veut que Oho bouge progessivement et on régle la vitesse d'Oho 
    position_oho_avant = position_oho; 
    translate (width/2 + position_oho, 0);
    image (Oho, 0, height/4*1.8, width/4, 1593*width/4/1792);
    popMatrix();
    if (position_oho+ width/2 > width/4*3.5) {  // quand oho atteint le bouton next 
      gameIndex = 2; // on va sur le tuto des murs 
    }
  }


  // 2 - tuto Joueur 2
  else if (gameIndex ==2) { // nous sommes sur l'écran du tuto des murs 
    imageMode (CENTER) ;
    image (Next, width/4*3.5, height/4*1.9, width/5, 2663*width/5/7218);
    image (TutoJoueur2, 0, 0, width, height);
    pushMatrix();
    float mouvement_murs = map(micro.getAnalog1(), 3, 160, -width*0.35, -width*0.15); //on calibre le mouvement des murs  en fonction des valeurs de le luminosité que reçoit la carte micro-bit 
    position_murs = (mouvement_murs - position_murs_avant) / 105 + position_murs_avant; // on veut que les murs bougent progressivment et on règle leur vitesse 
    position_murs_avant = position_murs;
    translate(position_murs, 0); // faire bouger murs
    for (int i = 10; i > 00; i--) { // i nombre de rectangle 
      drawBackShape((i+1)*5, color(255, 178, 255, 255 - i*25)); // on associe notre juxtaposition de murs décrire avnt le draw un dégradé de couleur pour donner un effet de néon  
    }
    popMatrix();
    if (position_murs + width/2 > width*0.85) { // quand le mur atteint le bouton next 
      gameIndex = 3; // nous allons à l'écran du décompte 
      Decompte =3; // On réinitialise le décompte de l'écran suivant, pour que lorsqu'on fait retry le décompte recommence à 3
    }
  }


  // 3 - Démarage / compte à rebourd
  else if (gameIndex ==3) { // aller sur l'écran du décompte
    m += 1;
    if ( m %30== 0 && Decompte > 0) {
      Decompte = Decompte -1;
    }
    fill (0, 255, 0);
    textAlign (CENTER);
    textSize(250);
    text (Decompte, width/2, height/5*1.8); // l'affichage du texte dépend de notre décompte 
    imageMode (CENTER);
    image (Goal, width/2, height/5*3.5, width/5*4, 2751*width/5*4/8476);
    if (Decompte == 0) {
      gameIndex = 4;
      m = 0;
      position_oho = 0;// on réinitialise la position d'Oho pour que lorsqu'on fait retry la position d'Oho soit la même
      position_murs = 0; // on réinitialise la position du mur pour que lorsqu'on fait retry la position des murs soit la même 
      Timer = 60; // on réinitialise le timer pour que lorsqu'on fait retry le décompte recommence à 60
    }
  }


  // 4 - Jeu
  else if (gameIndex ==4) { // aller sur l'écran jeu

    
    if (gameOver == false) { // si Oho ne perd pas, le jeu continue
      pushMatrix(); 
      float mouvement_murs = map(micro.getAnalog1(), 3, 160, -3.5, 3.5);  //on calibre le mouvement des murs  en fonction des valeurs de le luminosité que reçoit la carte micro-bit 
      position_murs += mouvement_murs;

      translate(position_murs, 0);
      for (int i = 10; i > 00; i--) { //i nombre de murs répétés
        drawBackShapes((i+1)*5, color(255, 178, 255, 255 - i*25)); // on associe notre juxtaposition de murs décrire avant le draw un dégradé de couleur pour donner un effet de néon 
      }
      popMatrix();


      //// problème détection colision
      if (position_oho < position_murs + spacing -165 && position_oho > position_murs -75) { // Lorsque la position de Oho est comprise entre les deux murs 
        
        lifeLost = false; // on ne perd pas de vie 

        // Afficher l'état des vies
        if (lifeCounter == 3) { // lorsqu'Oho a ces trois vies
          image(animation1.images[0], width*0.05, height*0.05); // introduction des stades de vies 
        } else if (lifeCounter == 2) {
          image(animation2.images[0], width*0.05, height*0.05  );
        } else if (lifeCounter == 1) {
          image(animation3.images[0], width*0.05, height*0.05  );
        } else if (lifeCounter == 0) {
          image(animation3.images[0], width*0.05, height*0.05  );
        }
        
        
      } else {

        if (lifeLost == false) {
          lifeCounter = lifeCounter - 1; // On fait diminuer le compter de vie 
          position_oho = 0;
          position_murs = 0;
        }

        timer_vies += 1;

        if (play_animation) {
          if (lifeCounter == 2) {
            animation1.display(width*0.05, height*0.05);
          } else if (lifeCounter == 1) {
            animation2.display(width*0.05, height*0.05);
          } else if (lifeCounter == 0) {
            animation3.display(width*0.05, height*0.05);
          }
        }

        if (timer_vies %40 == 0) {
          timer_vies = timer_vies - 1;

          if (timer_vies == 0) {
            play_animation = false;
          }
          if (lifeCounter == -1) {
            gameOver = true;
           
          }
        } 
        lifeLost = true;
      }
     
      
      pushMatrix();// Changement des images d'Oho 
      float mouvement_oho = map(micro.getXAccel(), 15, -13, -5, +5); //on calibre le mouvement des murs  en fonction des valeurs de l'accéléromètre de la carte micro-bit 
      position_oho = position_oho + mouvement_oho; // on veut que les murs bougent progressivment et on règle leur vitesse 
      translate(position_oho, 0);

      if (lifeCounter != 0 && lifeLost == false) { // Toutes les situations où les vies ne sont pas égales à 0 
        image(photo, width/2, height/2, 300, 300);// position/affichage image
         if (!OhoTheme.isPlaying()){
         OhoTheme.play();
         }
     
      }
      if (lifeLost == true && lifeCounter!=0) { // Lorsque Oho touche un mur et que le nombre de vie n'est pas 0
        image(Oho_PasContent, width/2, height/2, 300, 300);
        if (!Outch.isPlaying()) {
          Outch.play();
        }
      }
      if (lifeCounter==0) { // Lorsque Oho perd 
        image(Oho_Explosion, width/2, height/2, 300, 300);
        if (!OhoDead.isPlaying()) {
          OhoDead.play();
        }
      }
      popMatrix(); 
    }


    // Timer du jeu
    j += 1; 
    if (j % 60 == 0 && Timer > 0) {
      Timer = Timer - 1; // On fait diminue le Timer, on fait donc un décompte 
    }

    fill (0, 255, 0);
    textAlign (CENTER);
    textSize (50);
    text (Timer, width/10*9.5, height/10*9.8);


    // Lors que l'un des deux joueurs perd
    if (Timer == 0) { // Lorsque le Timer vaut 0, Oho gagne 
      gameIndex = 5; // Si Oho gagne et les murs perdent, on va sur l'écran où le joueur 1 gagne et le joueur 2 perd 
      
    }
    if (lifeCounter == 0) { // Lorsqu'il n'y a plus de vie, Oho perd
      gameIndex = 6; // Si Oho perd et les murs gagnent, on va sur l'écran où le joueur 1 perd et le joueur 2 gagne 
    }
    
    
  } else if (gameIndex == 5) { // on va sur l'écran où c'est oho qui a gagné 
    lifeCounter = 3; // on réinitialise le nombre de vie pour en avoir 3 quand on rejoue 
   
    for (int i = 10; i > 00; i--) { // nombre de murs répétés
      drawBackShapess((i+1)*5, color(255, 178, 255, 255 - i*25)); // on remet notre juxtapositions de rectangles avec un dégradé de couleur 
      drawBackShapess2((i+1)*5, color(0, 255, 255, 255 - i*25));
    }
    imageMode(CENTER); // introduction de nos images
    image(Joueur1gagnant, 0, 0, width, height);
    image(Retry, width/2, height*8*7, width/4, 2663*width/4/7218);
    if (micro.getAnalog0()>500) { // commande du bouton retry 
      gameIndex = 3; // retourner au décompte avant le jeu 
    } else {
      n += 1; 
      if (n % 60 == 0 && Attente > 0) { // au boût de 20 secondes, si retry n'a pas été clické, on retourne automatique à la page d'accueil
        Attente = Attente - 1; // on fait diminue l'attente 
      }
      if  (Attente == 0) { // lorsque l'attente est égale à 0, on retourne à l'accueil 
        gameIndex = 0;
      }
    }
  } else if (gameIndex == 6) { // on va sur l'écran où c'est oho qui a perdu
    lifeCounter = 3; // on réinitialise le nombre de vie pour en avoir 3 quand on rejoue 
  
    for (int i = 10; i > 00; i--) { // nombre de murs répétés
      drawBackShapess((i+1)*5, color(255, 178, 255, 255 - i*25)); // on remet notre juxtapositions de rectangles avec un dégradé de couleur 
      drawBackShapess2((i+1)*5, color(0, 255, 255, 255 - i*25)); 
    }
    imageMode(CENTER); // introduction de nos images
    image(Joueur1perdant, 0, 0, width, height);
    image(Retry, width/2, height/8*7, width/4, 2663*width/4/7218);
    if (micro.getAnalog0()>500) { // commande du bouton retry 
      gameIndex = 3; // retourner au décompte avant le jeu 
    } else {
      n += 1;
      if (n % 60 == 0 && Attente > 0) { // au boût de 20 secondes, si retry n'a pas été clické, on retourne automatique à la page d'accueil
        Attente = Attente - 1; // on fait diminue l'attente 
      }
      if  (Attente == 0) { // lorsque l'attente est égale à 0, on retourne à l'accueil
        gameIndex = 0;
      }
    }
  }

  //text("DEBUG", 20, 50); // En cas de problème avec les capteurs 
  //text("gameIndex : " + gameIndex, 20, 65);
  //text("micro.getAnalog0() : " + micro.getAnalog0(), 20, 80);
  //text("micro.getXAccel() : " + micro.getXAccel(), 20, 95); 
  //text("micro.getAnalog1() : " + micro.getAnalog1(), 20, 110);

  // println(gameIndex);
}// fermeture draw
