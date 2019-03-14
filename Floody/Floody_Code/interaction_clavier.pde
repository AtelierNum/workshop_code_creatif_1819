//DIRECTION FENETRE 
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      origine_y -= 10;
    } 
    if (keyCode == DOWN) {
      origine_y += 10;
    } 
    if (keyCode == LEFT) {
      origine_x -= 10;
    } 
    if (keyCode == RIGHT) {
      origine_x += 10;
    }
  }
  if (key == '0') {
    gameIndex = 0;
  }
  if (key == '1') {
    gameIndex = 1;
  }
  if (key == '2') {
    gameIndex = 2;
  }
  if (key == '3') {
    gameIndex = 3;
  }
  if (key == 'x') {
    radius = 80;
  }
  if (key == 'f') {
    etatPerso ++;
    if (etatPerso > 2) etatPerso = 0;
  }
  if (key == 'd') {
    etatPerso --;
    if (etatPerso < 0) etatPerso = 2;
  }
}
