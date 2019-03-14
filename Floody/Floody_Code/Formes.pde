
class Boule {
  float x, y; // coordonnées dans l'espace virtuel
  float d; // diametre de l'objet

  Boule(int _largeur, int _hauteur) {
    x = random(_largeur);
    y = random(_hauteur);
    d = random(18, 30);
  }

  // Cet élément apparaît il dans la fenêtre ?
  // _x, _y : origine de la fenêtre d'affichage dans l'espace virtuel
  // _l, _h : largeur et hauteur de la fenêtre d'affichage
  boolean visible(int _x, int _y, int _l, int _h) {
    if ( (x >= _x) && (x < (_x + _l)) && (y >= _y) && (y < (_y + _h)) ) {
      return true;
    } else return false;
  }

  // Afficher l'objet en fonction de la position de l'origine de la fenêtre d'affichage
  void dessiner(int _x, int _y) {
    stroke(255);
    fill(255);
    ellipse(x - _x, y - _y, d, d);
  }
}

class Carre {
  float x, y; // coordonnées dans l'espace virtuel
  float d; // diametre de l'objet

  Carre(int _largeur, int _hauteur) {
    x = random(_largeur);
    y = random(_hauteur);
    d = random(8, 30);
  }

  // Cet élément apparaît il dans la fenêtre ?
  // _x, _y : origine de la fenêtre d'affichage dans l'espace virtuel
  // _l, _h : largeur et hauteur de la fenêtre d'affichage
  boolean visible(int _x, int _y, int _l, int _h) {
    if ( (x >= _x) && (x < (_x + _l)) && (y >= _y) && (y < (_y + _h)) ) {
      return true;
    } else return false;
  }

  // Afficher l'objet en fonction de la position de l'origine de la fenêtre d'affichage
  void dessiner(int _x, int _y) {
    rectMode(CENTER);
    stroke(255);
    fill(255);
    rect(x - _x, y - _y, d, d);
  }
}

class Triangle {
  float x, y; // coordonnées dans l'espace virtuel
  float d; // diametre de l'objet

  Triangle(int _largeur, int _hauteur) {
    x = random(_largeur);
    y = random(_hauteur);
    d = random(11, 30);
  }

  // Cet élément apparaît il dans la fenêtre ?
  // _x, _y : origine de la fenêtre d'affichage dans l'espace virtuel
  // _l, _h : largeur et hauteur de la fenêtre d'affichage
  boolean visible(int _x, int _y, int _l, int _h) {
    if ( (x >= _x) && (x < (_x + _l)) && (y >= _y) && (y < (_y + _h)) ) {
      return true;
    } else return false;
  }

  // Afficher l'objet en fonction de la position de l'origine de la fenêtre d'affichage
  void dessiner(int _x, int _y) {
    stroke(255);
    fill(255);

    float x1 = x + d * cos(PI*3/4);
    float y1 = y + d * sin(PI*3/4);

    float x2 = x + d * cos(PI*5/4);
    float y2 = y + d * sin(PI*5/4);

    float x3 = x + d * cos(PI*7/4);
    float y3 = y + d * sin(PI*7/4);
    triangle(x1 -_x, y1 -_y, x2 - _x, y2 - _y, x3 - _x, y3 - _y);
  }
}
