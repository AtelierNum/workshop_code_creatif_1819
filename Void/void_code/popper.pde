class popper { 

  float stepSize = 2;
  float xoff =0;


  void initPop(float rad) {
      /////////// INIT POPPERS //////////
  float angle = radians( 360 / float(formResolution));
  for (int i=0; i < formResolution; i++) {
    xbeg[i] = cos(angle*i) * rad;
    ybeg[i] = sin(angle*i) * rad;  
    xstart[i] = xbeg[i];
    ystart[i] = ybeg[i];
  }
  }
  

  void resizer() {
    for (int i = 0; i < formResolution; i++) {
      xbeg[i] = lerp(xbeg[i], xstart[i], 0.5);
      ybeg[i] = lerp(ybeg[i], ystart[i], 0.5);
    }
  }


  void display(float _x, float _y) {
    centerX = _x; 
    centerY = _y;
    //float angle = radians(360/float(formResolution));
    //float radius = initRadius * rdom(0.5, 1.0);

    beginShape();
    // start controlpoint
    curveVertex(xbeg[formResolution-1] + centerX, ybeg[formResolution-1] + centerY);

    for (int i = 0; i < formResolution; i++) {
      noisoff += 0.1;
      noisoff += 0;
      stepSize = noise(noisoff)*2;
      xbeg[i] += random(-stepSize, stepSize);
      ybeg[i] += random(-stepSize, stepSize);
      // ellipse(x[i], y[i], 5, 5);
    }
    // only these points are drawn
    for (int i=0; i < formResolution; i++) {
      curveVertex(xbeg[i] + centerX, ybeg[i]+centerY);
    }
    curveVertex(xbeg[0] + centerX, ybeg[0]+centerY);

    // end controlpoint
    curveVertex(xbeg[1] + centerX, ybeg[1]+centerY);
    endShape();
  }
}
