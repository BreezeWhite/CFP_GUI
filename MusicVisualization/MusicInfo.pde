


class MusicInfo{
  ArrayList<FloatList> pianoRoll; //Dimension: N samples*88
  ArrayList<FloatList> strength; //Same dimension as above
  
  static final int sample_range = 100; // 1 second. 0.01 sec/sample;
  final int[] f_split_interval = {20, 25, 22, 21}; // Total 88
  
  int[] inter_f_num = new int[f_split_interval.length];
  int[] speed = new int[f_split_interval.length]; // Calculate the number of predicted onset.
  float[] mean_f_stren = new float[f_split_interval.length];
  float mean_speed; 
  float mean_stren;
  float mean_center; // Current energy center. Calculate according to inter_f_num and mean_f_stren.
  float f_change_dir; // value<0: center move left; value>0: center move right.
  int total_fnum; // Total playing notes during the current time range.
  int length_;
  
  protected int current_time = sample_range/2;
  
  public MusicInfo(String pred_path){
    pianoRoll = new ArrayList<FloatList>();
    strength = new ArrayList<FloatList>();
    readFile(pred_path);
    length_ = pianoRoll.size()-sample_range/2;
  }
  public void printInfo(){
    println("Current time: " + currentTime());
    println("mean_speed: " + mean_speed);
    println("mean_stren: " + mean_stren);
    println("mean_center: " + mean_center);
    println("f_change_dir: " + f_change_dir);
    println("total_fnum: " + total_fnum);
  }
  public ArrayList<FloatList> getPlayingNote(int range){
    // Current playing note would at index=0.
    // The rest part is for the use of 3D fly-in effect.
    ArrayList<FloatList> notes = new ArrayList<FloatList>(range);
    if(current_time > pianoRoll.size()-sample_range/2){
      return notes;
    }
    update(current_time);
    
    for(int i=0; i<range; i+=1){
      FloatList tmp;
      if(current_time+i >= pianoRoll.size()){
        int total_key = pianoRoll.get(0).size();
        tmp = new FloatList(total_key);
        for(int j=0; j<total_key; j+=1) tmp.set(j, 0);
      } 
      else{
        tmp = pianoRoll.get(current_time+i);
      }
      notes.add(tmp);
    }
    current_time += 1;
    
    return notes;
  }
  public int[] getCurOnset(float bias_range){
    assert(lligal_time_range(current_time)): "Given time: " + current_time + "\n Avail time: " + length_;
    
    bias_range = int(bias_range/SEC_PER_SAMPLE);
    
    int[] notes_played = new int[0];
    boolean[] onset = new boolean[KEY_NUM];
    for(int i=int(current_time-bias_range+1); i<current_time; i+=1){
      for(int j=0; j<KEY_NUM; j+=1){
        if(onset[j] == true) continue;
        
        boolean cur_played = isPlayed(pianoRoll.get(i).get(j), strength.get(i).get(j));
        boolean before_played = isPlayed(pianoRoll.get(i-1).get(j), strength.get(i-1).get(j));
        if(!before_played && cur_played){
          notes_played = append(notes_played, j);
          onset[j] = true;
        }
      }
    }
    return notes_played;
  }
  public FloatList getStrength(float cur_time){
    int time_idx = int(cur_time + sample_range/2);
    return strength.get(time_idx);
  }
  public void setStrength(float time, FloatList value){
    int idx = int(time + sample_range/2);
    strength.set(idx, value);
  }
  public void resetTime(float time){
    time /= SEC_PER_SAMPLE;
    assert(lligal_time_range(int(time))): "Given time is out of range.";
    current_time = int(time + sample_range/2);
    current_time = constrain(current_time, 0, length_-1);
    
    update(float(current_time)*SEC_PER_SAMPLE);
  }
  public boolean isEnd(){
    return !lligal_time_range(current_time-sample_range/2);
  }
  public boolean isEnd(int time){
    return !lligal_time_range(time);
  }
  public float currentTime(){
    return (current_time-sample_range/2)*SEC_PER_SAMPLE;
  }
  
  private void readFile(String pred_path){
    // Read and interpret raw data into local variables: pianoRoll, strength;
    BufferedReader pred = createReader(pred_path);
    int total_key = 0;
    
    try{
      String line;
      while((line = pred.readLine()) != null){
        String[] elem = splitTokens(line, " \n");
        total_key = elem.length;
        
        FloatList tmp = new FloatList(total_key);
        for(String e: elem) tmp.append(float(e));
        
        pianoRoll.add(tmp);
        strength.add(tmp);
      }
      pred.close();
    } catch(IOException e){
      e.printStackTrace();
    }
    
    // Append additonal zero value to the beginning and the end.
    FloatList tmp = new FloatList(total_key);
    for(int j=0; j<total_key; j+=1) tmp.set(j, 0);
    
    for(int i=0; i<sample_range; i+=1){
      if(i < sample_range/2){
        pianoRoll.add(0, tmp);
        strength.add(0, tmp);
      }
      else{
        pianoRoll.add(tmp);
        strength.add(tmp);
      }
    }
  }
  
