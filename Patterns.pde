// Here's all the pattern code. Each pattern is a class
// with a run method, and lots of helpers available like
// LFOs, modulators, parameters. They can have transitions
// between them, layers, effects, etc.

class Periodicity extends LXPattern {
  
  final SinLFO[] pos = new SinLFO[Model.NUM_STRIPS]; 
  
  Periodicity(LX lx) {
    super(lx);
    for (int i = 0; i < pos.length; ++i) {
      pos[i] = new SinLFO(0, 1, 60*SECONDS / (float) i);  
      addModulator(pos[i]).start(); 
    }
  }
  
  public void run(double deltaMs) {
    int si = 0;
    for (Strip strip : model.strips) {
      float pp = pos[si++].getValuef();
      int pi = 0;
      for (LXPoint p : strip.points) {
        colors[p.index] = lx.hsb(
          (lx.getBaseHuef() + dist(p.x, p.y, model.cx, model.cy) / model.xRange * 180) % 360,
          100,
          max(0, 100 - 200*abs(pp - (pi / (float) Strip.NUM_POINTS))) 
        );
        ++pi;
      }
    }
  }
}

class Warp extends LXPattern {
  
  private final SinLFO hr = new SinLFO(90, 180, 34000);
  
  private final SinLFO sr = new SinLFO(9000, 37000, 41000);
  private final SinLFO slope = new SinLFO(0.5, 1.5, sr); 
  
  private final SinLFO speed = new SinLFO(500, 2500, 27000);
  private final SawLFO move = new SawLFO(TWO_PI, 0, speed);
  private final SinLFO tight = new SinLFO(6, 14, 19000);
  
  private final SinLFO cs = new SinLFO(17000, 31000, 11000);
  private final SinLFO cx = new SinLFO(model.xRange * .25, model.xRange * .75, cs); 
  
  Warp(LX lx) {
    super(lx);
    addModulator(hr).start();
    addModulator(sr).start();
    addModulator(slope).start();
    addModulator(speed).start();
    addModulator(move).start();
    addModulator(tight).start();
    addModulator(cs).start();
    addModulator(cx).start();
  }
  
  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      float dx = (abs(p.x - cx.getValuef()) - slope.getValuef() * abs(p.y - model.cy)) / model.xRange;
      float b = 50 + 50*sin(dx * tight.getValuef() + move.getValuef());
      
      colors[p.index] = lx.hsb(
        (lx.getBaseHuef() + + abs(p.y - model.cy) / model.yRange * hr.getValuef() + abs(p.x - cx.getValuef()) / model.xRange * hr.getValuef()) % 360,
        100,
        b
      );
    }
  }
}

class ParameterWave extends LXPattern {
  
  final BasicParameter amp = new BasicParameter("AMP", 1);
  final BasicParameter speed = new BasicParameter("SPD", 0.5, -1, 1); 
  final BasicParameter period = new BasicParameter("PERIOD", 0.5, 0.5, 5);
  final BasicParameter thick = new BasicParameter("THICK", 2, 1, 5);
  final BasicParameter xColor = new BasicParameter("X-COLOR", 0.5);
  final BasicParameter yColor = new BasicParameter("Y-COLOR", 0.5);
  
  private float base = 0;
  
  ParameterWave(LX lx) {
    super(lx);
    addParameter(amp);
    addParameter(speed);
    addParameter(period);
    addParameter(thick);
    addParameter(xColor);
    addParameter(yColor);
  }
  
  public void run(double deltaMs) {
    base += deltaMs / 1000. * TWO_PI * speed.getValuef();
    
    for (LXPoint p : model.points) {
      float svy = model.cy + amp.getValuef() * model.yRange/2.*sin(base + (p.x - model.cx) / model.xRange * TWO_PI * period.getValuef());
      float hShift =
        abs(p.x - model.cx) / model.xRange * 360 * xColor.getValuef() +
        abs(p.y - model.cy) / model.yRange * 360 * yColor.getValuef();
      colors[p.index] = lx.hsb(
        (lx.getBaseHuef() + hShift) % 360,
        100,
        max(0, 100 - (100 / (thick.getValuef()*FEET)) * abs(p.y - svy))
      );
    }
  }
}

class AuroraBorealis extends LXPattern {
  
  final SinLFO yOffset = new SinLFO(0, 3*FEET, 3*SECONDS);
  
