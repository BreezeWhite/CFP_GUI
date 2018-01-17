import java.util.Collections;

class Tatoo{
  class Sectors{
    FullSector sector;
    int num_sector;
    float cur_offset_deg = 0;
    float spin_speed = radians(0.1);
  }
  
  private float x, y;
  private ArrayList<Sectors> sectors;
  private MusicInterpreter mintpr;
  private boolean END = false;
  private final int MAX_QUEUE_NUM = 2;
  
  public Tatoo(float ori_x, float ori_y){
    x = ori_x;
    y = ori_y;
    sectors = new ArrayList<Sectors>();
    
    mintpr = new MusicInterpreter();
  }
  
  //***//
  public boolean update(float cur_time, MusicInfo2 m){
    if(END) return true;
    
    mintpr.update_minfo(m);
    addSector(cur_time);
    
    for(int idx=0; idx<sectors.size(); idx+=1){
      if(idx >= 1 && sectors.get(idx-1).sector.END == false) break;
      Sectors curSec = sectors.get(idx);
      
      curSec.sector.paint(curSec.cur_offset_deg, x, y);
      //curSec.sector.paint_WanHuaTon(curSec.cur_offset_deg, x, y); // Extremely slow...
      curSec.cur_offset_deg += curSec.spin_speed;
      
      if(idx >= 1 && curSec.sector.END){
        float offset_deg = curSec.cur_offset_deg-sectors.get(idx-1).cur_offset_deg;
        
        sortSectors(idx);
        sectors.get(0).sector.addFSec(sectors.get(idx).sector, offset_deg);
        sectors.remove(idx);
      }
    }
    
    return false;
  }
  public void setEND(){
    if(sectors.size() == 0){
      END = true;
      return;
    }
    if(sectors.size() > 1) return;
    if(sectors.get(0).sector.END == false) return;
    if(sectors.get(0).cur_offset_deg % radians(15) < 0.01){
      sectors.get(0).sector.paint(sectors.get(0).cur_offset_deg, x, y);
      END = true;
    }
  }
  
  private void sortSectors(int idx){
    float size = sectors.get(idx).sector.radius_;
    for(int i=0; i<idx; i+=1){
      if(sectors.get(i).sector.radius_ < size){
        Collections.swap(sectors, i, idx);
        break;
      }
    }
  }
  
  public void addSector(float radius, float deg, int num_s, float cur_time){
    Sectors tmp = new Sectors();
    tmp.sector = new FullSector(radius, deg, abs(num_s));
    tmp.num_sector = abs(num_s);
    int dir = num_s>0 ? 1: -1;
    tmp.spin_speed *= dir;
    
    ArrayList<PVector> axis = mintpr.getArrangeAxis(cur_time);
    ArrayList<PImage> imgs = mintpr.getShapes();
    tmp.sector.drawImage(axis, imgs);
    
    sectors.add(tmp);
  }
  
  private float last_add_time = 0;
  private final float min_add_interval = 0.5;
  private void addSector(float cur_time){
    if(sectors.size() >= MAX_QUEUE_NUM) return; // To avoid too many sectors waiting drawing in queue;
    if(cur_time-last_add_time < min_add_interval) return;
    last_add_time = cur_time;
    
    float rad = mintpr.getTatooRadius(cur_time);
    if(rad == -1) return;
    
    float deg = mintpr.getTatooDegree(cur_time);
    println(round(TAU/deg));
    
    float dir = random(-1, 1);
    dir = dir>0? 1: -1;
    addSector(rad, deg, floor(dir*TAU/deg), cur_time);
  }
}