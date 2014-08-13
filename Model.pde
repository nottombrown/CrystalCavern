// This file defines the structural model of where lights
// are placed. It can be extended and tacked onto, and each
// light point can exist anywhere in 3-D space. The model
// can be iterated over to visit all the points, and each
// point has an index into the underlying color buffer.

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

static class Model extends LXModel {

  public static final int NUM_STRIPS = 24; // Actual number of strips per side
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
      
      // Starboard side 
      for (int i = 0; i < NUM_STRIPS; ++i) {
        strip = new Strip(0, i*STRIP_SPACING);
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

  public final float x;
  public final float z;

  Strip(float z, float x) {
    super(new Fixture(z, x));
    this.z = z;
    this.x = x;
  }

  private static class Fixture extends LXAbstractFixture {
    Fixture(float z, float y) {
      /**
       * Points in each segment are added left to right
      */
      for (int i = 0; i < NUM_POINTS_PER_PART; ++i) {
        addPoint(new LXPoint((NUM_POINTS_PER_PART + i)*POINT_SPACING, y, z));
      }
    }
  }
}
