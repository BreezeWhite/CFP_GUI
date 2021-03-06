
class MusicInterpreter{
  MusicInfo2 minfo;
  
  public MusicInterpreter(){
  }
  
  private boolean inited = false;
  public void update_minfo(MusicInfo2 m){
    minfo = m;
    
    if(inited) return;
    
    init_sizeVar();
    init_degreeVar();
    inited = true;
  }
  
  private float[] MAX_SIZE;
  private float[] MIN_SIZE;
  final float MAX_SPEED = 10;
  final float THRESHOLD_ = -0.1;
  //***//
  public float getTatooRadius(float cur_time){
    update_minfo(cur_time);
    
    float mean_stren = constrain(minfo.mean_stren, 0, MAX_STRENGTH)*3;
    float cur_stren = map(mean_stren, 0, minfo.get_MAX_Stren()*0.8, THRESHOLD_, 1+THRESHOLD_);
    float mean_speed = constrain(minfo.mean_speed, 0, MAX_SPEED);
    float cur_speed = map(mean_speed, 0, MAX_SPEED, THRESHOLD_, 1+THRESHOLD_);
    println(cur_stren, cur_speed);
    if((abs(mean_stren*mean_speed)<1) && (cur_stren<0 || cur_speed<0)) return -1;
    
    int idx = 0;
    int cur_total = 0;
    while(minfo.mean_center > cur_total){
      cur_total += minfo.f_split_interval[idx];
      idx += 1;
    }
    float rad = map(abs(cur_stren*cur_speed), 0, 1, MIN_SIZE[idx-1], MAX_SIZE[idx-1]);
    
    /*
    println("current time: " + cur_time);
    println("min_size: " + MIN_SIZE[idx-1]);
    println("max_size: " + MAX_SIZE[idx-1]);
    println("cur_stren: " + cur_stren);
    println("cur_speed: " + cur_speed);
    println("return radius: " + rad + "\n");
    */
    return rad;
  }
  
  
  final float MAX_DEGREE = PI;
  final float MIN_DEGREE = radians(15);
  private int MAX_POW_2, MAX_POW_3, MAX_POW_5; // MIN_DEGREE * 2^MAX_POW_2 * 3^MAX_POW_3 <= MAX_DEGREE.
  private float avail_MAX_DEG = 0;
  //***//
  public float getTatooDegree(float cur_time){
    update_minfo(cur_time);
    
    float pow_2 = pow(2, minfo.total_fnum % MAX_POW_2);
    float pow_3 = pow(3, minfo.total_fnum % MAX_POW_3);
    float pow_5 = pow(5, minfo.total_fnum % MAX_POW_5);
    
    float DEG = MIN_DEGREE * pow_2 * pow_3 * pow_5;
    if(DEG > avail_MAX_DEG) avail_MAX_DEG = DEG;
    
    return DEG;
  }
  
  
  public ArrayList<PVector> getArrangeAxis(float cur_time){
    update_minfo(cur_time);
    
    Table required = new Table();
    for(String req_: ArrBaseCond.cond_considered){
      required.addColumn(req_);
    }
    TableRow row_ = required.addRow();
    float total_note = minfo.mean_speed * minfo.speed.length;
    row_.setFloat("note_num", total_note);
    row_.setFloat("time", minfo.currentTime());
    
    IntDict availSkills = ArrangementSkillTree.CondCheck(required);
    ArrayList<PVector> tmpAxis = Music_2_Arrange_TransRules.getAxis(minfo, availSkills, avail_MAX_DEG);
    num_coords = tmpAxis.size();
    
    return tmpAxis; 
  }
  
  int num_coords = 0;
  public ArrayList<PImage> getShapes(){
    ArrayList<PImage> shapes = new ArrayList<PImage>();
    
    for(int i=0; i<num_coords; i+=1){
      PGraphics shape = createGraphics(50, 50);
      shape.beginDraw();
      shape.colorMode(ARGB);
      shape.ellipse(25, 25, 49, 49);
      shape.endDraw();
      
      shapes.add(shape.get());
    }
    return shapes;
  }
  
  ///***********///
  private void init_sizeVar(){
    final float MIN = 50;
    final float MAX = 300;
    final float overlap = 0.5;
    
    float[] size_range = new float[0];
    int tmp_total = 0;
    for(int inter_num: minfo.f_split_interval){
      tmp_total += inter_num;
      float sp_point = map(tmp_total, 1, 88, MIN, MAX);
      size_range = append(size_range, sp_point);
    }
    size_range = splice(size_range, size_range[0], 0);
    size_range = append(size_range, size_range[size_range.length-1]);
    
    MAX_SIZE = new float[size_range.length];
    MIN_SIZE = new float[size_range.length];
    for(int i=1; i<size_range.length-1; i+=1){
      MAX_SIZE[i] = (size_range[i+1]-size_range[i])*overlap+size_range[i];
      MIN_SIZE[i] = size_range[i]-(size_range[i]-size_range[i-1])*overlap;
    }
    MAX_SIZE = reverse(subset(MAX_SIZE, 1, minfo.f_split_interval.length));
    MIN_SIZE = reverse(subset(MIN_SIZE, 1, minfo.f_split_interval.length));
  }
  private void init_degreeVar(){
    int max_deg = int(degrees(MAX_DEGREE));
    while(max_deg%2 == 0){
      MAX_POW_2 += 1;
      max_deg /= 2;
    }
    max_deg = int(degrees(MAX_DEGREE));
    while(max_deg%3 == 0){
      MAX_POW_3 += 1;
      max_deg /= 3;
    }
    max_deg = int(degrees(MAX_DEGREE));
    while(max_deg%5 == 0){
      MAX_POW_5 += 1;
      max_deg /= 5;
    }
  }
  