  protected void update(float time_){
    int time = int(time_/SEC_PER_SAMPLE);
    update_inter_f_num_mean_stren(time);
    update_mean_stren();
    update_mean_center_change_dir();
    update_speed(time);
    
    int total_onset = 0;
    for(int s: speed) total_onset += s;
    mean_speed = total_onset/float(speed.length);
  }
  
  private void update_inter_f_num_mean_stren(int time){
    int start_sample, end_sample;
    start_sample = int(time-sample_range/2);
    end_sample = int(time+sample_range/2)-1;

    for(int i=0; i<inter_f_num.length; i+=1){
      inter_f_num[i] = 0;
      mean_f_stren[i] = 0;
    }
    
    total_fnum = 0;
    for(int i=start_sample; i<end_sample; i+=1){
      int start_roll = 0;
      for(int n=0; n<f_split_interval.length; n+=1){
        for(int count=start_roll; count<f_split_interval[n]+start_roll; count+=1){
          if(isPlayed(pianoRoll.get(i).get(count), strength.get(i).get(count)))
            inter_f_num[n] += 1;
            mean_f_stren[n] += strength.get(i).get(count);
        }
        if(inter_f_num[n] != 0) mean_f_stren[n] /= inter_f_num[n];
        
        start_roll += f_split_interval[n];
      }
    }
    for(int n: inter_f_num) total_fnum += n;
  }
  private void update_mean_stren(){
    mean_stren = 0;
    for(int i=0; i<inter_f_num.length; i+=1)
      mean_stren += mean_f_stren[i]*inter_f_num[i];
    
    if(total_fnum == 0) mean_stren = 0;
    else mean_stren /= total_fnum;
  }
  private void update_mean_center_change_dir(){
    float mean_energy = mean_stren*total_fnum/2;
    
    if(mean_energy <= 0.0001){
      f_change_dir = 44.5 - mean_center;
      mean_center = 44.5;
      return;
    }
    
    float current_energy = 0, last_energy = 0;
    int cur_total_roll = 0, last_total_roll = 0;
    int idx = 0;
    do{
      last_energy = current_energy;
      last_total_roll = cur_total_roll;
      current_energy += mean_f_stren[idx]*inter_f_num[idx];
      cur_total_roll += f_split_interval[idx];
      
      idx += 1;
    }while(current_energy<mean_energy);
    
    float tmp = map(mean_energy, last_energy, current_energy, last_total_roll, cur_total_roll-1);
    f_change_dir = tmp - mean_center;
    mean_center = tmp;
  }
  
  private void update_speed(int time){
    final int TOTAL_KEY_NUM = 88;
    
    int start_roll = 0;
    for(int i=0; i<f_split_interval.length; i+=1){
      
      ArrayList<Boolean> onOff = new ArrayList<Boolean>(TOTAL_KEY_NUM);
      for(int j=0; j<TOTAL_KEY_NUM; j+=1) onOff.add(false);
      
      int onset_num = 0;
      int start_sample = int(time-sample_range/2);
      int end_sample = int(time+sample_range/2)-1;
      for(int n=start_sample; n<end_sample; n+=1){
        for(int j=start_roll; j<f_split_interval[i]+start_roll; j+=1){
          if(onOff.get(j) == false){
            if(isPlayed(pianoRoll.get(n).get(j), strength.get(n).get(j))){
              onset_num += 1;
              onOff.set(j, true);
            }
          }
          if(!isPlayed(pianoRoll.get(n).get(j), strength.get(n).get(j))) 
            onOff.set(j, false);
        }
      }
      speed[i] = onset_num;
      start_roll += f_split_interval[i];
    }
  }
  
  private boolean isPlayed(float pred, float stren){
    return pred > 0.5;
  }
  private boolean lligal_time_range(int time){
    return (time >= 0) && (time < length_);
  }
}

class MusicInfo2 extends MusicInfo{
  
  public MusicInfo2(String pred_path){
    super(pred_path);
  }
  
  private float MAX_Stren = 0;
  private int last_max_t = sample_range/2;
  //****//
  public float get_MAX_Stren(){
    final float fade_mag_sec = 0.5;
    
    int t_interval = floor((current_time-last_max_t)*SEC_PER_SAMPLE);
    float tmp_max = MAX_Stren * pow(fade_mag_sec, t_interval);
    for(int i=last_max_t+1; i<current_time; i+=1){
      float max_stren = strength.get(i).max();
      if(max_stren > tmp_max){
        MAX_Stren = max_stren;
        last_max_t = i;
      }
    }
    return MAX_Stren;
  }
}