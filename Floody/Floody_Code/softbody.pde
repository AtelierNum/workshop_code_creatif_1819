void drawShape() {
  // calculate node starting positions
  for (int i=0; i<nodes; i++) {
    nodeStartX[i] = centerX+cos(radians(rotAngle))*radius;
    nodeStartY[i] = centerY+sin(radians(rotAngle))*radius;
    rotAngle += 360.0/nodes;
  }

  // draw polygon
  curveTightness(organicConstant);
  noFill();
  beginShape();
  for (int i=0; i<nodes; i++) {
    curveVertex(nodeX[i], nodeY[i]);
  }
  for (int i=0; i<nodes-1; i++) {
    curveVertex(nodeX[i], nodeY[i]);
  }
  endShape(CLOSE);
}

void moveShape() {
  //move center point
  float deltaX = map(position_x, 200, -200, 0, 960) - centerX;
  float deltaY = map(position_y, 200, -200, 0, 940) - centerY;

  float deltaXmap = map(position_x, 200, -200, -50, 50) ;
  float deltaYmap = map(position_y, 200, -200, -50, 50) ;

  origine_x += deltaXmap ;
  origine_y += deltaYmap;

  // Untranslates
  //translate(mercury.x, mercury.y);
  //translate(-width/2+32*cos(mercury.a)*mercury.v, 
  // -height/2+32*sin(mercury.a)*mercury.v);
  //pour que ça marche il faut nommer la variable et appeler la collision pour ajouter un point a

  // create springing effect
  deltaX *= springing;
  deltaY *= springing;
  accelX += deltaX;
  accelY += deltaY;

  // move predator's center
  centerX += accelX;
  centerY += accelY;


  // slow down springing
  accelX *= damping;
  accelY *= damping;

  // change curve tightness
  organicConstant = 1-((abs(accelX)+abs(accelY))*.1);

  //move nodes
  for (int i=0; i<nodes; i++) {
    nodeX[i] = nodeStartX[i]+sin(radians(angle[i]))*(  accelX*2);
    nodeY[i] = nodeStartY[i]+sin(radians(angle[i]))*(  accelY*2);
    angle[i]+=frequency[i];
  }
}
