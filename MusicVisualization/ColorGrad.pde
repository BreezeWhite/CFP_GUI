
class Color_Tachi{
  private ColorGrad[] colors;
  private int MAX_NColors;
  
  public Color_Tachi(int num_colors){
    MAX_NColors = num_colors;
    
    colors = new ColorGrad[MAX_NColors];
    for(int i=0; i<MAX_NColors; i+=1){
      colors[i] = new ColorGrad(0, i);
    }
  }
  
  public void update(){
    for(int i=0; i<MAX_NColors; i+=1){
      if(colors[i].END == false){
        colors[i].update();
      }
    }
  }
  
  public void add_colors(float stren, int key_){
    colors[key_].reset(stren);
  }
}



class ColorGrad {
  public boolean END = true;

  private PImage pic;
  private float stren_, ori_stren;
  private int fade_iter;
  private int x_, y_;
  private int key_;

  private float MAX_Stren = MAX_STRENGTH;
  private int iter_ = 10, MAX_Fade_iter = 13;
  private int MIN_Fade_iter = int(MAX_Fade_iter*1);
  private int spread_speed = 125;
  private int MAX_CVal = 150;

  private color Blue = color(#61B1F5);
  private color Orange = color(#E88F68);


  public ColorGrad(float stren, int k) {
    key_ = k;
    
    if(isBlack(k)) init_b();
    else init_w();
    
    stren_ = stren;
    ori_stren = stren;
    fade_iter = int(map(stren, 0, MAX_Stren, MIN_Fade_iter, MAX_Fade_iter));
  }
  
  public void update() {
    if (stren_ < 0.1) {
      END = true;
      return;
    }
    
    setPic();
    set(x_, y_, pic);

    stren_ -= ori_stren/fade_iter;
    iter_ += 1;
  }
  public void reset(float stren){
    stren_ = stren;
    ori_stren = stren;
    iter_ = MAX_Fade_iter;
    fade_iter = int(map(stren, 0, MAX_Stren, MIN_Fade_iter, MAX_Fade_iter));
    if(isBlack(key_)) pic = createImage(int(b_size_x), int(b_size_y), HSB);
    else pic = createImage(int(w_size_x), int(w_size_y), HSB);
    END = false;
  }
  
  
  private void init_b(){
    pic = createImage(int(b_size_x), int(b_size_y), HSB);
    x_ = ceil(key2pos_x(key_)-(b_size_x/2));
    y_ = ceil(key2pos_y(key_)-(b_size_y/2));
  }
  private void init_w(){
    pic = createImage(int(w_size_x), int(w_size_y), HSB);
    x_ = ceil(key2pos_x(key_)-(w_size_x/2));
    y_ = ceil(key2pos_y(key_)-(w_size_y/2));
  }

  private void setPic() {
    colorMode(HSB, MAX_CVal);

    color top = fadeColor(Orange);
    color buttom = fadeColor(Blue);

    colorMode(RGB, MAX_CVal);
    int init_height = floor(pic.height/3);
    int bound_height = iter_*spread_speed;
    if (bound_height > pic.height) bound_height = pic.height;

    int bound_buttom = init_height-int(iter_*spread_speed*0.36);
    if (bound_buttom < 0) bound_buttom = 0;

    
    if(isBlack(key_))
      draw_b(init_height, bound_height, bound_buttom, top, buttom);
    else
      draw_w(init_height, bound_height, bound_buttom, top, buttom);
      
    //add_frame();

    colorMode(RGB, 255);
  }
  
  private void draw_b(int init_height, int bound_height, int bound_buttom, color top, color buttom){
    for (int j=init_height; j<=bound_height; j+=1) {
      float inter = map(j, init_height, pic.height+1, 1, 0);
      color c = lerpColor(top, buttom, inter);
      for (int i=0; i<pic.width; i+=1)
        pic.set(i, pic.height-j, c);
    }
    for (int j=init_height; j>=bound_buttom; j-=1) {
      float inter = map(j, 0, init_height, 1, 0);
      color c = lerpColor(buttom, top, inter);
      for (int i=0; i<pic.width; i+=1)
        pic.set(i, pic.height-j, c);
    }
  }
  
  
  private void draw_w(int init_height, int bound_height, int bound_buttom, color top, color buttom){
    int key_type = type();
    
    for (int j=init_height; j<=bound_height; j+=1){
      float inter = map(j, init_height, pic.height+1, 1, 0);
      color c = lerpColor(top, buttom, inter);
      
      int left_bound=2, right_bound=2;
      switch(key_type){
        case 0:
          left_bound = int(b_size_x/2);
          right_bound = pic.width;
          break;
        case 1:
          left_bound = 0;
          right_bound = pic.width-int(b_size_x/2);
          break;
        case 2:
          left_bound = int(b_size_x/2);
          right_bound = pic.width-int(b_size_x/2);
          break;
      }
      if(key_ == 0) left_bound = 0;
      else if(key_ == 87) right_bound = pic.width;
      
      if(j < b_size_y-7){
        left_bound = 0;
        right_bound = pic.width;
      }
      
      for (int i=left_bound; i<right_bound; i+=1) {
        pic.set(i, pic.height-j, c);
      }
    }
    
    for(int i=0; i<pic.width; i+=1){
      for (int j=init_height; j>=bound_buttom; j-=1) {
        float inter = map(j, 0, init_height, 1, 0);
        color c = lerpColor(buttom, top, inter);
        pic.set(i, pic.height-j, c);
      }
    }
  }
  
  private int type(){
    final int[] left_b = {4, 11, 12/*no use*/};
    final int[] right_b = {0, 5, 12/*no use*/};
    final int[] both = {2, 7, 9};
    int offset = key_<3 ? key_+9: (key_-3)%12;
    
    int type = -1;
    for(int i=0; i<3; i+=1){
      if(offset == left_b[i]) type = 0;
      else if(offset == right_b[i]) type = 1;
      else if(offset == both[i]) type = 2;
    }
    
    return type;
  }
  
  private void add_frame(){
    color black = color(0);
    for(int i=0; i<pic.width; i+=1)
      pic.set(i, 0, black);
    for(int i=0; i<pic.width; i+=1)
      pic.set(i, pic.height, black);
    for(int i=0; i<pic.height; i+=1)
      pic.set(0, i, black);
    for(int i=0; i<pic.height; i+=1)
      pic.set(pic.width, i, black);
  }
  
  private color fadeColor(color c) {
    float h = hue(c);
    float b = brightness(c);
    float s = map(stren_, 0, MAX_Stren, MAX_CVal*0.6, MAX_CVal);

    return color(h, s, b);
  }
}