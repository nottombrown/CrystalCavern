class Game extends LXPattern {
  
  final BasicParameter speed = new BasicParameter("SPEED", 1, 0.1, 10);
  final BasicParameter radius = new BasicParameter("RADIUS", 15, 0, 50);
  final BasicParameter hueBase = new BasicParameter("BASE", 200, 0, 360);
  
  float time = 0.;

  Game(LX lx) {
    super(lx);
    addParameter(speed);
    addParameter(radius);
    addParameter(hueBase);
  }
  
  public void run(double deltaMs) {
    time += deltaMs * speed.getValuef();
    float timeS = time / 1000.;
    
    // Create orb with a set radius in center
    
    LXPoint center = new LXPoint(model.cx,model.cy);
    for (LXPoint p : model.points) {
      float distance = dist(p.x, p.y, center.x, center.y);
      
      float brightness;
      if (distance > radius.getValuef()) {
        brightness = 100;
      } else {
        brightness = 0;
      }
      
//      println(radius.getValuef());
//      println(distance);
//      println(brightness);
//      println("XXX");
//      
      
      colors[p.index] = lx.hsb(
        hueBase.getValuef(),
        100,
        constrain((radius.getValuef() - distance)*blur, 0, 100)
      );
    }
  }
}
