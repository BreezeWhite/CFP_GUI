
class FullSector extends Sector{
  
  public PGraphics FSector;
  public int num_sectors;
  
  private float[] cos_, sin_;
  
  public FullSector(float radius, float deg, int num_s){
    super(radius, deg);
    
    assert(radius > 0): "Raiuds can't be samller or equals to 0. Current radius: " + radius;
    FSector = createGraphics(int(radius_*2)+3, int(radius_*2)+3);
    initWanHuaTon();
    
    num_sectors = num_s;
    degIncSpeed = radians(3)/TAU*deg;
    
    cos_ = new float[num_s];
    sin_ = new float[num_s];
    for(int i=0; i<num_s; i+=1){
      cos_[i] = cos(deg*i - HALF_PI);
      sin_[i] = sin(deg*i - HALF_PI);
    }
  }
  
  
  @Override
  public void paint(float rot, float x, float y){
    update_var();
    
    imageMode(CENTER);
    pushMatrix();
    translate(x, y);
    rotate(rot);
    image(FSector, 0, 0);
    popMatrix();
  }
  
  private final float DEG = radians(30);
  private PGraphics FScope, img, mirror;
  private void initWanHuaTon(){
    FScope = createGraphics(FSector.width, FSector.height);
    img = createGraphics(FSector.width, FSector.height);
    mirror = createGraphics(FSector.width, FSector.height);
  }
  public void paint_WanHuaTon(float rot, float x, float y){
    update_var();
    
    img = FSector;
    img.mask(getScopeMask(rot, DEG));
    
    PGraphics tmp_img = createGraphics(img.width, img.height);
    tmp_img.beginDraw();
    tmp_img.imageMode(CENTER);
    tmp_img.translate(tmp_img.width/2, tmp_img.height/2);
    tmp_img.rotate(-rot);
    tmp_img.image(img, 0, 0);
    tmp_img.endDraw();
    img = tmp_img;
    
    mirror.beginDraw();
    mirror.imageMode(CENTER);
    mirror.translate(mirror.width/2, mirror.height/2);
    mirror.rotate(DEG);
    mirror.scale(-1, 1);
    mirror.image(img, 0, 0);
    mirror.endDraw();
    
    int loop_count = round(PI/DEG);
    FScope.beginDraw();
    FScope.imageMode(CENTER);
    FScope.background(205);
    FScope.translate(FSector.width/2, FSector.height/2);
    for(int i=0; i<loop_count; i+=1){
      FScope.image(img, 0, 0);
      FScope.rotate(DEG);
      FScope.image(mirror, 0, 0);
      FScope.rotate(DEG);
    }
    FScope.endDraw();
    FScope.mask(getScopeMask(0, TAU));
    
    imageMode(CENTER);
    image(FScope, x, y);
  }
  private PImage getScopeMask(float rot, float deg){
    PGraphics mask = createGraphics(FSector.width, FSector.height);
    mask.beginDraw();
    mask.arc(mask.width/2, mask.height/2, radius_, radius_, rot, rot+deg);
    mask.endDraw();
    
    return mask.get();
  }
  
  
  public void update_var(){
    if(END) return;
    
    super.update_var();
    
    FSector.beginDraw();
    FSector.clear();
    //println(cur_sector.width, cur_sector.height);
    //FSector.image(cur_sector, FSector.width/2, 0);
    
    PImage tmp = createImage(FSector.width, FSector.height, ARGB);
    cur_sector.loadPixels();
    for(int i=0; i<cur_sector.height; i+=1){
      int py = i - cur_sector.height;
      for(int j=0; j<cur_sector.width; j+=1){
        color a = cur_sector.pixels[i*cur_sector.width+j];
        if(a >= colorThreshold) continue;
        
        for(int k=0; k<num_sectors; k+=1){
          int pos_x = round(cos_[k]*j - sin_[k]*py) + FSector.width/2 ;
          int pos_y = round(sin_[k]*j + cos_[k]*py) + FSector.height/2 ;
          tmp.set(pos_x, pos_y, a);
        }
      }
    }
    FSector.image(tmp, 0, 0);
    FSector.endDraw();
  }
  
  public PImage eraseWhite(PImage pic){
    pic.loadPixels();
    for(int i=0; i<pic.pixels.length; i+=1){
      if(pic.pixels[i] > colorThreshold){
        pic.pixels[i] = 0;
      }
    }
    pic.updatePixels();
    
    return pic;
  }
  public void addFSec(FullSector fsec, float rot){
    PImage tmp_fsec = eraseWhite(fsec.FSector.get());
    
    FSector.beginDraw();
    FSector.imageMode(CENTER);
    FSector.translate(radius_, radius_);
    FSector.rotate(rot);
    FSector.image(tmp_fsec, 0, 0);
    FSector.endDraw();
  }
}


