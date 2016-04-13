class Circle {
  Vec2 position;
  float r;
  Body body;
  String type;
  Circle(Vec2 _pos, float _r, String type) {
    r=_r;
    position=_pos;
    MakeShape();
    body.setUserData(new Object[]{type, "alive"});
  }


  void display(color cl) {
    position = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();

    pushMatrix();
    translate(position.x, position.y);    // Using the Vec2 position and float angle to
    rotate(-a);              // translate and rotate the rectangle
    fill(cl);
    stroke(0);
    ellipse(0, 0, r*2, r*2);
    popMatrix();
  }//end display

  /*
  *TThis Function Destroys the body of the box from the box2d world
   *
   */
  void destroyBody() {
    box2d.destroyBody(this.body);
  }
  void MakeShape() {
    // Build Body
    //Set the Type
    //Set the position Coordinate pixles to box world
    BodyDef bd = new BodyDef();

    bd.type = BodyType.DYNAMIC;

    bd.position.set(box2d.coordPixelsToWorld(position.x, position.y));
    body = box2d.createBody(bd);

    // Define a box
    CircleShape cs = new CircleShape();
    //2d width is from center to edge // Box2D considers the width and height of a
    cs.m_radius = box2d.scalarPixelsToWorld(r);                    // rectangle to be the distance from the
    // center to the edge (so half of what we
    // normally think of as width or height.) 
    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    // Parameters that affect physics
    fd.density = .01;
    fd.friction = 0.6;
    fd.restitution = 0.6;


    // Attach Fixture to Body               
    body.createFixture(fd);
  }
}