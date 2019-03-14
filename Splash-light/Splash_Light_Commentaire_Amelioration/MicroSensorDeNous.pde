class MicroSensorDeNous {
  Serial port;
  int analog0; // bouton
  int analog1; 
  int analog2; // luminosite
  int xaccel;
  int yaccel;


  MicroSensorDeNous(Serial port) {
    this.port = port;
    this.port.bufferUntil('\n');
  }

  int getAnalog0() {
    return analog0;
  }
  int getAnalog1() {
    return analog1;
  }
  int getAnalog2() {
    return analog2;
  }

  int getXAccel() {
    return xaccel;
  }

  int getYAccel() {
    return yaccel;
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
             // println(json);
             
              analog0 = json.getInt("analog0");
              analog1 = json.getInt("analog1");
              analog2 = json.getInt("analog2");
              xaccel = json.getInt("xaccel");
              yaccel = json.getInt("yaccel");
              //println(buttonA);
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
