class MicroSensor {
  Serial port;
  int buttonA;
  int buttonB;
  int analog0;
  int analog1;
  int analog2;
  int xmag;
  int ymag;
  int zmag;
  int xaccel;
  int yaccel;
  int zaccel;

  MicroSensor(Serial port) {
    this.port = port;
    this.port.bufferUntil('\n');
  }

  int getButtonA() {
    return buttonA;
  }
  int getButtonB() {
    return buttonB;
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

  int getXMag() {
    return xmag;
  }

  int getYMag() {
    return ymag;
  }
  int getZMag() {
    return ymag;
  }

  int getXAccel() {
    return xaccel;
  }

  int getYAccel() {
    return yaccel;
  }

  int getZAccel() {
    return zaccel;
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
              buttonA = json.getInt("buttonA");
              buttonB = json.getInt("buttonB");
              analog0 = json.getInt("analog0");
              analog1 = json.getInt("analog1");
              analog2 = json.getInt("analog2");
              xmag = json.getInt("xmag");
              ymag = json.getInt("ymag");
              zmag = json.getInt("zmag");
              xaccel = json.getInt("xaccel");
              yaccel = json.getInt("yaccel");
              zaccel = json.getInt("zaccel");
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
