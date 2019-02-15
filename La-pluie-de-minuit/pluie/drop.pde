class Drop {


  
  float x = random(width); //récupérer un x random dans la largeur de l'écran
  float y = random(-500, -100); //récupérer un y random entre -500 et -100

  float z = random(0, 20); //z random entre 0 et 20, pour donner l'effet de profondeur (parallaxe)
  float yspeed = map(z, 0, 20, 4, 10); //récupération d'une vitesse en ordonéee aléatoire 
  float xspeed = map(z, 0, 20, 4, 10); // récupération d'une vitesse en absice aléatoire

  Drop() { //constructeur d'un drop
  }

  void fall() { //fonction qui fait descendre les drops

    xspeed = map(pico.getSound(), 0, width, 0, 15); //lorsque quelqu'un souffle, le x se décale 
    x = x + xspeed; //décalage en fonction de la vitesse
    y = y + yspeed;
    float grav = map(z, 0, 20, 0, 0.2); //définition d'une gravité aléatoire pour la vitesse
    yspeed = yspeed + grav;

   
    if (x>width) { //recadrage de drop dans l'écran en x
      x = random(0, -100);
      xspeed =map(z, 0, 20, 1, 10);
    }

    if (y > height) { //recadrage de drop dans l'écran en y
      y = random(0, -100);
      yspeed = map(z, 0, 20, 1, 10);
    }
  }
  
  void modifierVitesse(float modificateur) {//fonction qui change la vitesse de descente d'un drops
    yspeed = yspeed * modificateur;
  }

  void show() {//fonction qui montre sur le sketch drop
  //défition du design de drop
    float thick = map(z, 0, 20, 1, 3);
    strokeWeight(thick); 
    stroke(255);
   
  //définition de l'inclinaison de drop (si quelqu'un souffle)
    float inclinaison = map(xspeed, -5, 5, -20, 20);
    
    //dessin de la drop en prenant en compte sa taille (x et y) ainsi que son angle
    line(x, y, x +inclinaison, y+20);
  }
}
