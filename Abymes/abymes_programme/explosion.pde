
class Explosion {

  float x;
  float y;
  float life;

  Star [] stars = new Star [40];
  Rect [] rectangle = new Rect [40];



  Explosion(float x, float y) {
    this.x = x;
    this.y = y;

    for (int i = 0; i < stars.length; i++) { 
      stars [i] = new Star();
    }
    for (int i = 0; i < rectangle.length; i++) { 
      rectangle [i] = new Rect ();
    }
  }

  void update() {
    life += 2 ;
  }

  void display() {
     
    pushStyle();
    pushMatrix();
    translate(x, y);
    for (int i = 0; i < stars.length; i++) { //afficher l'explosion d'ellipses jusqu'au max
      stars[i].update_st();
      stars[i].display_st();
    }
    for (int i = 0; i < rectangle.length; i++) { //afficher l'explosion de rectangles jusqu'au max
      rectangle[i].update_rec();
      rectangle[i].display_rec();
    }
    popStyle();
    popMatrix();
  }
}