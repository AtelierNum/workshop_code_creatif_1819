
class MicroSensor {
  Serial port;

  int analog0;
  int analog1;
  int ymag;
  int xmag;
  int zmag;


  MicroSensor(Serial port) {
    this.port = port;
    this.port.bufferUntil('\n');
  }


  int getAnalog0() { 
    return analog0;
  }
 
 int getYMag() {
    return ymag;
  }
  
    int getXMag() {
    return xmag;
  }
  
  int getZMag() {
    return zmag;
  }

 int getAnalog1() {
    return analog1;
  }
  
  void update() {
    try {
      while (this.port.available() > 0) {
        String inBuffer = this.port.readStringUntil('\n');
        if (inBuffer != null) {
          if (inBuffer.substring(0, 1).equals("{")) {
            JSONObject json = parseJSONObject(inBuffer);
            if (json == null) {
              //println("JSONObject could not be parsed");
            } else {
             
             analog0 = json.getInt("analog0"); //bouton vert --> carres
             analog1 = json.getInt("analog1"); //bouton blanc --> ellipses
             ymag = json.getInt("ymag"); //inclinaison avant-arriere carte --> couleur particules
             xmag = json.getInt("xmag"); //inclinaison gauche-droite carte --> couleur fond
             zmag = json.getInt("zmag"); //hauteur carte 
            }
          } else {
          }
        }
      }
    } 
    catch (Exception e) {
    }
  }
}