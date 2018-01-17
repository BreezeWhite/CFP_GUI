

class Effects{
  private Ripple_Tachi ripples;
  private Color_Tachi colors;
  private Embolus_Tachi embs;
  private Tatoo tatoo;
  private MusicInfo2 minfo;
  
  private boolean END = false;
  
  final int MAX_ELEM_NUM = 80;
  public boolean DONE = true;
  
  public Effects(){
    ripples = new Ripple_Tachi(MAX_ELEM_NUM);
    colors = new Color_Tachi(KEY_NUM);
    embs = new Embolus_Tachi(KEY_NUM);
    tatoo = new Tatoo(width/2, height/2);
  }
  public void render(float cur_time, MusicInfo2 m){
    minfo = m;
    update_var(cur_time);
    
    boolean end = true;
    end &= tatoo.update(cur_time, m);
    ripples.update();
    embs.update();
    end &= pianoRoll(END);
    colors.update();
    
    DONE = end;
  }
  public void setEND(){
    END = true;
    tatoo.setEND();
  }
  
  private void update_var(float cur_time){
    minfo.resetTime(cur_time);
    int[] onsets = minfo.getCurOnset(0.05);
    
    FloatList strens = minfo.getStrength(cur_time);
    for(int i=0; i<onsets.length; i+=1){
      int key_num = onsets[i];
      
      add_elem(strens.get(key_num), key_num);
    }
  }
  
  public void add_elem(float stren, int key_){
    stren = constrain(stren, 0.01, MAX_STRENGTH);
    
    ripples.add_ripple(stren, key_);
    colors.add_colors(stren, key_);
    embs.add_embs(stren, key_);
  }
  
  private int cur_alpha = 255;
  private int fade_speed = 8;
  private boolean pianoRoll(boolean fade_out){
    //52 white keys, lowest from A0.
    //Total 88 keys.
    if(cur_alpha < 0) return true;
    
    if(fade_out){
      cur_alpha -= fade_speed;
      pianoRoll(52, cur_alpha);
    }
    else pianoRoll(52, 255);  
    
    return false;
  }
  
  
  private void pianoRoll(int num, int alpha){
    int[] interval = {4, 3}; // Period of printing black keys after N white keys.
    
    num -= 2;
    int period = 0;
    for(int e: interval) period += e;
   
    rectMode(CENTER);
    stroke(0, alpha);
    strokeWeight(1);
    int iter_ = 0;
    for(int i=0; i<=num; i+=1){
      fill(255, alpha);
      rect(init_width+w_size_x*i, init_height, w_size_x, w_size_y);
      
      int remain = i % period;
      for(int j=0; j<iter_; j+=1) remain -= interval[j];
      if(remain % interval[iter_] != 0){
        fill(0, alpha);
        rect(init_width-w_size_x/2+w_size_x*i+0.5, init_height-(w_size_y-b_size_y)/2+0.5, b_size_x, b_size_y);
      }
      else iter_ = (iter_+1) % interval.length;
    }
    
    fill(255, alpha);
    rect(init_width-w_size_x, init_height, w_size_x, w_size_y);
    fill(0, alpha);
    rect(init_width-w_size_x/2+0.5, init_height-(w_size_y-b_size_y)/2+0.5, b_size_x, b_size_y);
  }
}