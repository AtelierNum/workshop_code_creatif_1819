class Hamburger {
  float posX, posY, kcal ;

  Hamburger(float xpos, float ypos, float calories) {
    this.posX = xpos;
    this.posY = ypos;
    this.kcal = calories;
  }
  
  void hambStyle(){
    pushStyle();
    fill(255);
    noStroke();
    //float x = random(width / 2 - 50, width / 2 + 50);
    //float y = random(height / 2 - 50, height / 2 + 50);
    Radius = kcal;
    Popper1.initPop(Radius);
    Popper1.display(posX,posY);
    Popper1.resizer();
    popStyle();
  }
}