class Sector{
  public boolean END;
  
  public PGraphics sector;
  public PImage cur_sector;
  public float deg_, radius_;
  public float ori_x, ori_y;
  
  public StrangeShape ss;
  public boolean polygon = false;
  
  protected float degIncSpeed = radians(8);
  protected float colorThreshold = color(250);
  
  public Sector(float radius, float deg){
    assert(deg>0 && deg<=PI);
    
    END = false;
    ss = new StrangeShape();
    
    deg_ = deg;
    radius_ = radius;
    initSector();
    
    //drawCircle();
    //drawSpiral();
  }
  
  private float cur_endDeg = 0;//radians(5);
  public void update(float rot, float x, float y){
    update_var();
    paint(rot, x, y);
  }
  private void update_var(){
    if(cur_endDeg < deg_){
      cur_sector = Mask(cur_endDeg);
      cur_endDeg += degIncSpeed;
    }
    else END = true;
  }
  
  public void paint(float rot, float x, float y){
    imageMode(CORNER);
    pushMatrix();
    translate(x+ori_y*sin(rot), y-ori_y*cos(rot));
    rotate(rot);
    image(cur_sector, 0, 0);
    popMatrix();
  }
  
  public void drawImage(ArrayList<PVector> axis, ArrayList<PImage> img){
    assert(axis.size() == img.size());
    
    sector.beginDraw();
    sector.pushMatrix();
    sector.translate(ori_x, ori_y);
    for(int i=0; i<axis.size(); i+=1)
      sector.image(img.get(i), axis.get(i).x, axis.get(i).y);
    sector.popMatrix();
    sector.endDraw();
  }
  
  private void initSector(){
    float w, h;
    w = radius_*sin(deg_)+2;
    h = radius_;
    if(deg_ > HALF_PI){
      w = radius_+2;
      h += radius_*cos(deg_);
    }
    ori_x = 0;
    ori_y = radius_;
    
    sector = createGraphics(ceil(w), ceil(h));
    sector.beginDraw();
    sector.background(255);
    sector.noStroke();
    sector.line(ori_x, ori_y, 0, 0);
    sector.line(ori_x, ori_y, radius_*cos(deg_), radius_*(sin(deg_)+1));
    sector.noFill();
    sector.stroke(0);
    sector.strokeWeight(1);
    sector.arc(ori_x, ori_y, radius_*2, radius_*2, -HALF_PI, deg_);
    if(polygon) sector.line(0, 0, radius_*cos(deg_), radius_*(sin(deg_)+1));
    sector.endDraw();
    
    
  }
  
  
  public PImage Mask(float deg){
    int row = 0;
    int col = 0;
    int cur_pos = 0;
    PImage new_pic = createImage(sector.width, sector.height, ARGB);
    
    while(cur_pos < sector.width*sector.height){
      int x = col-floor(ori_x);
      int y = floor(ori_y)-row;
      
      if((mag(x, y) > radius_) || (atan(float(x)/y) > deg)){
        row += 1;
        col = 0;
        cur_pos = row*sector.width + col;
        continue;
      }
      if(sector.get(col, row) < colorThreshold){
        new_pic.set(col, row, sector.get(col, row));
      }
      
      if(col == sector.width-1){
        col = 0;
        row += 1;
      }
      else col += 1;
      cur_pos = row*sector.width + col;
    }
    
    return new_pic;
  }
  
  
  
  /////////////////////////////////////////
  private void drawSpiral(){
    int ss_num = 510;
    PVector last_p = new PVector(0, 0);
    for(int i=0; i<ss_num; i+=1){
      float t = map(i, 0, ss_num-1, 0, 1);
      PVector c = Arrangement.Spiral(radius_, 0.92, t);
      
      /*
      mag/ss_num: 
      0.8/90
      0.9/200
      0.92/260
      0.95/250
      */
      
      sector.beginDraw();
      sector.translate(sector.width/3, radius_/3);
      sector.imageMode(CENTER);
      //sector.image(ss.leaf, c.x, c.y);
      sector.stroke(0);
      sector.strokeWeight(1);
      sector.line(last_p.x, last_p.y, c.x, c.y);
      last_p = c;
      sector.endDraw();
    }
  }
  private void drawCircle(){
    int num = 30;
    float tmp_deg = HALF_PI - deg_;
    
    for(int i=0; i<num; i+=1){
      PVector c = Arrangement.Func_XY(radius_*1.5, tmp_deg/2, random(0, 1));
      c.set(c.x, ori_y-c.y);
      
      float r = random(10, 300);
      sector.beginDraw();
      sector.stroke(0);
      sector.strokeWeight(1);
      sector.ellipse(c.x, c.y, r, r);
      sector.endDraw();
    }
  }
}