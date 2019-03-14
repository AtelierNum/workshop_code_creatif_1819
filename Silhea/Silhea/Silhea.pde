//importation differentes bibliothèques, usage principal de "blobDetection".
import processing.serial.*;
import processing.video.*;
import blobDetection.*;
import processing.sound.*;
//
AudioIn input;
Amplitude loudness;
PicoSensors pico;
Serial port;
Capture cam;
BlobDetection theBlobDetection;

int seuil_sonore = 70;
long dernier_clap = 0;
int max_sonore = 0;
color currentcolor = color (246, 85, 174);
PImage flou;
boolean newFrame=false;
int arriere = 1;


boolean buttonState = false;
boolean pButtonState = false;

boolean prendre = false;
boolean photo = false;

SoundFile rose; // son pour l'animation avec les mains 
SoundFile jaune;
SoundFile cyan;
SoundFile violet; 

ArrayList<Boule> boules;
int maximum = 100;
int modificateur_quantiter;

int mode = 0; // mode : changement entre écran d'accueil et écran principal

int compteur_photo = 0;

PImage coucou;

boolean DEBUG = true; // passer à false pour ne plsu afficher les infos de dev

// ==================================================
// setup()
// ==================================================
void setup()
{
  
  coucou = loadImage("deb2.jpg");
  arriere = 1;
  frameRate(60);
  // Size of applet
  size(1184, 656, P2D);
  //colorMode(HSB);
  // Capture
  // cam = new Capture(this, 1280, 720, 15);
  // Comment the following line if you use Processing 1.5
  // cam.start();
  input = new AudioIn(this, 0);
  input.start();
  loudness = new Amplitude(this);
  loudness.input(input);
  //println(Serial.list() );
  String picoPort = Serial.list()[0];
  port = new Serial(this, picoPort, 38400); 
  pico = new PicoSensors(port);
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 1184, 656);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[71]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);

    // Débuter la capture de webcam
    cam.start();
  }

  // BlobDetection
  // image traité pour la détection des Blobs
  flou = new PImage(80, 60); 
  theBlobDetection = new BlobDetection(flou.width, flou.height);
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(0.2f); // will detect bright areas whose luminosity > 0.2f;

  //association des couleurs aux ambiances sonores
  rose = new SoundFile (this, "soncyan.wav");
  jaune = new SoundFile (this, "sonjaune.wav");
  cyan = new SoundFile (this, "sonrose.wav");
  violet = new SoundFile (this, "sonviolet.wav");
  //utilisation de la classe boule utilisée pour l'apparition de cercle en fonction de la position du potentiometre.
  boules = new ArrayList<Boule>();
  for (int maximum =0; maximum < boules.size(); maximum++)
  {

    boules.add(new Boule());
  }
}
// ==================================================
// draw()
// ==================================================
void draw()
{
  background(0);

  if (mode == 0) { // Ecran accueil
    imageMode(CENTER);
    image(coucou,width/2,height/2,800,1000);

    if (keyPressed)mode = 1;
  }

  if (mode == 1) { // Mode principal
    pico.update();

    float volume = pico.getSound();
    println(volume);

    /*changement couleur arrière plan*/


    if (arriere >= 1)
    {
      background(0, 0, 0);
    }

    if (arriere >= 2)
    {
      background(255, 255, 255);
    }

    if (arriere > 2)
    {
      arriere = 1;
    }

    /*changement couleur stroke en fonction action sonore*/

    modificateur_quantiter = int(pico.getSlider() / 50) * 5;

    if (modificateur_quantiter>boules.size())
    {
      int ajout = modificateur_quantiter - boules.size();
      for (int maximum = 0; maximum < ajout; maximum++) 
      {
        boules.add(new Boule());
      }
    }

    if (modificateur_quantiter<boules.size())
    {
      int entro =   boules.size() - modificateur_quantiter;
      for (int maximum = 0; maximum < entro; maximum++)
      {
        boules.remove(0);
      }
    }

    for (int maximum = 0; maximum < boules.size(); maximum++) {
      Boule b = boules.get(maximum);
      boules.get(maximum). afficher();
    }

// fonction permettant le changement d'ambiance sonore/visuelle via action sonore (clap des mains)
    int size = int(map(volume, 0, 1000, 1, 950));
    if (size > max_sonore) max_sonore = size;

    if ((size >= seuil_sonore) && ( (millis() - dernier_clap) > 2000)) {

      dernier_clap = millis();

      if ((size >= seuil_sonore) && (size < 150)) {
        currentcolor = color(246, 85, 174);
        if (rose.isPlaying() == false) {
          rose.loop();
          jaune.stop();
          cyan.stop();
          violet.stop();
        }
      } 
      if (( size >= 150) && (size < 300)) {
        currentcolor = color (253, 222, 0);
        if (jaune.isPlaying() == false) {
          jaune.loop();
          rose.stop();
          cyan.stop();
          violet.stop();
        }
      } 
      if (( size >= 300) && (size < 500)) {
        currentcolor = color(0, 253, 220);
        if (cyan.isPlaying() == false) {
          cyan.loop();
          jaune.stop();
          rose.stop();
          violet.stop();
        }
      }
      if (size >= 500) {
        currentcolor = color(167, 66, 226);
        if (violet.isPlaying() == false) {
          violet.loop();
          jaune.stop();
          cyan.stop();
          rose.stop();
        }
      }
    }
    if (cam.available()) {
      cam.read();
      //  image(cam, 0, 0, width, height);
      flou.copy(cam, 0, 0, cam.width, cam.height, 
        0, 0, flou.width, flou.height);
      //fastblur(flou, int(pico.getA()/200)); // appliquer un flou avant de chercher les blobs
      theBlobDetection.computeBlobs(flou.pixels);
    }

    // image(img, 0, 0, width, height); // décommenter pour voir l'image traitée


    float largeur = (((float)pico.getB()/20 + 1));
    float hauteur = (((float)pico.getB()/20 + 1));  
    //int largeur = getB() / 50 + 1;
    //int hauteur = mouseY / 50 + 1;
    //int largeur = mouseX  + 1;
    //int hauteur = mouseY  + 1;

    //pushMatrix();
    /*---------------------------------------------*/
    /* fonction permettant la superposition de l'image cam */
    /*
  float multx = (float)width / (float)flou.width;
     float multy = (float)height / (float)flou.height;
     for (int y = 0; y < height; y += hauteur) {
     for (int x = 0; x < width; x += largeur) {
     
     // Coordonnées du pixel à tester
     int px = int(x / multx);
     int py = int(y / multy);
     rectMode(CENTER);
     color c = flou.get(px, py);
     if (red(c) == 0) c = (int)random(50);
     float diametre =  (255 - brightness(c) / 1) ;
     float transparence = map(dist(x,y,mouseX, mouseY), 0,1000,0,10);
     fill(red(c),green(c),blue(c),9);
     fill(c);
     noStroke();
     diametre = 50 - (dist(mouseX, mouseY, x,y) );
     rect(mouseX, mouseY, diametre, diametre);
     rect(x, y, largeur, hauteur);
     //rect(x,y,cote,cote);
     }
     }
     */

    // Pixellisation du fond

    //int l = int(map(mouseX, 0, width, 100, 300));
    //int h = int(map(mouseY, 0, height, 100, 300));

    //rectMode(CORNER);
    //noStroke();
    //for (int y = 0; y < height; y += h) {
    //  for (int x = 0; x < width; x += l) {
    //    color c = get(x, y);
    //    fill(c);
    //    rect(x, y, l, h);
    //  }
    //}

    // Dessin des contours

   
    //popMatrix();

    //println(buttonState);

    if (pico.getC() == 1023) {
      if (buttonState == true && pButtonState == buttonState) {
        buttonState = false;
      } else if (buttonState == false && pButtonState == buttonState) {
        buttonState = true;
      }
    } else {
      if (pButtonState != buttonState) arriere++;
      pButtonState = buttonState;
    }

   // println(prendre);
    /*
    if (pico.getD() == 1023) {
     if (prendre == true && photo == prendre) {
     prendre = false;
     } else if (prendre == false && photo == prendre) {
     prendre = true;
     }
     } else {
     if (photo != prendre) {
     compteur_photo ++;
     String nb = nf(compteur_photo, 5);
     saveFrame("fond_" + nb + ".png");
     photo = prendre;
     }
     }*/
drawBlobsAndEdges(true, true);
    // Prise de photos pour l'animation
    if (pico.getD() == 1023) {
      compteur_photo ++;
      String nb = nf(compteur_photo, 5);
      saveFrame("fond_" + nb + ".png");
    }
    // drawBlobsAndEdges(true, true);

    //if (DEBUG) {
    //  textSize(12);
    //  fill(255);
    //  text("pico.getSlider() : " + pico.getSlider(), 20, 40);
    //  text("modificateur_quantiter : " + modificateur_quantiter, 20, 60);
    //  text("fps : " + frameRate, 20, 80);
    //}
  }
}

