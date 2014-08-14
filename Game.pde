class Game extends LXPattern {
  
  final BasicParameter blur = new BasicParameter("BLUR", 0.48, 0, 1);
  final BasicParameter speed = new BasicParameter("SPEED", 1, 0.1, 10);
  final BasicParameter radius = new BasicParameter("RADIUS", 14.4, 0, 50);
  final BasicParameter hueBase = new BasicParameter("BASE", 200, 0, 360);
  
  float time = 0.;

  Game(LX lx) {
    super(lx);
    addParameter(blur);
    addParameter(radius);
    addParameter(speed);
    addParameter(hueBase);
  }
  
  public void run(double deltaMs) {
    time += deltaMs * speed.getValuef();
    float timeS = time / 1000.;
    
    // Create orb with a set radius in center
    Orb orb = new Orb(model.cx, model.cy, radius.getValuef());
    orb.run();
  }
  
  
  // An orb that knows how to draw itself
  class Orb {
    public final float x;
    public final float y;
    public final float radius;
    
    Orb(float x, float y, float radius) {
      this.x = x;
      this.y = y;
      this.radius = radius;
    }
    public void run() {
      LXPoint center = new LXPoint(model.cx,model.cy);
      for (LXPoint p : model.points) {
        float distance = dist(p.x, p.y, center.x, center.y);
        
        float brightness;
        if (distance > radius) {
          brightness = 100;
        } else {
          brightness = 0;
        }
        
        colors[p.index] = lx.hsb(
          hueBase.getValuef(),
          100,
          constrain((radius - distance)*blur.getValuef()*radius, 0, 100)
        );
      }
    } 
  }
  
}