  AuroraBorealis(LX lx) {
    super(lx);
    addModulator(yOffset).start();
  }
  
  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      colors[p.index] = lx.hsb(
        (p.y + 2*FEET * sin(p.x/model.xRange * 4*PI) + yOffset.getValuef())/model.yRange * 180,
        100,
        100
      );
    }
  }
}

class Bouncing extends LXPattern {
  
  final BasicParameter size = new BasicParameter("SIZE", 1*FEET, 1*FEET, 5*FEET);
  final BasicParameter rate = new BasicParameter("RATE", 2*SECONDS, 1*SECONDS, 4*SECONDS);
  final BasicParameter max = new BasicParameter("MAX", model.cy, model.cy, model.yMax);
  final BasicParameter min = new BasicParameter("MIN", 0, 0, model.cy);
  
  final SinLFO py = new SinLFO(min, max, rate);
  
  Bouncing(LX lx) {
    super(lx);
    addParameter(size);
    addParameter(rate);
    addParameter(min);
    addParameter(max);
    addModulator(py).start();
  }
  
  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      colors[p.index] = lx.hsb(
        0,
        100,
        max(0, 100 - (100/size.getValuef()) * abs(p.y - py.getValuef()))
      );
    }
  }
}

class Plasma extends LXPattern {
  
  final BasicParameter speed = new BasicParameter("SPEED", 1, 0.1, 10);
  final BasicParameter hueSpread = new BasicParameter("SPREAD", 45, 0, 360);
  final BasicParameter hueBase = new BasicParameter("BASE", 200, 0, 360);
  
  float time = 0.;

  Plasma(LX lx) {
    super(lx);
    addParameter(speed);
    addParameter(hueSpread);
    addParameter(hueBase);
  }
  
  public void run(double deltaMs) {
    time += deltaMs * speed.getValuef();
    float timeS = time / 1000.;
    for (LXPoint p : model.points) {
      float v1 = sin(p.x / 30. + timeS * 3.);
      float v2 = sin(10 * sin(p.x / (model.cx * 2.) * sin(timeS / 2.) + p.y / (model.cx * 2.) * cos(timeS / 3.)) + timeS);
      float cx = p.x / (model.cx * 2.) + 0.5 * sin(timeS / 2.);
      float cy = p.y / (model.cx * 2.) + 0.5 * cos(timeS / 1.5);
      float v3 = sin(sqrt(50. * (cx * cx + cy * cy) + 1.) + timeS);
      float v = v1 + v2 + v3;
      
      colors[p.index] = lx.hsb(
        max(0, min(360, sin(v) * hueSpread.getValuef() + hueBase.getValuef())),
        100,
        max(50, min(100, v * 25 + 50))
      );
    }
  }
}

public class Fire extends LXPattern {

  final BasicParameter scaleX = new BasicParameter("XSCALE", 200, 1, 1000);
  final BasicParameter scaleY = new BasicParameter("YSCALE", 150, 1, 1000);

  final BasicParameter xNoiseScale = new BasicParameter("XNOISE", 0.035, 0.001, 1);
  final BasicParameter yNoiseScale = new BasicParameter("YNOISE", 0.009, 0.001, 1);

  final BasicParameter noiseBase = new BasicParameter("NOISE", 0, 0, 1000);
  final BasicParameter noiseOctaves = new BasicParameter("OCT", 3, 1, 6);
  final BasicParameter noiseWeight = new BasicParameter("WGHT", 0.6, 0, 1);
  
  PGraphics g;
  PImage source, iceSource;
  PImage disp;
  float dispX = 0, dispY = 0;

  int dispScale = 1;
  int dispShift = 0;
  
  Fire(LX lx) {
    super(lx);
    createSource();
    createIceSource();
    g = createGraphics(int(model.xRange), int(model.yRange));

    addParameter(scaleX);
    addParameter(scaleY);

    addParameter(xNoiseScale);
    addParameter(yNoiseScale);

    addParameter(noiseBase);
    addParameter(noiseOctaves);
    addParameter(noiseWeight);
  }
  
  void drawGradientPart(PGraphics g, int y1, int y2, color c1, color c2) {
    for (int i = y1; i <= y2; i++) {
      float inter = map(i, y1, y2, 0, 1);
      color c = lerpColor(c1, c2, inter);
      g.stroke(c);
      g.line(0, i, g.width, i);
    }
  }
  
  void drawGradient(PGraphics g, float[] ys, color[] cs) {
    for (int i = 0; i < ys.length - 1; i++) {
      drawGradientPart(g, int(ys[i] * g.height), int(ys[i+1] * g.height), cs[i], cs[i+1]);
    }
  }
  
