//pickup is a class that holds a circle class and also gives it a type but then handles how that type should act differenlty from other circles
  class Pickup {

  String type;//the type of circle/pickup
  Vec2 position;//position of pickip

  Body body;//the body of the pickup

  float r= 10;//radius set to ten
  color cl = color(255, 0, 0);//color originaly blue but most are images
//cunstructor including, Type, Position and toCreate yet boolean
  Pickup(String _type, Vec2 _pos, boolean create) {
    type= _type;//set type
    position = _pos;//set pos
    if (create) {//if to create is true
      MakeShape();//make the shape
      body.setUserData(new Object[]{type, "alive"});//set the user data to the type and alive
    }
  }
  /*
*update is called in the mian update function and updates the objects physics
*
*/
  void update() {
    Object[] o1 = (Object[]) body.getUserData();//grab data flags
    if (o1[1]=="dead") {//if flagged as dead
      pickupsToKill.add(this);//add to death list
       if (o1[0]=="token"){//if token then play token soun
       tokenSound.play();
     tokenSound.amp(.5);
   }
      if (o1[0]=="health"){}//room for sounds
      if (o1[0]=="invincible"){//if invin then play invin pickup sound
      invin.play();
     invin.amp(.5);}
    }//end if invin
  }//end update
/*display is called winthinth the main display function and draws the pickup to screeen
*
*
*/
  void display() {
    position = box2d.getBodyPixelCoord(body);//grab physics position
    float a = body.getAngle();//grab angle

    pushMatrix();//enter the matric neo
    translate(position.x, position.y);    // Using the Vec2 position and float angle to
    rotate(-a);              // translate and rotate the rectangle
    scale(.1);
    imageMode(CENTER);
    switch(type) {//draw the image type depending on the type
    case "token":
      image(token, 0, 0);
      break;
    case "health":
      image(health, 0, 0);
      break;
    case "invincible":
      image(invincible, 0, 0);
      break;
    }
    popMatrix();//leave the matrix neo
  }
/*
*this function destroy the body
*
*/
  void destroy() {
    box2d.destroyBody(this.body);
  }

/*
*This function makes the shape oft he pickup in the physics world
*
*/
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