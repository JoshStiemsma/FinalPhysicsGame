//the circle class is a jbox 2d object of the circle type
class Circle {
  Vec2 position;//the position of the circle
  float r;//the radius of the circle
  Body body;//the body named body of the object
  String type;//the type in string form of the circle, like pickup, or something else
  //constructor for circle, with position, radius and type
  Circle(Vec2 _pos, float _r, String type) {
    r=_r;//set raius
    position=_pos;//set position
    MakeShape();//make the shape
    body.setUserData(new Object[]{type, "alive"});//set the userdata to the type and alive
  }

/*
*The function display is called every frame in the main display function
*/
  void display(color cl) {
    position = box2d.getBodyPixelCoord(body);//grab the physics based position
    float a = body.getAngle();//grab the angle

    pushMatrix();//Enter the matrix neo, it looks fun they said
    translate(position.x, position.y);    // Using the Vec2 position and float angle to
    rotate(-a);              // translate and rotate the rectangle
    fill(cl);//fill with certain color
    noStroke();
    ellipse(0, 0, r*2, r*2);//draw circle twice its size
    popMatrix();//leave matrix neo
  }//end display

  /*
  *TThis Function Destroys the body of the box from the box2d world
   *
   */
  void destroyBody() {
    box2d.destroyBody(this.body);
  }
  /*
*The function makeShape, makes the cirlces shape within the physics world
*/
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
  }//close makeshape
}//close circle class