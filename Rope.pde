//the rope class is a manager for jointed boxes that hang from a stationary box on the cieling
class Rope {

  // Rope properties
  float totalLength;  // How long
  int numPoints;      // How many points

  // Our chain is a list of particles
  ArrayList<Box> boxes;
  ArrayList<Box> boxesToKill = new ArrayList<Box>();

//position of the entire rope and its base
  Vec2 position;

  // Chain constructor including length, amount of nodes, position, and toCreate yet or not
  Rope(float l, int n, Vec2 pos, boolean toCreate) {
    this.position = pos;
    totalLength = l;
    numPoints = n;
    if (toCreate) Create();
  }

/*
*the function create actualy creates the body of the rope based off of the ropes variables
*
*/
  void Create() {
    boxes = new ArrayList();
    // Here is the real work, go through and add particles to the chain itself
    Box previouse = null;
    for (int i=0; i < numPoints+1; i++) {
      // Make a new particle
      Box b = null;

      // First and last particles are made with density of zero
      if (i == 0) {
        b = new Box(new Vec2(position.x, position.y-10), new Vec2(5, 5), true, .10,true);
      } else b = new Box(new Vec2(position.x, position.y+(20*i)), new Vec2(5, 20), false, .10,true);
      boxes.add(b);
      // Connect the particles with a distance joint
      if (i > 0) {

        RevoluteJointDef rjd = new RevoluteJointDef();
        rjd.bodyA= previouse.body;
        rjd.bodyB = b.body;
        rjd.collideConnected=false;
        if (i==1) rjd.localAnchorA.set(0, -2);
        else rjd.localAnchorA.set(.5, 1.2);
        rjd.localAnchorB.set(.5, -1.2);
        RevoluteJoint dj = (RevoluteJoint) box2d.world.createJoint(rjd);
      }
      previouse = b;
    }
  }
/*
*the fucntion destroy removes all the boxes bdies from the world
*
*/
  void destroy() {//remove all boxes
    for (Box b : boxes) b.destroyBody();
  }
  /*
*the function remove from array, removes the passed box from the roeps boxes array
*
*/
  void removeFromArray(Box b) {
    boxes.remove(b);
  }
/*
*Update is called int he main update and updates all the boxes of the rope
*
*/
  void update() {
    for (int i = 0; i<boxes.size(); i++) {
      Object[] o1 =  (Object[])boxes.get(i).body.getUserData();
      if (o1[1]=="dead") boxesToKill.add(boxes.get(i));
    }
  }
  // Draw the rope by drawing all the boes on the ropes boxes arraylist
  void display() {
    for (int i = 0; i<boxes.size(); i++) {
      if (i==0) {
        // boxes.get(i).display(color(255, 255, 255));
      } else {


        Vec2 pos = box2d.getBodyPixelCoord(boxes.get(i).body);
        float a1 = boxes.get(i).body.getAngle();
        pushMatrix();
        imageMode(CENTER);       
        translate(pos.x, pos.y);
        rotate(-a1);
        scale(.15);
        image(rope, 0, 0);

        popMatrix();
      }
    }
  }

/*
*handle death takes care of all the evil boxes tht need to die at the proper time though, like harry potter so tht they dont break the system
*
*/
  void HandleDeaths() {
    for (Box b : boxesToKill) {
      b.destroyBody();
      boxes.remove(b);
      //remove box from its array of boxes in either rope or building
    }
    boxesToKill = new ArrayList<Box>();
  }
}