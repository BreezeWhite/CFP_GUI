final int WIDTH = 1200, HEIGHT = 400;
final float SEC_PER_SAMPLE = 0.01;
final int KEY_NUM = 88;
final float MAX_STRENGTH = 1;

final int w_size_x = 22 ;
final float w_size_y=w_size_x*4.75;
final float b_size_x=w_size_x*0.6, b_size_y=b_size_x*4.17;
final float init_height = HEIGHT/2-0.3*w_size_y, init_width = WIDTH/2-24.5*w_size_x;


void settings() {
  size(WIDTH, HEIGHT+201);
}

Effects e;
MusicInfo2 minfo;

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.analysis.*;

AudioPlayer music;
FFT fft;
Music visual_m;

void setup() {
  rectMode(CENTER);
  
  String[] music_path = "song.wav";
  String[] pred_path = "prediction_of_song.txt";
  
  Minim minim = new Minim(this);
  music = minim.loadFile(music_path, 1024);
  fft = new FFT(music.bufferSize(), music.sampleRate());
  minfo = new MusicInfo2(pred_path);
 
  e = new Effects();
  visual_m = new Music();
  
  music.play(0*1000);
  music.mute();
}


void draw() {
  background(255);
  
  float cur_time = music.position();
  cur_time = round(cur_time/10); 
  cur_time /= 100;
  updateStrength(cur_time);
  
  visual_m.drawLineSpectrum();
  visual_m.drawPosition();
  
  e.render(cur_time, minfo); // All concept about time in this program uses 'second' as unit.
  
  if(music.position() >= music.length()-1){
    e.setEND();
    if(e.DONE){
      println("End");
      noLoop();
    }
  }
}

void updateStrength(float cur_time){
  float[] amp = visual_m.getAmplitude();
  assert(amp.length == KEY_NUM);
  
  FloatList stren = new FloatList(KEY_NUM);
  for(float a: amp) stren.append(a*5);
  minfo.setStrength(cur_time, stren);
}

void mousePressed() {
  if(mouseY > height-visual_m.line_height){
    float x = constrain(mouseX, 5, width-5);
    int pos = round(map(x, 5, width-5, 0, music.length()));
    music.cue(pos);
    return;
  }
  
  float stren = random(MAX_STRENGTH);
  int key_ = pos2key(mouseX);
  e.add_elem(stren, key_);
}
void mouseDragged() {
  float stren = random(0.6, MAX_STRENGTH);
  int key_ = pos2key(mouseX);

  e.add_elem(stren, key_);
}

int a = 0;
void keyPressed() {
  if (key == ' ') {
    if(music.isPlaying())
      music.pause();
    else 
      music.play();
  }
}
