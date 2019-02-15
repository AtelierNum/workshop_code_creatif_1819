class circlezone {
  float rotation = 0;
  float maxSize = 0.75;
  float minSize = 0.1;
  float currSize = 0.1;
  float ease = 0.1;

  void updater() {
    currSize += ((maxSize-currSize)*ease);
    drawBlackHole(currSize);
  }
  
  void drawBlackHole(float size) {
    pushMatrix();
    pushStyle();
    translate(width/2,height/2);
    //pgPop.beginDraw();
    //centers pen
    //loops through 10 times
    for (int i = 0; i < 3 ; i++) { //u change la densité de l'animation
      //rotates semi-randomly to add vaiation to the black hole
      rotation += random(0.05, 0.1);
      rotate(rotation);
      noFill();
      stroke(20, 20, 254);
     // ellipse(0, 0, random(1, 250 * size), 300 * size);
      rotate(rotation+90);
      ellipse(0, 0, random(1, 150 * size), 200 * size);
    }
          popStyle();
          popMatrix();
        //  endDraw();
         // image(pgPop,0,0);
  }
  void reset() {
    currSize = minSize;
  }
}
