
class Ripple_Tachi{
  private Ripple[] ripples;
  private int MAX_NUM;
  private int current = 0;
  
  public Ripple_Tachi(int num_ripple){
    MAX_NUM = num_ripple;
    
    ripples = new Ripple[num_ripple];
    for(int i=0; i<MAX_NUM; i+=1){
      ripples[i] = new Ripple();
    }
  }
  
  public void update(){
    for(int i=0; i<MAX_NUM; i+=1){
      if(ripples[i].END == false){
        ripples[i].update();
      }
    }
  }
  
  public void add_ripple(float stren, int key_){
    int x = key2pos_x(key_);
    int y = key2pos_y(key_);
    
    ripples[current] = new Ripple(stren, x, y);
    current = (current+1) % MAX_NUM;
  }
}


class Ripple{
  private float lowest_energy = MAX_STRENGTH * 0.6;
  private float alpha = 0.4;
  private int MAX_Fade_iter = 50;
  private int MIN_Fade_iter = int(MAX_Fade_iter*0.6);
  private float MAX_Stren = MAX_STRENGTH;
  private float spread_speed = 9;
  public boolean END = true;
  
  private int fade_out_iter;
  private float stren_, ori_stren;
  private float[] cir_size;
  private int x_, y_;
  private float[] release_interval;
  private int num_circles = 1;
  
  public Ripple(){
    stren_ = 0.01;
    ori_stren = 0.01;
    x_ = 0;
    y_ = 0;
  }
  
  public Ripple(float strength, int x, int y){
    END = false;
    fade_out_iter = int(map(strength, 0, MAX_Stren, MIN_Fade_iter, MAX_Fade_iter));
    stren_ = strength;
    ori_stren = strength;
    x_ = x;
    y_ = y;
    
    while(strength > lowest_energy){
      num_circles += 1;
      strength = strength * alpha;
    }
    
    float MAX_interval = 20;
    float decrease_freq = 10;
    release_interval = new float[num_circles-1];
    for(int i=0; i<num_circles-1; i+=1){
      release_interval[i] = MAX_interval;
      MAX_interval -= alpha*decrease_freq;
      decrease_freq *= alpha;
    }
    
    cir_size = new float[num_circles];
    for(int i=0; i<num_circles; i+=1) cir_size[i] = 0;
    cir_size[0] = spread_speed;
  }
  
  
  public void update(){
    if(stren_ <= 0.01){
      END = true;
      return;
    }
    update_var();
    
    noFill();
    float MAX_Col = map(ori_stren, 0, MAX_Stren, 255, 0);
    stroke(map(stren_, 0, ori_stren, 255, MAX_Col));
    strokeWeight(2);
    for(int i=0; i<num_circles; i+=1){
      if(cir_size[i] <= 0.1) break;
      ellipse(x_, y_, cir_size[i], cir_size[i]);
    }
  }
  private void update_var(){
    int ith = 0;
    for(; ith<num_circles && cir_size[ith]>0.1; ith+=1){
      cir_size[ith] += spread_speed;
    }
    stren_ -= ori_stren/fade_out_iter;
    if(ith == 0 || ith == num_circles) return;
    
    int interval = int(cir_size[ith-1]/spread_speed);
    if(interval >= release_interval[ith-1]){
      cir_size[ith] += spread_speed;
    }
  }
}