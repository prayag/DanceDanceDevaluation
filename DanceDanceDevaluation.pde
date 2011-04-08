import ddf.minim.*;
import processing.serial.*;

int STOPPED = 1;
int TEMPO1 = 2;
int TEMPO2 = 3;
int TEMPO3 = 4;

int currentTempo = STOPPED;

int lineFeed = 10;


Serial port;
String buf="";
int count = 0;
AudioPlayer playerBackground;
AudioPlayer player1;
AudioPlayer player2;
AudioPlayer player3;
Minim minim;
int TRIGGER = 50;
int[] pressureValues = new int[4];
int[] oldPressureValues = new int[4];

void setup()
{
 size(512, 200, P2D);
 
 minim = new Minim(this);

 // load a file, give the AudioPlayer buffers that are 2048 samples long
 playerBackground = minim.loadFile("Background.wav", 2048);
 player1= minim.loadFile("1.wav",2048);
 player2= minim.loadFile("2.wav",2048);
 //player3 = minim.loadFile("3.wav",2048);
 
 port = new Serial(this, Serial.list()[0], 9600);
 port.bufferUntil(lineFeed);
 
}

void draw()
{
 background(0);
 stroke(255);
 // draw the waveforms
 // the values returned by left.get() and right.get() will be between -1 and 1,
 // so we need to scale them up to see the waveform
 // note that if the file is MONO, left.get() and right.get() will
 //return the same value
 for(int i = 0; i < playerBackground.left.size()-1; i++)
 {
   line(i, 50 + playerBackground.left.get(i)*50, i+1, 50 + playerBackground.left.get(i+1)*50);
   line(i, 150 + playerBackground.right.get(i)*50, i+1, 150 + playerBackground.right.get(i+1)*50);
 }
 
}


void serialEvent(Serial p) {
 println("Serial Event");
 buf= port.readString();
 println("Read:"+buf);
 pressureValues = parse(buf);
 playMusic();
 for (int i = 0; i < pressureValues.length; i++)
   oldPressureValues[i] = pressureValues[i];
 //println(pressureValues);

}

void playMusic(){
  if (oldPressureValues[0] <=50 && pressureValues[0] > 50) {
    playOrStop();
  }
  if (oldPressureValues[1] <=50 && pressureValues[1] > 50) {
    player1= minim.loadFile("1.wav",2048);
    player1.play();
  }
  if (oldPressureValues[2] <=50 && pressureValues[2] > 50) {
    player2= minim.loadFile("2.wav",2048);
    player2.play();
  }
  //if (oldPressureValues[3] <=50 && pressureValues[3] > 50)
  //  player3.play();
}

void playOrStop(){

  if (currentTempo == STOPPED) {
    playerBackground= minim.loadFile("Background.wav",2048);
    playerBackground.play();
    playerBackground.loop();
    currentTempo = TEMPO1;
  }
  else if (currentTempo == TEMPO1) {
    playerBackground.pause();
    playerBackground= minim.loadFile("Background.wav",2048);
    playerBackground.play();
    currentTempo = TEMPO2;
  }
  else if (currentTempo == TEMPO2) {
    playerBackground.pause();
    playerBackground= minim.loadFile("Background.wav",2048);
    playerBackground.play();
    currentTempo = TEMPO2;
  }
  else if(currentTempo == TEMPO3) {
    playerBackground= minim.loadFile("Background.wav",2048);
    playerBackground.pause();
    currentTempo = STOPPED;
  }
}

void stop()
{
   // always close Minim audio classes when you are done with them
   playerBackground.close();
   player1.close();
   player2.close();
   player3.close();
  // player4.close();
   minim.stop();
   super.stop();
}

int[] parse(String string)
{
  int[] intValues = new int[4];
  String[] strValues = new String[4];
  
  strValues = string.split(",");
  println(strValues);
  for(int i=0;i<strValues.length-1;i++)
  {
      intValues[i] = Integer.parseInt(strValues[i]);  
  }
  
  return intValues;
}


