
// adapted from : https://grallator.wordpress.com/2013/10/17/137/
class PicoSensors {

  Serial port;

  int b1, b2;                            // byte pairs from the data packet
  int  i;                               // general loop counter
  int[]  ChanValues={0, 0, 0, 0, 0, 0, 0, 0};  // the 8 channel values 
  int[] ValBuffer=new int[18];          // the 18 byte data packet from the Picoboard
  int  Channel;                         // used to identify the channel the data corresponds to
  int  Val;                              // the value of the channel

  PicoSensors(Serial port) {
    this.port = port;
    // send a request to the board to supply values
    port.write(1);
  }


  void update() {
    // reading from the picoboard requires a bit of care to get a full packet
    // read when at least 18 bytes of data are available
    if (port.available()>=18) {
      // take the first 18 bytes
      // these are 2-byte hi/lo pairs for 8 input channels + firmware version (channel 15)
      for (i=0; i<18; i++) {
        ValBuffer[i]=port.read();
      }

      // find the 10-bit values for channels 0-7
      // channel    Sensor
      //    0        D
      //    1        C
      //    2        B
      //    3        Button
      //    4        A
      //    5        Light
      //    6        Sound
      //    7        Slider

      for (i=0; i<18; i+=2) {
        b1=ValBuffer[i];
        b2=ValBuffer[i+1];
        Channel=(b1&120)>>3;
        Val=((b1&7)<<7)+(b2&127);    //channel value is bits 0-2 of hi byte and bits 0-6 of lo byte
        if (Channel<8)  ChanValues[Channel]=Val; // only store value if channel is in range  0-7
      }

      // sometimes there's extra data if things change fast and the FPS value is high
      // better performance is obtained if you ignore these partials and get a full set,
      // so read anything left in the buffer to flush it.
      while (port.available()>0)
      {
        b1=port.read();
      }
      // buffer now empty - ask for more data
      port.write(1);
    }
  }
  
  int getA(){
    return ChanValues[4];
  }
  
  int getB(){
    return ChanValues[2];
  }
  
  int getC(){
    return ChanValues[1];
  }
  
  int getD(){
    return ChanValues[0];
  }
  
  int getButton(){
    return ChanValues[3];
  }
  
  int getLight(){
    return ChanValues[5];
  }
  
  int getSound(){
    return ChanValues[6];
  }
  
  int getSlider(){
    return ChanValues[7];
  }
}