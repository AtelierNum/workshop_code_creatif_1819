class Rect {
  float x_rec; 
  float y_rec; 
  float z_rec; // on rajoute une variable dans le plan 
 

  Rect() {
    x_rec = width/2; 
    y_rec = height/2; 
    z_rec = random(width/4); // la veleur qui va les faire grossir pour créer l'illusion de 3 plan
  }

  void update_rec () {
    z_rec = z_rec - 25 ;  //si vitesse avec MouseX remplacer '10' par "speed"
    if (z_rec < 1) { 
      z_rec = width;
      x_rec = random(-25,25); 
      y_rec = random(-25,25);
    }
  }

  void display_rec () {
    fill (255); 
    noStroke();
    
    float sx_rec = map(x_rec / z_rec, 0, 1, 0, width); //adaptation des coordonnées de l'anim à la taille de la fenetre
    float sy_rec = map(y_rec / z_rec, 0, 1, 0, height);

    float r_rec = map(z_rec, 0, width/4, 10, 0); 
    // ellipse(sx_st, sy_st, r_st, r_st);
    rect(sx_rec, sy_rec, r_rec, r_rec);
  }
}

// Je veux pouvoir affiché des ellipse ou des rectangle