  void createSource() {
    PGraphics g = createGraphics(int(model.xRange), int(model.yRange));
    g.beginDraw();
    g.noFill();
    drawGradient(g, new float[] {0, 0.4, 0.45, 0.5, 0.6, 0.8, 1}, new color[] {
      color(0,0,0), 
      color(0,0,30),
      color(21,50,50),
      color(21,100,100),
      color(31,100,100),
      color(50,70,100),
      color(50,30,100)
    });
    g.endDraw();
    source = g.get();
    source.loadPixels();
  }
    
  void createIceSource() {
    PGraphics g = createGraphics(int(model.xRange), int(model.yRange));
    g.beginDraw();
    g.noFill();
    drawGradient(g, new float[] {0, 0.4, 0.45, 0.5, 0.6, 0.8, 1}, new color[] {
      color(261,0,0), 
      color(261,30,30),
      color(261,50,50),
      color(261,100,100),
      color(219,70,100),
      color(197,70,100),
      color(197,0,100)
    });
    g.endDraw();
    iceSource = g.get();
    iceSource.loadPixels();
  }
  
  void createDisplacementMap() {
    noiseDetail(int(noiseOctaves.getValuef()), noiseWeight.getValuef());
    noiseSeed(int(noiseBase.getValuef()));

    float xNoiseScaleF = xNoiseScale.getValuef();
    float yNoiseScaleF = yNoiseScale.getValuef();
  
    PGraphics g = createGraphics(int((model.xRange + 1) / dispScale), int((model.yRange + 1) / dispScale));
    g.beginDraw();
    g.loadPixels();
    for (int y = 0; y < g.height; y++) {
      for (int x = 0; x < g.width; x++) {
        g.pixels[y * g.width + x] = 
          int(map(noise(dispX + (x << dispShift) * xNoiseScaleF, 0 + (y << dispShift) * yNoiseScaleF), 0, 1, 0, 255)) +  
          (int(map(noise(dispX + (x << dispShift) * xNoiseScaleF, dispY + (y << dispShift) * yNoiseScaleF), 0, 1, 0, 255)) << 8) + 
          (int(map(noise(dispX + (x << dispShift) * xNoiseScaleF, dispY + (y << dispShift) * yNoiseScaleF), 0, 1, 0, 255)) << 16) + 
          (255 << 24);
      }
    }
    g.updatePixels();
    g.endDraw();
    disp = g.get();
    disp.loadPixels();
  }

  int beatNum = 0;

  public void run(double deltaMs) {
    dispX += 0.02 / 2;
    dispY += 0.05 / 3;
    createDisplacementMap();

    float scaleXF = scaleX.getValuef();
    float scaleYF = scaleY.getValuef();

    if (beat.peak()) {
      beatNum = (beatNum + 1) % 2;
    }
    float inc = beatNum == 0 ? beat.getValuef() * beat.getValuef() : 0;
    
    for (LXPoint p : model.points) {
      int x = int(p.x);
      int y = int(model.yRange - p.y);
      if (x < 0) x = 0;
      if (x >= source.width) x = source.width - 1;
      if (y < 0) y = 0;
      if (y >= source.height) y = source.height - 1;
      int sx = int(
          x + (
            (
              ((
                disp.pixels[(y >> dispShift) * disp.width + (x >> dispShift)]
              ) & 0xff) - 128
            ) * scaleXF
          ) / 256.
        );
      int sy = int(
          y + (
            (
              (((disp.pixels[(y >> dispShift) * disp.width + (x >> dispShift)]) >> 8) & 0xff) - 
              128
            ) * scaleYF
          ) / 256.
        );
      if (sx < 0) sx = 0;
      if (sx >= source.width) sx = source.width - 1;
      if (sy < 0) sy = 0;
      if (sy >= source.height) sy = source.height - 1;
      //float inc = eq.getAveragef(1, 4) > beatTrigger.getValuef() ? 1 : 0;
      colors[p.index] = lerpColor(source.pixels[sy * source.width + sx], iceSource.pixels[sy * source.width + sy], inc);
    }
  }
}

public class Dance extends LXPattern {

  PGraphics g;
  final int MOVE_COUNT = 6;
  PImage[] moves = new PImage[MOVE_COUNT];
  int move = 0;
  int flip = 1;
  
  int[] table = new int[256];

  final int SOURCE_TEMPO = 0;
  final int SOURCE_BEAT = 1;
  final int SOURCE_COUNT = 2;
  
