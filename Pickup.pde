class Pickup {

  String type;
  Vec2 position;

  Body body;

  float r= 10;
  color cl = color(255, 0, 0);

  Pickup(String _type, Vec2 _pos, boolean create) {
    type= _type;
    position = _pos;
    if (create) {
      MakeShape();
      body.setUserData(new Object[]{type, "alive"});
      switch(type){
        case "token":
        cl= color(255,255,0);
        break;
        case "health":
        cl = color(255,0,0);
        break;
        case "invincible":
        cl = color(0,0,255);
        break;
        
      }
    }
    
    
    
    
  }


  void display() {

    Object[] o1 = (Object[]) body.getUserData();
    if (o1[1]=="dead") {
      pickupsToKill.add(this);
    }


    position = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();

    pushMatrix();
    translate(position.x, position.y);    // Using the Vec2 position and float angle to
    rotate(-a);              // translate and rotate the rectangle
    fill(cl);
    stroke(0);
    ellipse(0,0, r, r);
    popMatrix();
  }

  void destroy() {
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



    // println(bd.type);
    // Define a box
    CircleShape cs = new CircleShape();
    //2d width is from center to edge // Box2D considers the width and height of a
    cs.m_radius = box2d.scalarPixelsToWorld(float(9));                    // rectangle to be the distance from the
    // center to the edge (so half of what we
    // normally think of as width or height.) 
    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    // Parameters that affect physics
    fd.density = .05;
    fd.friction = 0.6;
    fd.restitution = 0.6;


    // Attach Fixture to Body               
    body.createFixture(fd);
  }
}