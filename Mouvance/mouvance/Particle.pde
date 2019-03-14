class Particle { //CLASSE PARTICULES VENT

  PVector pos;
  PVector vel;
  PVector acc;
  float size;
  float maxforce;   
  float maxspeed;
  float angle;
  float angleIncrement;

  Boolean flowing = true;
  Boolean repelling = false;
  Boolean attracting = false;
  Boolean stopped = false;
  Boolean rippling = false;
  Boolean trembling = false;
  Boolean spiralling = true;
  Boolean start = false;
  Boolean inVortex = false;

  float ripplingSize = 0;
  float distanceFromCenter = 0;
  float startDistance = domeRadius;
  int trembleTime = 0;
  int index;

  PVector previous = new PVector();
  PVector vortexCenter;
  float radius = random(50, 200);
  float dec = (200 - radius) * 0.000014;
  //float tilt = random(-60,60);
  float turnVelocity;


  Particle (float _x, float _y, float _maxspeed, float _maxforce, int _index) {
    pos = new PVector(_x, _y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    size = 3.5;
    angle = 0;
    angleIncrement = random(0.005, 0.05);
    maxforce = _maxforce;
    maxspeed = _maxspeed;
    index = _index;
  }

  /**
   * Calculates the noise angle in a given position
   * @param      _x      Current position on the x axis
   * @param      _y      Current position on the y axis
   * @return     Float   Noise angle
   */
  float getNoiseAngle(float _x, float _y) {
    return map(noise(_x/noiseOndulation + noiseVariation, _y/noiseOndulation + noiseVariation, frameCount/noiseInterval + noiseVariation), 0, 1, 0, TWO_PI*2);
  }

  /**
   * Sets acceleration to follow the noise flow
   */
  void flow() {
    float noiseAngle = getNoiseAngle(pos.x, pos.y);
    PVector desired = new PVector(cos(noiseAngle)*noiseResistance, sin(noiseAngle)*noiseResistance);
    desired.mult(maxspeed);
    PVector steer = PVector.sub(desired, vel);
    steer.limit(maxforce); 
    applyForce(steer);
  }


  /**
   * Rotates the particle from a given radius
   * @param      _radius    Distance from the center to rotate from
   */
  void circleRotation(float _radius) {
    angle += angleIncrement;
    if (angle >= TWO_PI) angle = 0;
    PVector target = new PVector(width/2 + (_radius * cos(angle)), height/2 + (_radius * sin(angle)));
    PVector desired = PVector.sub(target, pos);
    follow(desired);
  }

  /**
   * Sets a random velocity in three intervals to simulate a trembling effect
   */
  void tremble() {
    flowing = false;
    PVector variation = new PVector(random(-1, 1), random(-1, 1));
    vel.add(variation);
    if (trembleTime > maxTrembleTime/3) vel.add(variation);
    if (trembleTime > 2*(maxTrembleTime/3)) vel.add(variation);  

    trembleTime++;
    if (trembleTime > maxTrembleTime) { 
      trembleTime = 0;
      trembling = false;
      flowing = true;
    }
  }

  void vortex(float turn) {
    PVector current = new PVector(radius * cos(angle), /*tilt + 20 **/ cos(angle + 3.5), radius * sin(angle));
    if (turn != 0) turnVelocity = turn * (201-radius);
    angle -= dec + turnVelocity;
    turnVelocity *= 0.95;

    if (previous.x == 0) {
      previous.set(current);
    }

    isoLine(current, previous, angle);
    previous.set(current);
  }

  void isoLine(PVector begin, PVector end, float angle) {
    PVector newBegin = new PVector((begin.x - begin.z), ((begin.x + begin.z)/2 - begin.y));
    PVector newEnd = new PVector((end.x - end.z), ((end.x + end.z)/2 - end.y));
    borders();
    stroke(255);
    pushMatrix();
    translate(vortexCenter.x, vortexCenter.y);
    strokeWeight(2);
    line (newBegin.x, newBegin.y, newEnd.x, newEnd.y);
    //ellipse(newBegin.x, newBegin.y, 2, 2);
    popMatrix();
  }

  /**
   * Maps the particle size according to the distance between its position and the ripple radius
   */
  void ripple() {
    float distance = abs(dist(pos.x, pos.y, width/2, height/2) - rippleRadius);

    if (distance < 50) { 
      rippling = true;
      ripplingSize = map(distance, 50, 0, 0, 7);
      repelling = true;
      magnet(width/2, height/2, rippleRadius + 25, 10);
    } else {
      rippling = false;
      repelling = false;
    }
  }

  /**
   * Sets the particle acceleration to follow a desired direction
   * @param      _desired    Vector to follow
   */
  void follow(PVector _desired) {
    _desired.normalize();
    _desired.mult(maxspeed);
    PVector steer = PVector.sub(_desired, vel);
    steer.limit(maxforce); 
    applyForce(steer);
  }

  /**
   * Spiral effect from the borders to the top of the dome 
   */
  void spiral() {    
    if (start && spiralling) {
      angle += 0.03;
      startDistance -= 0.3;
      if (angle >= TWO_PI) angle = 0;
      pos.x = startDistance * cos(angle) + width/2;
      pos.y = startDistance * sin(angle) + height/2;

      if (spiralling && startDistance < 10) {
        spiralling = false;
        particleSpiral++;
      }
    }
  }

  /**
   * Particle falls to the closest border of the dome to end the sequence
   */
  void fall() {
    flowing = false;
    repelling = true;
    attracting = false;
    inverted = false;

    magnet(width/2, height/2, domeRadius, 1500);
  }

  /**
   * Repels or attracts the particles within a distance
   * @param      _x           X coordinate of the magnet center
   * @param      _y           Y coordinate of the magnet center
   * @param      _radius      Distance affected by the magnet effect
   * @param      _strength    Strength of the magnet force
   */
  void magnet(float _x, float _y, float _radius, float _strength) {
    float magnetRadius = _radius;
    PVector target = new PVector(_x, _y);
    PVector force = PVector.sub(target, pos);
    float distance = force.mag();

    if (distance < magnetRadius) {
      flowing = false;
      distance = constrain(distance, 5.0, 25.0);
      force.normalize();
      float strength = 0.00;
      if (repelling) strength = (500 + _strength) / (distance * distance * -1);
      if (attracting) strength = (50 + _strength) / (distance * distance);
      force.mult(strength);        
      applyForce(force);
    } else {
      flowing = true;
    }
  }

  /**
   * Adds a vector to the current acceleration
   * @param      _force    Vector to add 
   */
  void applyForce(PVector _force) {
    acc.add(_force);
  }

  /**
   * Updates the acceleration, velocity and position vectors
   */
  void update() {
    if (!stopped) {
      if (inverted) acc.mult(-1);
      vel.add(acc);
      vel.limit(maxspeed);
      pos.add(vel);
      acc.mult(0);
    }
  }

  /**
   * Displays the particle on the canvas
   */
  void display() {   
    /* --------Color fill-------- */
    //fill(map(pos.x, width/2 - domeRadius, width/2 + domeRadius, 250, 360), 100, 100);    
    /* --------White fill-------- */
    fill(#f21906);

    noStroke();
    ellipse(pos.x, pos.y, size+ripplingSize, size+ripplingSize);
  }

  /**
   * Recursive function that sets a random position to the particle within the dome area
   */
  void position() {
    pos.x = width/2 - ((domeRadius - 15) * cos(random(TWO_PI)));
    pos.y = height/2 - ((domeRadius - 15) * sin(random(TWO_PI)));

    float distance = dist(pos.x, pos.y, width/2, height/2);
    if (distance > domeRadius) position();
  }


  /**
   * Checks whether the particle is going out of bound and sets its position to the opposte side of the dome
   */
  void borders() {
    float distance = dist(pos.x, pos.y, width/2, height/2);    
    if (distance > domeRadius) {
      if (falling) {
        stopped = true;
      } else {
        /* --------Warp particles to a random location-------- */
        //position();

        /* --------Warp particles to opposite side-------- */
        float theta = atan2(pos.y - height/2, pos.x - width/2);
        pos.x = (width/2 + (domeRadius * cos(theta + PI)));
        pos.y = (height/2 + (domeRadius * sin(theta + PI)));
      }
    }
  }

  /**
   * Calls the functions that run every frame
   */
  void run() {
    update();
    borders();
    display();
  }

  void modifierVitesse(float _m) {
    maxspeed = _m;
  }
}