  private float last_time = 0;
  private void update_minfo(float cur_time){
    if(last_time != cur_time) {
      minfo.resetTime(cur_time);
      last_time = cur_time;
    }
  }
}

static class Music_2_Arrange_TransRules implements NecessaryVar {
  private static MusicInfo2 minfo;
  
  private static float MAX_DEG_;
  
  public static ArrayList<PVector> getAxis(MusicInfo2 m, IntDict availArr, float MAX_DEG){
    minfo = m;
    MAX_DEG_ = MAX_DEG;
    BASE_DEG = MAX_DEG_/availArr.get("LINE_");
    ArrayList<PVector> axis = new ArrayList<PVector>();
    
    for(String skill_name: availArr.keyArray()){
      ArrayList<String> neceVar = ArrSkills.valueOf(skill_name).getNVar();
      float[] args = getArgs(neceVar.toArray(new String[neceVar.size()]));
      
      float t_num = args[args.length-1];
      float[] new_args = new float[args.length];
      arrayCopy(args, new_args);
      for(int i=0; i<t_num; i+=1){
        float t = map(i, 0, t_num-1, 0, 1);
        new_args[args.length-1] = t;
        
        PVector p = ArrSkills.valueOf(skill_name).getAxis(new_args);
        axis.add(p);
      }
    }
    return axis;
  }
  
  public static float [] getArgs(String[] var_name){
    float[] args = new float[0];
    for(String v_name: var_name){
      if(v_name.equals(LEN)) args = append(args, len_transRules());
      else if(v_name.equals(THETA)) args = append(args, theta_transRules());
      else if(v_name.equals(RAD)) args = append(args, rad_transRules());
      else if(v_name.equals(ORI_X)) args = append(args, ori_x_transRules());
      else if(v_name.equals(ORI_Y)) args = append(args, ori_y_transRules());
      else if(v_name.equals(T)) args = append(args, t_transRules());
      else assert false: "Given skill not found: " + v_name;
    }
    return args;
  }
  
  
  public float LEN_transRules(){
    return len_transRules();
  }
  private static float len_transRules(){
    float max_stren = minfo.get_MAX_Stren();
    float cur_stren = minfo.mean_stren;
    
    float tmp_len = map(cur_stren, 0, max_stren, 0.3, 1);
    //println(tmp_len + " " + cur_stren + " " + max_stren);
    
    return tmp_len;
  }
  
  private static float BASE_DEG;
  private static float cur_deg = 0;
  public float THETA_transRules(){
    return theta_transRules();
  }
  private static float theta_transRules(){
    float tmp_deg = cur_deg;
    cur_deg = (cur_deg+BASE_DEG) % (MAX_DEG_+BASE_DEG);
    
    return tmp_deg;
  }
  
  public float RAD_transRules(){
    return rad_transRules();
  }
  private static float rad_transRules(){
    float len = len_transRules();
    float center = map(minfo.mean_center, 0, 87, 0, 1);
    float rad = map(len*center, 0, 1, 0.2, 1);
    
    return rad;
  }
  
  public float ORI_X_transRules(){
    return ori_x_transRules();
  }
  private static float ori_x_transRules(){
    float rad = rad_transRules();
    float center = map(minfo.mean_center, 0, 87, 0, 1);
    float deg = map(center, 0, 1, 0, MAX_DEG_);
    
    return rad * cos(deg);
  }
  
  public float ORI_Y_transRules(){
    return ori_y_transRules();
  }
  private static float ori_y_transRules(){
    float rad = rad_transRules();
    float center = map(minfo.mean_center, 0, 87, 0, 1);
    float deg = map(center, 0, 1, 0, MAX_DEG_);
    
    return rad * sin(deg);
  }
  
  public float T_transRules(){
    return t_transRules();
  }
  private static float t_transRules(){
    // Returns total sampling amount.
    int total_onset = floor(minfo.mean_speed * minfo.speed.length);
    int div = constrain(minfo.total_fnum/total_onset, 0, 1000);
    float m = map(div, 0, 1000, 0.6, 5);
    
    return total_onset*m;
  }
}