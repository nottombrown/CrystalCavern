class Game extends LXPattern {
  
  final BasicParameter speed = new BasicParameter("SPEED", 1, 0.1, 10);
  final BasicParameter radius = new BasicParameter("RADIUS", 0, 50, 360);
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
      float distance = dist(p.x, p.y, center.y, center.y);
      float brightness = (distance < radius.getValuef()) ? 0 : 1;
      
      colors[p.index] = lx.hsb(
        hueBase.getValuef(),
        100,
        distance
      );
    }
  }
}
