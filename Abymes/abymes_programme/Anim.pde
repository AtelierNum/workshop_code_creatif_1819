class Anim {
  //proprietes de la classe Boule
  float x, y;
  float vx, vy;
  boolean b; //variable vraie ou fausse

  //constructeur de Anim
  Anim(boolean b_, float x_, float _vx) { 
    vx = _vx; //direction random entre 2 et 5 en abscisse (vers la droite)
    vy = 0; // direction random negtaive (vers le haut) ou positive (vers le bas)
    x = x_; // on attribue la variable boolean x_ à la variable x(abscisse du point de départ de l'anim)
    y = height*0.5; // ordonnée du pt de départ
    b = b_;
  }

  /* on ne sait plus si c'est vraiment utile
   Anim(float x, float y) {
   this.x = x;
   this.y = y;
   this.vx = vx;
   this.vy = vy;
   vx = 1;
   vy = 1;
   }*/

  void deplacer() { //fonction qui permet de diriger les déplacements des particules
    x += random(-1, 1);
    // ajouter -1, 0, ou +1 à la position y de la chose
    y += random(-1, 1);

    /*
    if (x < 10) {
     vx = -vx;
     x = 10;
     }
     if (x > width - 10) {
     vx = -vx;
     x = width - 10;
     }
     if (y < 10) {
     vy = -vy;
     y = 10;
     }
     if (y > height - 10) {
     vy = -vy;
     y = height - 10;
     }*/

    if ((dist(x, y, width*0.5, height*0.5) < 100)) { //si particule entre dans la zone au centre, elle est ralentie
      x += vx*0.5;
      y += vy*0.5;
    }

    if (dist(x, y, width*0.5, height*0.5) > 100) { //si particule n'est pas dans la zone au centre, elle est plus rapide
      x += vx*2;
      y += vy*2;
    }

    //rebonds sur les bords
    // if ( (x < 0) || (x > width) ) vx = -vx; //si le centre de la particule sort de la fenetre, on inverse sa direction 
    //if ( (y < 0) || (y > height) ) vy = -vy;
  }

  void afficher() { //affichage des animations

    fill(micro.getYMag(), micro.getYMag(), 255); //couleur des particules en fonction de l'inclinaison avant-arriere de la carte
   

    if (b==true) {
      rectMode(CENTER);
      rect(x, y, 30, 30); //si b true, animation carrés --> voir interaction_anim pour voir pk b est true ou false
      
      /*pushStyle();
      noFill();
      stroke(255, 255, 255);
      ellipse(width, height*0.5, x/(frameCount/50), x/(frameCount/50)); //ondes quand particule anvoyée
      popStyle();*/
      
    } else {
      ellipse(x, y, 30, 30); //si b false, animation boules
      
      pushStyle();
      noFill();
      stroke(255, 255, 255);
      ellipse(0, height*0.5, x*frameCount/50, x*frameCount/50); //ondes quand particule anvoyée
      popStyle();
    }
  }
}