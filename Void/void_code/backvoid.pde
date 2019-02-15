class backvoid {
  float xposvoid;
  float yposvoid;
  float speedvoid = random(0.025);
  float tposvoid=random(0,TWO_PI);
  float radiusvoid = 150 * 1.37;
  float sizevoid = random(2,4);
  float sensvoid= random(0,1);
  

  void update(int index) {
    radiusvoid-=1;
    if (sensvoid < 0.5) {
      tposvoid += speedvoid;
    } else {
      tposvoid -= speedvoid;
    }
    float sinvalvoid = sin(tposvoid);
    float cosvalvoid = cos(tposvoid);
    xposvoid = (width / 2) + (cosvalvoid * radiusvoid);
    yposvoid = (height / 2) + (sinvalvoid * radiusvoid);
    if(radiusvoid < 0){
      Backvoid.remove(index);
    }
    
  }

  void display() {
    fill(0, 0, 204);
    noStroke();
    ellipse(xposvoid, yposvoid, sizevoid, sizevoid);
  }
}
