class Box {
  //the players body
  Body body;

  float w, h;

  float c = 175;
  color clr = color(0, 0, 200);
  boolean fixed = false;
  
  int density;
  //Constructor
  Box(Vec2 pos, Vec2 size, boolean fixed_,int density) {
    this.density = density;
    w = size.x;
    h = size.y;
    this.fixed = fixed_;

    MakeBox(  pos, fixed_);
     body.setUserData(this);
  }

  void display(color cl) {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    
    
    pushMatrix();
    translate(pos.x, pos.y);    // Using the Vec2 position and float angle to
    rotate(-a);              // translate and rotate the rectangle
    fill(cl);
    stroke(0);
    rectMode(CENTER);
    rect(0, 0, w, h);
    popMatrix();
  }//end display

  void MakeBox( Vec2 pos, boolean fixed_) {
    // Build Body
    //Set the Type
    //Set the position Coordinate pixles to box world
    BodyDef bd = new BodyDef();
    if (fixed_==false) {
     bd.type = BodyType.DYNAMIC;
    } else if (fixed_==true) {
     bd.type = BodyType.STATIC;
    }
    
    bd.position.set(box2d.coordPixelsToWorld(pos.x, pos.y));
    body = box2d.createBody(bd);

    
   

    // println(bd.type);
    // Define a box
    PolygonShape sd = new PolygonShape();
    //2d width is from center to edge
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);  // Box2D considers the width and height of a
    sd.setAsBox(box2dW, box2dH);                    // rectangle to be the distance from the
    // center to the edge (so half of what we
    // normally think of as width or height.) 
    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = this.density;
    fd.friction = 0.6;
    fd.restitution = 0.6;


    // Attach Fixture to Body               
    body.createFixture(fd);
  }
}