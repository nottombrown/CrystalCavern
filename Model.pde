// This file defines the structural model of where lights
// are placed. It can be extended and tacked onto, and each
// light point can exist anywhere in 3-D space. The model
// can be iterated over to visit all the points, and each
// point has an index into the underlying color buffer.

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

static class Model extends LXModel {

  public static final int NUM_STRIPS = 24;  // Number of horizontal strips (arranged vertically)
  public static final float STRIP_SPACING = 2.25*INCHES;

  public final List<Strip> strips;

  Model() {
    super(new Fixture());
    Fixture f = (Fixture) fixtures.get(0);
    this.strips = Collections.unmodifiableList(f.strips);
  }

  private static class Fixture extends LXAbstractFixture {

    public static final int NUM_STRIPS = 24; 

    private final List<Strip> strips = new ArrayList<Strip>();

    Fixture() {
      // Build an array of strips, from top to bottom
      Strip strip;
      
      for (int i = 0; i < NUM_STRIPS; ++i) {
        strip = new Strip((NUM_STRIPS - i)*STRIP_SPACING);
        strips.add(strip);
        addPoints(strip);
      }
    }
  }
}

static class Strip extends LXModel {

  public static final int NUM_POINTS = 50;
  public static final int NUM_POINTS_PER_PART = NUM_POINTS;
  public static final float POINT_SPACING = METER / 30.;

  public final float y;

  Strip(float y) {
    super(new Fixture(y));
    this.y = y;
  }

  private static class Fixture extends LXAbstractFixture {
    Fixture(float y) {
      /**
       * Points in each segment are added right to left
      */
      for (int i = 0; i < NUM_POINTS_PER_PART; ++i) {
        addPoint(new LXPoint((NUM_POINTS_PER_PART - i)*POINT_SPACING, y, 0));
      }
    }
  }
}