  final DiscreteParameter beatSource = new DiscreteParameter("BTSRC", SOURCE_TEMPO, SOURCE_COUNT);

  BasicParameter speed = new BasicParameter("SPEED", 1, 0, 2);
  
  Dance(LX lx) {
    super(lx);
    addParameter(speed);
    addParameter(beatSource);
    
    // One period of the sinus function shifted to range [0-255] 
    for (int i = 0; i < 256; i++) {
      table[i] = (int)(128 + 127.0 * sin(i * TWO_PI / 256.0));
    }

    for (int i = 0; i < MOVE_COUNT; i++) {
      moves[i] = loadImage("images/dance" + Integer.toString(i + 1) + "a.png");
    }

    g = createGraphics(int(model.xRange), int(model.yRange));
  }
  
  color rgb2hsv(float r, float g, float b) {
    float h, s, v;

    float min, max, delta;
    min = min( r, g, b );
    max = max( r, g, b );
    v = max;        // v
    delta = max - min;
    if( max != 0 )
      s = delta / max;    // s
    else {
      // r = g = b = 0    // s = 0, v is undefined
      s = 0;
      h = -1;
      return color(0, s * 100, v * 100);
    }
    if( r == max )
      h = ( g - b ) / delta;    // between yellow & magenta
    else if( g == max )
      h = 2 + ( b - r ) / delta;  // between cyan & yellow
    else
      h = 4 + ( r - g ) / delta;  // between magenta & cyan
    h *= 60;        // degrees
    if( h < 0 )
      h += 360;
      
    return color(h, s * 100, v * 100);
  }
  
  float timeMs = 0;
  
  PImage drawImage() {
    // grab some samples, hmm could have used lookup table...
    int t = (int)(128 + 127.0 * sin(0.0013 * (float)timeMs));
    int t2 = (int)(128 + 127.0 * sin(0.0023 * (float)timeMs));
    int t3 = (int)(128 + 127.0 * sin(0.0007 * (float)timeMs));

    g.loadPixels();
    for (int y = 0; y < g.height; y++) {
      for (int x = 0; x < g.width; x++) {
        // Define a function for each color component that depends on the
        // x,y coordinate and time. Use the lookup table for nice swirly movement.
        // There is no deeper logic here, I just experimented with the functions
        // untill I found something that looked pleasing.
        int r = table[(x / 5 + t / 4 + table[(t2 / 3 + y / 8) & 0xff]) & 0xff];
        int gr = table[(y / 3 + t + table[(t3 + x / 5) & 0xff]) & 0xff];
        int b = table[(y / 4 + t2 + table[(t + gr / 4 + x / 3) & 0xff]) & 0xff];
        g.pixels[x + y * g.width] = rgb2hsv(r, gr, b);
      }
    }
    g.updatePixels();

    float beatZoom = map(eq.getAveragef(1, 4), 0, 1, 1, 4);
    
    g.beginDraw();
    g.pushMatrix();
    g.translate(model.cx / 2 - 15, model.cy + 15);
    g.scale(1, -1);
    g.scale(0.08);
    g.blendMode(DIFFERENCE);
    g.translate(moves[move].width / 2, 0);
    g.scale(flip, 1);
    g.translate(-moves[move].width / 2, 0);
    g.image(moves[move], 0, 0);
    g.popMatrix();
    g.endDraw();

    return g.get();
  }

  int pickMove() {
    int m = move;
    do {
      m = int(random(MOVE_COUNT));
    } while (m == move);
    return m;
  }

  public void run(double deltaMs) {
    timeMs += deltaMs * speed.getValuef();
   
    if (beatSource.getValuei() == SOURCE_TEMPO) {
      if (lx.tempo.beat()) {
        move = pickMove();
        flip = random(1) > 0.5 ? 1 : -1;
      }
    }
    else {
      if (beat.peak()) {
        move = pickMove();
        flip = random(1) > 0.5 ? 1 : -1;
      }
    }

    PImage img = drawImage();
    
    for (LXPoint p : model.points) {
      int ix, iy;
      if (p.z > 0) {
        ix = int((model.xRange - p.x - 5*FEET) / model.xRange * img.width); 
        iy = int(p.y / model.yRange * img.height); 
      }
      else {
        ix = int(p.x / model.xRange * img.width); 
        iy = int(p.y / model.yRange * img.height); 
      }
      colors[p.index] = img.get(ix, iy);
    }
  }
}

