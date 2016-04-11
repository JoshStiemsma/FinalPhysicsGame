class Rope {

  // Rope properties
  float totalLength;  // How long
  int numPoints;      // How many points

  // Our chain is a list of particles
  ArrayList<Box> boxes;
  ArrayList<Box> boxesToKill = new ArrayList<Box>();


  Vec2 position;

  // Chain constructor
  Rope(float l, int n, Vec2 pos, boolean toCreate) {
    this.position = pos;
    totalLength = l;
    numPoints = n;
    if (toCreate) Create();
  }


  void Create() {
    boxes = new ArrayList();
    float len = totalLength / numPoints;
    // Here is the real work, go through and add particles to the chain itself
    for (int i=0; i < numPoints+1; i++) {
      // Make a new particle
      Box b = null;

      // First and last particles are made with density of zero
      if (i == 0 ) b = new Box(new Vec2(position.x, position.y-10), new Vec2(10, 10), true, .10);
      else b = new Box(new Vec2(position.x, position.y+(10*i)), new Vec2(5+(i*2), 5+(i*2)), false, .10);
      boxes.add(b);

      // Connect the particles with a distance joint
      if (i > 0) {
        DistanceJointDef djd = new DistanceJointDef();
        Box previous = boxes.get(i-1);
        // Connection between previous particle and this one
        djd.bodyA = previous.body;
        djd.bodyB = b.body;
        // Equilibrium length
        djd.length = box2d.scalarPixelsToWorld(len);
        // These properties affect how springy the joint is 
        djd.frequencyHz = 0;
        djd.dampingRatio = 0;

        // Make the joint.  Note we aren't storing a reference to the joint ourselves anywhere!
        // We might need to someday, but for now it's ok
        DistanceJoint dj = (DistanceJoint) box2d.world.createJoint(djd);
      }
    }
  }

  void destroy() {//remove all boxes
    for (Box b : boxes) b.destroyBody();
  }
  void removeFromArray(Box b) {
    boxes.remove(b);
  }
  // Draw the rope by drawing all the boes on the ropes boxes arraylist
  void display() {
    for (int i = 0; i<boxes.size(); i++) {
      Object[] o1 =  (Object[])boxes.get(i).body.getUserData();
      if (o1[1]=="dead") boxesToKill.add(boxes.get(i));

      if (i==0) {
        boxes.get(i).display(color(255, 255, 255));
      } else {
        boxes.get(i).display(175);
      }
    }
  }


  void HandleDeaths() {
    for (Box b : boxesToKill) {
      b.destroyBody();
      boxes.remove(b);
      //remove box from its array of boxes in either rope or building
    }
    boxesToKill = new ArrayList<Box>();
  }
}