
class Embolus_Tachi{
  private int MAX_NEmb;
  private Embolus[] embs;
  private int r_size = 9;
  
  public Embolus_Tachi(int num_emb){
    MAX_NEmb = num_emb;
    
    embs = new Embolus[MAX_NEmb];
    for(int i=0; i<MAX_NEmb; i+=1){
      if(i < 0 || i > 87) return;
      
      int x, y;
      y = int(init_height - w_size_y*0.45 + r_size);
      
      if(i < 3){
        x = int(init_width + (i-2)*w_size_x/2);
      }
      else{
        int octave = int((i-3)/12) + 1;
        int pos = (octave-1) * (12 + 2);
        int offset = (i-3) % 12 + 1;
        offset = offset>5 ? offset+1 : offset;
      
        x = int(init_width + (pos+offset+1)*w_size_x/2);
      }
      
      embs[i] = new Embolus(0, x, y);
    }
  }
  
  public void update(){
    for(int i=0; i<embs.length; i+=1){
      if(embs[i].END == false){
        embs[i].update();
      }
    }
  }
  
  public void add_embs(float stren, int keys){
    embs[keys].reset(stren);
  }
}


class Embolus {
  public boolean END = true;

  private int x_, y_;
  private float fade_iter;

  private int iter_ = 0;
  private int r_size = 9;
  private int height_ = ceil(r_size*1.5);
  private float MAX_Stren = MAX_STRENGTH;
  private int MAX_Fade_iter = 2;
  private float MIN_Fade_iter = MAX_Fade_iter * 0.3;
  private boolean protru = true;
  private int protru_speed = 2;
  private int current_height = 0;
  private color emb_c = color(#DB8D16);

  public Embolus(float stren, int x, int y) {
    fade_iter = map(stren, 0, MAX_Stren, MIN_Fade_iter, MAX_Fade_iter);
    x_ = x;
    y_ = y-4;
  }

  public void update() {
    if (END) return;

    setPos();
    embolus(x_, y_+current_height);
  }
  public void reset(float s){
    fade_iter = map(s, 0, MAX_Stren, MIN_Fade_iter, MAX_Fade_iter);
    protru = true;
    current_height = 0;
    END = false;
  }

  private void setPos() {
    if (protru) {
      if (-current_height > height_) {
        protru = false;
        current_height = -height_;
      } else current_height -= protru_speed;

      return;
    }

    iter_ += 1;
    if (current_height >= 0) {
      current_height = 0;
      END = true;
      return;
    }
    if (fade_iter >= 1) {
      if(iter_ % int(fade_iter) == 0){
        current_height += 1;
        iter_ = 0;
      }
    } 
    else {
      int step = ceil(map(fade_iter, 0, 1, 1, 3));
      current_height += step;
      iter_ = 0;
    }
  }

  private void embolus(int x, int y) {
    fill(emb_c);
    noStroke();
    rect(x, y, r_size, r_size);
    ellipse(x, y-r_size/2-1, r_size, r_size);
  }
}