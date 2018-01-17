
class Music{
  private float[] stable_amp, cur_amp;
  private float[] hz;
  
  public Music(){
    stable_amp = new float[KEY_NUM];
    cur_amp = new float[KEY_NUM];
    
    hz = new float[KEY_NUM+2];
    for(int i=0; i<hz.length; i+=1){
      hz[i] = pow(2, float(i-49)/12) * 440;
    }
  }
  public float[] getAmplitude(){
    fft.forward(music.mix);
    
    final float MAX_AMP = 130;
    for(int i=1; i<=KEY_NUM; i+=1){
      float centerFreq = hz[i];
      float upper_freq = (hz[i+1] - centerFreq)/2 + centerFreq;
      float lower_freq = (centerFreq - hz[i-1])/2 + hz[i-1];
      float avg = fft.calcAvg(lower_freq, upper_freq);
      float inc = 1 + sigmoid(i) * 5;
      cur_amp[i-1] = map(avg*inc, 0, MAX_AMP, 0, 1);
    }
    
    return cur_amp;
  }
  public void drawSpectrum(){
    rectMode(CORNERS);
    float[] amp = getAmplitude();
    for(int i=0; i<amp.length; i+=1){
      float xl = map(i, 0, amp.length, 10, width-10);
      float xr = map(i+1, 0, amp.length, 10, width-10);
      
      rect(xl, height, xr, height - amp[i]*1000);
    }
  }
  
  private float[] getAmp(){
    float[] cur_amp = getAmplitude();
    float por_new = 0.4;
    float por_old = 1-por_new;
    
    for(int i=0; i<KEY_NUM; i+=1){
      stable_amp[i] = stable_amp[i]*por_old + cur_amp[i]*por_new;
    }
    return stable_amp;
  }
  private float sigmoid(int key_){
    float offset = 0.8;
    float t = map(key_, 0, KEY_NUM-1, -1, 1.3);
    return 1/(1+exp(-9*(t-offset)));
  }
  
  public void drawLineSpectrum(){
    float[] amp = getAmp();
    float lx = 0;
    float ly = height;
    
    for(int i=0; i<amp.length; i+=1){
      float x = map(i, 0, amp.length, 10, width-10);
      float y = map(amp[i], 0, 0.8, height, height-200);
      
      stroke(0);
      strokeWeight(1);
      line(lx, ly, x, y);
      stroke(#FF244C);
      strokeWeight(2);
      point(x, y);
      
      lx = x;
      ly = y;
    }
    stroke(0);
    strokeWeight(1);
    line(lx, ly, width, height);
  }
  
  public int line_height = 80;
  public void drawPosition(){
    pushStyle();
    
    float x = map(music.position(), 0, music.length(), 1, width);
    stroke(#FCA1F8);
    strokeWeight(2);
    line(x, height, x, height-line_height);
    
    popStyle();
  }
}