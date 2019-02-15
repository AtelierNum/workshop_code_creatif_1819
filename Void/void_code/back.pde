class back {
  float xpos;
  float ypos;
  float speed = random(0.005);
  float tpos=0;
  float r = random(210, 310);
  float rxback = random(sliderValue, sliderValueY);
  float ryback = random(sliderMinX, sliderMinY);
  float size = random(1, 5);
  float sens= random(0,1);
  float xpos1;
  float ypos1;
  float cosval;
  float sinval;
  float tpos1;
  float tposmin=0;

  void update() {
    if (sens < 0.5) {
      tpos += speed;
    } else {
      tpos -= speed;
    }
    float sinval = sin(tpos);
    float cosval = cos(tpos);
    xpos = (width / 2) + (cosval * ryback * r);
    ypos = (height / 2) + (sinval * rxback * r);
  }

  void display() {
 tpos1 += 5;
    sinval = sliderValue * sin(tpos1);
    cosval = sliderValueY * cos(tpos1);
    xpos1 = (width / 2) + (cosval * 400);
    ypos1 = (height / 2) + (sinval * 400);
    
    fill(255);
    //ellipse(xpos1,ypos1,10,10);
    
    tposmin += 5;
    sinval = sliderMinX * sin(tpos1);
    cosval = sliderMinY * cos(tpos1);
    float xposmin = (width / 2) + (cosval * 150);
    float yposmin = (height / 2) + (sinval * 150);
    
    fill(255);
    //ellipse(xposmin,yposmin,10,10);
    
    //println("sliderValuecos = ", sliderValue);
    pushStyle();
    fill(0, 0, 204);
    noStroke();
    ellipse(xpos, ypos, size, size);
    popStyle();
  }
}
