
class StrangeShape{
  PGraphics leaf;
  PGraphics _5bienShin;
  PGraphics polygon;
  
  public StrangeShape(){
    create_polygon();
    create_5beinShin();
    createLeaf();
  }
  
  private void create_polygon(){
    polygon = createGraphics(39, 111);
    polygon.beginDraw();
    polygon.translate(19, 0);
    polygon.noFill();
    
    polygon.beginShape();
    
    polygon.vertex(0, 0);
    polygon.bezierVertex(-25, 45, -25, 90, 0, 110);
    polygon.bezierVertex(25, 90, 25, 45, 0, 0);
    
    polygon.endShape();
    polygon.endDraw();
  }
  
  private void create_5beinShin(){
    
    _5bienShin = createGraphics(54, 53);
    
    _5bienShin.beginDraw();
    _5bienShin.translate(27, 0);
    _5bienShin.noFill();
    _5bienShin.strokeWeight(0.5);
    _5bienShin.scale(2);
    
    _5bienShin.beginShape();
    
    _5bienShin.vertex(-5, 0);
    _5bienShin.vertex(5, 0);
    _5bienShin.vertex(13, 20);
    _5bienShin.vertex(0, 26);
    _5bienShin.vertex(-13, 20);
    _5bienShin.vertex(-5, 0);
    
    _5bienShin.endShape();
    
    _5bienShin.endDraw();
  }
  private void createLeaf(){
    float t = 0.6;
    float x = bezierPoint(0, -25, 0, -25, t);
    float y = bezierPoint(0, 45, 110, 90, t);
    float dx = bezierTangent(0, -25, 0, -25, t);
    float dy = bezierTangent(0, 45, 110, 90, t);
    
    //noStroke();
    
    leaf = createGraphics(10, 28);
    leaf.beginDraw();
    leaf.translate(4, 0);
    leaf.noFill();
    leaf.scale(0.25);
    leaf.strokeWeight(3);
    
    leaf.beginShape();
    
    leaf.vertex(0, 0);
    
    //leaf.bezierVertex(-25, 45, -25, 90, 0, 110);
    leaf.bezierVertex(-25, 45, dx-7, dy, x, y);
    leaf.bezierVertex(10, 78, 0, 104, 3, 90);
    leaf.bezierVertex(0, 104, -17, 93, 0, 110);
    
    leaf.bezierVertex(25, 90, 25, 45, 0, 0);
    leaf.endShape();
    
    leaf.ellipse(-6, 90, 8, 8);
    leaf.endDraw();
  }
}