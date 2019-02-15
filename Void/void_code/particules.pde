class Particle {
  PVector location, vitesse, acceleration;
  float life = 255 ;
  boolean _faim ;
  //  float[] xT = new float [n];
  // float[] yT = new float[n];
  float xT, yT, maxLines;
  float[] xoff = new float[nb];
  float[] yoff = new float[nb];
  float[] xpos = new float[nb];
  float[] ypos = new float[nb];
  float numDist ;//numérateur pour l'attraction, modifié pour changer le rapport m 
  ArrayList<Toile> toiles = new ArrayList();


  Particle(float x, float y, int _transparenceLife) {
    // particle class should have location, vitesse & acceleration
    location = new PVector(x, y);
    vitesse = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    life = _transparenceLife;
  }

  /////////////////////////////// CALCULS VECTEURS /////////////////////////
  PVector calculAttraction(float _xT, float _yT) {
    target = new PVector(_xT, _yT);
    // println("target :", target.x, "  ", target.y);
    // println("location :", location.x, "  ", location.y);
    PVector attraction = PVector.sub(target, location); //make vector pointing towards target
    float distance = attraction.mag();
    if (openDoor == true) {
      distance = distance * 0.73 ;    // également pour diminuer la valeur pour accéléder le mvt des particules, tout est bon dans le cochon!
      if ( timer > t_stamp ) numDist = 3; // particules qui s'excitent avant de se jeter sur la proie
    }

    float m = numDist /(distance * distance); //formule de gravité pour calculer la force = l'accélération
    attraction.normalize(); //distance vecteur = 1
    attraction.mult(m);
    maxLines = map(vitesse.mag(), 0, 5, 600, 998); //certes pas placé au mieux, mais j'utilise des variables localespour calculer distance...
    maxLines = constrain(maxLines, 600, 998); // utilisé pour contraindre un peu le nombre de ligne tracé si l'agent est lent (et éviter l'impression gros paté)
    return attraction;
  }


  PVector calculFriction() {
    PVector friction = vitesse.get();
    friction.normalize();
    friction.mult(-1); //produit scalaire
    friction.mult(0.4);
    return friction;
  }


  ///////////////////////////////////////  APPLY FORCES ///////////////////////////////////
  void applyForces() {
    PVector attraction = calculAttraction(xT, yT);
    PVector friction = calculFriction();
    acceleration.add(attraction);
    acceleration.add(friction); //ici le vecteur accélération est calculé
    vitesse.add(acceleration); //la vitesse = dérivée de l'accélération
    vitesse.limit(5); //vitesse max
  }


  ///////////////////// RESTER DANS L'ECRAN /////////////////////////////////
  //ensure that the particles remain on screen
  void stayHereBro() {
    PVector testVect = location; // vecteur temporaire pour faire les tests
    testVect.add(vitesse);
    int dir = (int(random(0, 2)) < 1) ? 1: -1;     //set rebound direction
    float donuts = dist(testVect.x, testVect.y, width /2, height /2);
    if (donuts > 400 * 0.79) {
      vitesse.x = - vitesse.x * 2; //rebondir sur la paroi,
      vitesse.y = dir * vitesse.y; //dans n'importe quelle direction
      //println("sortie X");
    }
    degagedela(testVect.x, testVect.x); //zone centrale
  }

  /////////////////////// ZONE CENTRALE //////////////////////////////////
  void degagedela(float _vectX, float _vectY) {
    //dégagez ! c'est le blackhole ici !
    float  trou = dist(width / 2, height / 2, _vectX, _vectY);

    if (trou < 161 && openDoor == false) { //si ils sont à X distance du centre et qu'il n'y a pas de food,
      int dir = (int(random(0, 2)) < 1) ? 1: -1;       //attribut 
      int dir2 = (int(random(0, 2)) < 1) ? 1: -1;       //attribut 2
      numDist = 8000 ; //en augmentant le numérateur du rapport d'attraction, j'augmente sa vitesse de déplcement : l'agent est perturbé car ilse trovue dans "LA ZONE INTERDIIIIITE" --> il peut forcer la condition pour en sortir (plus rapidement au passage) car les déplacements effectués sont plus grands
      xT = _vectX + ( 50 * dir );     // forcer une ejection du centre
      yT = _vectY + ( 50 * dir2 );
      applyForces();

      //tracés fantômes ; d'où sortent-ils ?
      //  pushStyle();
      // fill(255, 0, 0);
      // noStroke();
      // ellipse(_zoneX, _zoneY, 5, 5);
      // popStyle();

      // println("trou = ", trou);
      // println("////////////", _zoneX, " ////// zoneY = ", _zoneY);
      // println("vitesse = ", vitesse);
    }
  }

  /////////////////// COWARDS ////////////////////////////////////// 
  //sometimes, some of them are des petits coquins qui passent à travers les mailles du filet, et ici, c'est une dictature ! Tout le monde reste dans l'octogone .
  //donc les lâches fuyant la sainte mère patrie seront éliminés sans regrets
  void killCowards() {
    for (int i = 0; i < particules.size(); i ++) {
      float fuite = dist( location.x, location.y, width/2, height/2 );
      if (fuite > 400) {
        //reset noise values to respawn it in the screen
        xoff[i] = 0;
        yoff[i] = 0;
        particules.remove(i); // pendez-le ! sus au traitre !
        float angle = random(TWO_PI);
        float r = random(140, 200);
        float x = width/2 + r * cos(angle);
        float y = height/2 + r * sin(angle);
        particules.add(new Particle(x, y, 255)); // oh ! une nouvelle tete dans la population !

        applyForces();
      }
    }
  }


  /////////////////////////// DISCRIMINATION DES FAIBLES /////////////////////////////////////////

  void killWeak(int _j) {
    if (life < 6  && particules.size() > 3 ) particules.remove(_j) ;
    //redonner de la vie aux trois restants trop faibles :
    if ( particules.size() == 3) {
      for ( int i = 0; i < particules.size(); i++) { //verifier la vie / transparence de chacun des trois derniers, et la réaugmenter progressivment si trop faible
        Particle part = particules.get(i);
        if ( part.life < 150) {
          life = lerp(life, 255, 0.8);
        }
      }
    }
  }

  /////////////////////////////// TOILE D ARAIGNEE //////////////////////////

  void toileAraignee(float _x, float _y, float _maxLines, float transparence) {
    //virer les anciennes valeurs
    if (toiles.size() > 1000) toiles.remove(0);

    if (toiles.size() >= 1000) {
      // println(_maxLines);
      for (int i = 1; i < _maxLines; i += 25) {
        //println("toilessize ok");
        Toile t = toiles.get(i);
        //Distance 
        float d = dist(_x, _y, t.posX, t.posY);
        //Probabilité de rencontre
        float p = random(10);
        if (d <= 40 ) {
          //  println("on peut dessiner");
          pushStyle();
          strokeWeight(random(0.5, 1.2));
          stroke(255, transparence);
          line(_x, _y, t.posX, t.posY);
          popStyle();
        }
      }
    }
  }


  //////////////////////////////// LIFE AGENTS //////////////////////////////////////////////////////////////

  float life_agents() {
    //hunger                      //transparence max value
    if (frameCount % 5 == 0 && life > 5 && particules.size() > 3)   life -= 0.4; //à intervalles réguliers, si la vie n'est pas déjà à 5 (suppression), et si il y a plus que les 3 agents de base (qui attirent le visiteur)
    return life;
  }


  /////////////////////////////////////// LA FAIM ///////////////////////////////////////////
  // tous les agents ne se jetteront pas sur la cible : seulement ceux qui ont faim ira se ressourcer ! On liste donc la description des changements d'état de faim
  boolean faim() {
    //convertir en valeur déca pour poser les seuils
    float seuilLife = map ( life, 0, 255, 0, 1);
    if (seuilLife < 0.3 && openDoor == true ) _faim = true ; //si sa jauge de vie faible, et qu'un objet nourriture est apparu, alors le monstre a faim
    if (seuilLife > 0.8) {
      degagedela(location.x, location.y); //si il depasse les 0,8 , alors il n'a plus faim et repart (la fonction degage force les monstres a ressortir)
      _faim = false ;
    }
    if (openDoor == false) {
      degagedela(location.x, location.y);
      _faim = false ; //pas forcément exact, mais plus simple et ne change rien à la situation : il se fait ejecter, et a la prochaine iteration, si une cible a pop, il passera en mode faim et se jettera dessus
    }
    return _faim;
  }  


  ////////////////////////// MONSTRES QUI SE DIRIGENT VERS LEUR REPAS //////////////////////////
  void OnALaDalle(float _x, float _y) {
    if (openDoor == true) {
      numDist = 7000;
      float cibleProche = width;
      float xproche = width / 2;
      float yproche = height / 2;
      for (int i = 0; i < hamburger.size(); i ++) {
        Hamburger sandwich = hamburger.get(i) ;
        float x = sandwich.posX;
        float y = sandwich.posY;
        float cible = dist(x, y, _x, _y);

        if (cible < cibleProche) {  //déterminer la cible la plus proche 
          cibleProche = cible ;
          xproche = x;
          yproche = y;
        }
      }

      target = new PVector(xproche, yproche); //vecteur determinant la pos de la cible la plus proche
      xT = target.x;
      yT = target.y;
    }
  }
  /////////////////// UPDATE ///////////////////////////////////////////////////////////
  void update() {  
    numDist = 4000;
    for (int i =0; i < particules.size(); i ++) {
      xoff[i] += random(0.18);
      yoff[i] += random(0.18);
      //float bou = map (noise(xoff[i],i*5,50), 0, 1, -5, 5);
      //float lou =  map (noise(yoff[i],i*23,15), 0, 1, -5, 5);
      // println(bou,"  ",lou);
      // xT = location.x + (bou * 2) ;
      // yT = location.y + (lou * 2);
      xT = noise (xoff[i]) * width ;
      yT = noise (yoff[i]) * height ;
    }

    OnALaDalle(location.x, location.y); // agents qui se jettent sur la bouffe : mise a jour des targets
    applyForces(); // on applique les forces pour calculer la vitesse

    //vérification que l'on est pas hors champ ou dans la zone 
    if (openDoor == false) stayHereBro();

    location.add(vitesse); // vecteur vitesse ajouté à la position pour avoir la nouvelle position

    if (openDoor == true) {    //comportement grésillant lorsque les agents foncent vers la cible
      int posneg = (int(random(0, 2)) < 1) ? 1: -1; // on récupère donc les valeurs de position pour les "secouer" u peu sur le chemin
      location.x = location.x + (posneg * random(3));
      location.y = location.y + (posneg * random(3));
    }

    acceleration.mult(0); // clear l'acceleration

    //enregistrer les anciennes positions
    Toile oldPos = new Toile(location.x, location.y);
    toiles.add(oldPos);

    //mettre à jour sa jauge de vie & faim
    life_agents();
    faim();

    //tuons les si ils insistent !ç 
    killCowards();
  }

  //////////////////////////// SE NOURRIR ////////////////////////////
  void nourrir(float _x, float _y) {
    for (int i = 0; i < hamburger.size(); i ++) {
      Hamburger sandwich = hamburger.get(i) ;
      float x = sandwich.posX;
      float y = sandwich.posY;
      float nrj = sandwich.kcal;
      float cible = dist(x, y, _x, _y);

      if ( cible < 10) {
        hamburger.remove(i);//cible mangée
        if (life + nrj <= 255) life += nrj; // regagner de la vie en absorbant l'energie de la cible sans dépasser la limite 255
      }
    }
  }

  /////////////////////////////// DISPLAY ////////////////////////////////
  PVector display(int _index) {
    pushStyle();
    fill(255, life);
    noStroke();
    ellipse(location.x, location.y, 3, 3);
    popStyle();

    toileAraignee(location.x, location.y, maxLines, life);


    killWeak(_index);
    nourrir(location.x, location.y);

    return location;
  }
}
