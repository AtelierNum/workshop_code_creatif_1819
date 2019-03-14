class Star {
  float x_st; 
  float y_st; 
  float z_st; // on rajoute une variable dans le plan 
 

  Star() {
    x_st = width/2; 
    y_st = height/2; 
    z_st = random(width/4); // la veleur qui va les faire grossir pour créer l'illusion de 3 plan
  }

  void update_st () {
    z_st = z_st - 25 ;  //si vitesse avec MouseX remplacer '10' par "speed"
    if (z_st < 1) { 
      z_st = width;
      x_st = random(-25,25); 
      y_st = random(-25,25);
    }
  }

  void display_st () {
    fill (255); 
    noStroke();
    
    float sx_st = map(x_st / z_st, 0, 1, 0, width); //adaptation des coordonnées de l'anim à la taille de la fenetre
    float sy_st = map(y_st / z_st, 0, 1, 0, height);

    float r_st = map(z_st, 0, width/4, 10, 0); 
    // ellipse(sx_st, sy_st, r_st, r_st);
    ellipse(sx_st, sy_st, r_st, r_st);
  }
}

// Je veux pouvoir affiché des ellipse ou des rectangle