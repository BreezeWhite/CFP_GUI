
public static class ArrangementSkillTree{
  static Table availArr;
  static ArrSkillCriterion arrCond;
  
  private static boolean initialized = false;
  
  private static ArrangementSkillTree ast;
  public static ArrangementSkillTree getInstance(){
    if(!initialized) ast = new ArrangementSkillTree();
    initialized = true;
    return ast;
  }
  
  private ArrangementSkillTree(){
    arrCond = ArrSkillCriterion.getInstance();
    
    availArr = new Table();
    for(ArrSkills ask: ArrSkills.values()){
      availArr.addColumn(ask.toString());
    }
    ConstructSkillTree();
  }
  private void ConstructSkillTree(){
    TableRow[] level = new TableRow[ArrBaseCond.cond_num];
    level[0] = availArr.addRow();
    level[0].setInt("LINE_", 1);
    
    level[1] = availArr.addRow();
    level[1].setInt("LINE_", 1);
    
    level[2] = availArr.addRow();
    level[2].setInt("CONNECTED_LINE", 3);
    
    level[3] = availArr.addRow();
    level[3].setInt("CROSS_LINE", 4);
    level[3].setInt("LINE_", 1);
    
    level[4] = availArr.addRow();
    level[4].setInt("ARC_", 2);
    
    level[5] = availArr.addRow();
    level[5].setInt("ARC_ON_LINE", 2);
  }
  
  
  public static IntDict CondCheck(Table req){
    /**
    Condition check here uses 'or' logic to make the determination.
    */
    
    assert(req.getColumnCount() == ArrBaseCond.cond_considered.length);

    if(!initialized) {
      ast = new ArrangementSkillTree();
      initialized = true;
    }
    
    int MAX_level = 0;
    for(String cond_name: ArrSkillCriterion.cond_considered){
      float tmp_req = req.getFloat(0, cond_name);
      for(int i=0; i<ArrSkillCriterion.cond_num; i+=1){
        float threshold = ArrSkillCriterion.condTable.getFloat(i, cond_name);
        
        // value -1 reprsents this condition is not considered here.
        if(threshold == -1) continue; 
        
        if(tmp_req > threshold && MAX_level < i)
          MAX_level = i;
      }
    }
    return AvailArr(MAX_level);
  }
  
  public static IntDict AvailArr(int level){
    if(!initialized) {
      ast = new ArrangementSkillTree();
      initialized = true;
    }
    
    IntDict tmpAvail = new IntDict();
    for(ArrSkills ask: ArrSkills.values()){
      int tmpValue = 0;
      for(int i=0; i<=level; i+=1){
        tmpValue += availArr.getInt(i, ask.toString());
      }
      if(tmpValue <= 0) continue;
      
      tmpAvail.set(ask.toString(), tmpValue);
    }
    
    return tmpAvail;
  }
}

public static interface ArrBaseCond{
  static String[] cond_considered = {"note_num", "time"};
  static final int cond_num = 6;
  static Table condTable = new Table();
}

public static class ArrSkillCriterion implements ArrBaseCond{
  private static ArrSkillCriterion ac;
  private static float[] time;
  private static float [] note_num;
  
  public static ArrSkillCriterion getInstance(){
    ac = new ArrSkillCriterion();
    return ac;
  }
  
  private ArrSkillCriterion(){
    init_time();
    init_note_num();
    init_table();
  }
  private static void init_note_num(){
    note_num = new float[cond_num];
    //note_num = {0, 160, 320, 410, 550, 700}; return;
    
    int cur_num = 0;
    int num_interval = 150;
    for(int i=0; i<cond_num; i+=1){
      note_num = append(note_num, cur_num);
      cur_num += num_interval;
    }
  }
  private static void init_time(){
    time = new float[cond_num];
    //time = {0, 40, 70, 100, 140, 200}; return;
    
    float cur_time = 0;
    float time_interval = 40;
    for(int i=0; i<cond_num; i+=1){
      time = append(time, cur_time);
      cur_time += time_interval;
    }
  }
  
  private static void init_table(){
    for(String cond_name: cond_considered)
      condTable.addColumn(cond_name);
          
    for(int i=0; i<cond_num; i+=1){
      condTable.addRow();
      for(String cond_name: cond_considered){
        if(cond_name.equals("time")) condTable.setFloat(i, cond_name, time[i]);
        else if(cond_name.equals("note_num")) condTable.setFloat(i, cond_name,note_num[i]);
      }
    }
  }
}