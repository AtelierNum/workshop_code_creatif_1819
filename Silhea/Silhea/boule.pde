//class boule nous permet de faire apparaitre les différentes ellipse géré par le potientiomètre.
class Boule {
  float x, y;
  


  Boule()
  {
    x = random(width);
    y = random(height);
    
  }
  

  void afficher()
  {
    strokeWeight(1);
    fill(221,214,255,70);
    ellipse(x, y,60 , 60);
  }
}