// ==================================================
// drawBlobsAndEdges()
// ==================================================
void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
{
  noFill();
  Blob b;
  EdgeVertex eA, eB;
  for (int n=0; n<theBlobDetection.getBlobNb(); n++)
  {
    b=theBlobDetection.getBlob(n);
    if (b!=null)
    {
      // Edges
      if (drawEdges)
      { 

        float modificateur_epaisseur = (((float)pico.getA()/200));    //modifier épaisseur du contour avec potentiomètre.
        //modificateur_epaisseur = 3; -------------------------------- à commenter pour pouvoir modifier épaisseur avec le potentiometre.
        strokeWeight(modificateur_epaisseur); 
        // println(pico.getSlider());    
        for (float i = 0; i < 3; i++) {
          pushMatrix();
          scale(1 + (i / 20), 1);
          // strokeWeight(2*i); lorsque activé plus que 2 contours
          stroke(currentcolor);
          for (int m=0; m<b.getEdgeNb(); m++)
          {
            eA = b.getEdgeVertexA(m);
            eB = b.getEdgeVertexB(m);
            if (eA !=null && eB !=null)
              line(
                eA.x*width, eA.y*height, 
                eB.x*width, eB.y*height
                );
          }
          popMatrix();
        }
      }
      /* Partie permettant appararition de rectangle rouge permettant de repèrer zone*/
      // Blobs
      //if (drawBlobs)
      {
        //strokeWeight(1);
        //stroke(255, 0, 0);
        //rect(
        //b.xMin*width, b.yMin*height, 
        //b.w*width, b.h*height
        //);
      }
    }
  }
}

// ==================================================
// Super Fast Blur v1.1
// by Mario Klingemann 
// <http://incubator.quasimondo.com>
// ==================================================
void fastblur(PImage img, int radius)
{
  if (radius<1) {
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
  int vmin[] = new int[max(w, h)];
  int vmax[] = new int[max(w, h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0; i<256*div; i++) {
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0; y<h; y++) {
    rsum=gsum=bsum=0;
    for (i=-radius; i<=radius; i++) {
      p=pix[yi+min(wm, max(i, 0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0; x<w; x++) {

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if (y==0) {
        vmin[x]=min(x+radius+1, wm);
        vmax[x]=max(x-radius, 0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0; x<w; x++) {
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for (i=-radius; i<=radius; i++) {
      yi=max(0, yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0; y<h; y++) {
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if (x==0) {
        vmin[y]=min(y+radius+1, hm)*w;
        vmax[y]=max(y-radius, 0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }
}

/*déclencher capture d'écran avec pression bouton + changement couleur background*/
void keyPressed()
{  

  if (key == 'a')
  {
    arriere++;
  } 

  if (key == 'e') saveFrame("fond.png");
}
