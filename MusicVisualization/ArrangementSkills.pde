public interface NecessaryVar{
  String LEN = "LEN";
  String THETA = "THETA";
  String RAD = "RAD";
  String ORI_X = "ORI_X";
  String ORI_Y = "ORI_Y";
  String T = "T";
  
  public abstract float LEN_transRules();
  public abstract float THETA_transRules();
  public abstract float RAD_transRules();
  public abstract float ORI_X_transRules();
  public abstract float ORI_Y_transRules();
  public abstract float T_transRules();
}


public enum ArrSkills{
  //LINE_, CROSS_LINE, CONNECTED_LINE, ARC_, ARC_ON_LINE
  
  LINE_{
    protected void init(){
      nvar.add(NecessaryVar.LEN);
      nvar.add(NecessaryVar.THETA);
    }
    public PVector getAxis(float[] args){
      assert(legalVarNum(args.length));
      
      float t = args[args.length-1];
      float len = args[0];
      float theta = args[1];
      
      return Arrangement.Func_XY(len, theta, t);
    }
  }, 
  CROSS_LINE{
    protected void init(){
      nvar.add(NecessaryVar.LEN);
      nvar.add(NecessaryVar.THETA);
      nvar.add(NecessaryVar.RAD);
    }
    public PVector getAxis(float[] args){
      assert(legalVarNum(args.length));
      
      float t = args[args.length-1];
      float len = args[0];
      float theta = args[1];
      float rad = args[2];
      return Arrangement.CrossLine(len, theta, rad, t);
    }
  }, 
  CONNECTED_LINE{
    protected void init(){
      nvar.add(NecessaryVar.RAD);
      nvar.add(NecessaryVar.THETA);
      nvar.add(NecessaryVar.RAD);
      nvar.add(NecessaryVar.THETA);
    }
    public PVector getAxis(float[] args){
      assert(legalVarNum(args.length));
      
      float rad1 = args[0];
      float theta1 = args[1];
      float rad2 = args[2];
      float theta2 = args[3];
      float t = args[4];
      return Arrangement.ConnectedLine(rad1, theta1, rad2, theta2, t);
    }
  }, 
  ARC_{
    protected void init(){
      nvar.add(NecessaryVar.RAD);
      nvar.add(NecessaryVar.THETA);
    }
    public PVector getAxis(float[] args){
      assert(legalVarNum(args.length));
      
      float t = args[args.length-1];
      float rad = args[0];
      float theta = args[1];
      return Arrangement.Arc(rad, theta, t);
    }
  }, 
  ARC_ON_LINE{
    protected void init(){
      nvar.add(NecessaryVar.LEN);
      nvar.add(NecessaryVar.THETA);
      nvar.add(NecessaryVar.RAD);
      nvar.add(NecessaryVar.ORI_X);
      nvar.add(NecessaryVar.ORI_Y);
    }
    public PVector getAxis(float[] args){
      assert(legalVarNum(args.length));
      
      float t = args[args.length-1];
      float len = args[0];
      float theta = args[1];
      float rad = args[2];
      float cx = args[3];
      float cy = args[4];
      return Arrangement.ArcOnLine(len, theta, rad, cx, cy, t);
    }
  };
  
  protected ArrayList<String> nvar; 
  private ArrSkills(){
    nvar = new ArrayList<String>();
    init();
    nvar.add(NecessaryVar.T);
  }
  public ArrayList<String> getNVar(){
    return nvar;
  }
  protected boolean legalVarNum(int varNum){
    return varNum == nvar.size();
  }
  
  protected abstract void init();
  public abstract PVector getAxis(float[] args);
}

/***************************************************/
public static class Arrangement{
  
  private final static float std_len = 300;
  
  
  public static PVector Func_XY(float len, float theta, float t){
    len = map(len, 0, 1, std_len*0.2, std_len*1.5);
    
    theta -= HALF_PI;
    float l = map(t, 0, 1, 0, len);
    float x = l*cos(theta);
    float y = l*sin(theta);
    
    return new PVector(x, y);
  }
  
  public static PVector Spiral(float initL, float mag, float t){
    final float MIN_L = 4;
    float total_r = log(MIN_L/initL) / log(mag);
    float len = initL * pow(mag, total_r*abs(t));
    float angle = total_r * TAU * t - HALF_PI;
    float x = len * cos(angle);
    float y = len * sin(angle);
    
    return new PVector(x, y);
  }
  
  public static PVector ConnectedLine(float rad1, float theta1, float rad2, float theta2, float t){
    PVector begin = Func_XY(rad1, theta1, 1);
    PVector end = Func_XY(rad2, theta2, 1);
    PVector dist = end.sub(begin).mult(t);
    
    return begin.add(dist);
  }
  
  public static PVector CrossLine(float len, float theta, float rad, float t){
    len = map(len, 0, 1, 0, std_len/5);
    rad = map(len, 0, 1, 0, std_len*2/3);
    
    theta -= HALF_PI;
    float center_x = rad * cos(theta);
    float center_y = rad * sin(theta);
    float angle = theta + HALF_PI;
    float tmp_len = map(t, 0, 1, -len/2, len/2);
    float x = center_x + tmp_len * cos(angle);
    float y = center_y + tmp_len * sin(angle);
    
    return new PVector(x, y);
  }
  
  public static PVector ArcOnLine(float len, float theta, float rad, float cx, float cy, float t){
    len = map(len, 0, 1, 0, std_len*2/3);
    rad = map(rad, 0, 1, 0, std_len*2.3);
    cx = map(cx, 0, 1, 0, rad);
    cy = map(cy, 0, 1, 0, rad);
    
    float angle = theta - PI;
    float root_x = cx + rad*cos(angle);
    float root_y = cy + rad*sin(angle);
    
    float r = sqrt(rad*rad + len*len/4);
    float deg = 2*atan(len/2/rad);
    deg = map(t, 0, 1, -deg/2, deg/2) + angle - PI;
    float x = root_x + r*cos(deg);
    float y = root_y + r*sin(deg);
    
    return new PVector(x, y);
  }
  
  public static PVector Arc(float rad, float theta, float t){
    rad = map(rad, 0, 1, 0, std_len*2/3);
    
    float deg = map(t, 0, 1, 0, theta) - HALF_PI;
    float x = rad*cos(deg);
    float y = rad*sin(deg);
    
    return new PVector(x, y);
  }
}