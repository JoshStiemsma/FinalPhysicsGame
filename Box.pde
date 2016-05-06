class Box {
  //the players body
  Body body;
  //the width and height of the box
  float w, h;

  Vec2 size;
  //the float color of the box initialy grey
  float c = 175;
  //the color of the box, initialy blue
  color clr = color(0, 0, 200);
  //boolean if the box is fixed or not; usualy for chains and rope end
  boolean fixed = false;
  //box's positions as vec2
  Vec2 pos = new Vec2();
  //density of box as float
  float density;
  // the parent building of the box if there is one, initialy null
  Building parent;
  //the Vec2 initVel is the initial velocity of a box used when creating explosions and new boxes
  Vec2 initVel=new Vec2();
  //this boolean Hit by player is used to flag if this box was hit by the player
  boolean hitByPlayer=false;
  //the int on chain count is used to tell if this box has been in contact with the players chains for a certain time or not and if it needs ot be deleted
  int onChainCount = 0;

  //Constructor withou parent
  Box(Vec2 _pos, Vec2 size, boolean fixed_, float density, boolean _toCreate) {
    this.density = density;//set density to passed density
    this.pos=_pos;//set position to passed in position

    this.size=size;//set the size
    this.fixed = fixed_;//Fixed makes it Static usualy for rope ends

    w = size.x;//set width to size.x
    h = size.y;//set height to size.h
    if (_toCreate==true) {
      MakeBox(_pos);//create the box shape at given position _pos
      //body.setUserData(new Object[]{"box", "alive","offChain"});//set the boxes user data to box that is alive
    }
    if (body!=null) body.setUserData(new Object[]{"box", "alive", "offChain"});//set the boxes user data to box that is alive
  }
  //Constructor with parent
  Box(Vec2 _pos, Vec2 size, boolean fixed_, float density, Building parent, boolean _toCreate) {
    this.density = density;//set density to passed density
    this.pos=_pos;//set position to passed in position
    this.parent=parent;//set the parent to the given parent
    this.size=size;
    this.fixed = fixed_;//Fixed makes it Static usualy for rope ends

    if (_toCreate==true) {
      w = size.x;//set width to size.x
      h = size.y;//set height to size.h
      MakeBox(_pos);//create the box shape at given position _pos
      body.setUserData(new Object[]{"box", "alive", "offChain"});//set the boxes user data to box that is alive and offchain
    }
  }


  /*
  *TThis Function Destroys the body of the box from the box2d world
   *
   */
  void destroyBody() {
    box2d.destroyBody(this.body);//call the destroy function in box2d of this body
  }




  /*
  *This Display function draws each box within a matrix at its Coordinate Position, its bodies angle and 
   *Parameter or Color cl
   *
   */
  void display(color cl) {
    pos = box2d.getBodyPixelCoord(this.body);//grab the position of the box in pixel coordinates
    float a = body.getAngle();//set a to the rotation

    pushMatrix();//Enter the matrix neo
    translate(pos.x, pos.y);    // Using the Vec2 position and float angle to
    rotate(-a);              // translate and rotate the rectangle
    fill(cl);//set the fill to this boxes color
    noStroke();
    rectMode(CENTER);
    rect(0, 0, w, h);
    popMatrix();//leave the matrix neo
  }//end display

  void MakeBox( Vec2 pos) {
    // Build Body
    //Set the Type
    //Set the position Coordinate pixles to box world
    BodyDef bd = new BodyDef();
    if (fixed==false) {//if boolean fixed is true
      bd.type = BodyType.DYNAMIC;//box will move
    } else if (fixed==true) {
      bd.type = BodyType.STATIC;//box wont move
    }

    bd.position.set(box2d.coordPixelsToWorld(pos.x, pos.y));//set position useing coordinate pixels converted to world
    body = box2d.createBody(bd);//the body equals box2d creating a body of the body def bd

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
    fd.density = this.density;//set the denstiy to this boxes density
    fd.friction = 0.6;//set the firction
    fd.restitution = 0.6;//set the rest
    // Attach Fixture to Body               
    body.createFixture(fd);
  }

  /*
/This function explodes the box into smaller boxes when called, usualy called when player hits box or box hits ground
   /
   */
  void Explode() {
    //Vec2 newPos = box2d.getBodyPixelCoord(this.body);//grab position
    Vec2 newPos = pos;//grab position
    Vec2 vel = player.weight.getLinearVelocity();//grab linear velocity
    vel= new Vec2(vel.x/2, vel.y/2  );//reduce velocity by half
    Vec2 size = new Vec2(w/3, h/3);//size is a third of previose box size

    for (float i=0; i<=w/30; i++) {//for each 30% of each object create a new one a third of the objects size, or a pickup
      for (float j=0; j<=h/30; j++) {
        newPos.x+=w/9;//move positions over a 9th of the width
        int rand = int(random(0, 10));//create random varaible between 0 and 10
        if (rand>6&&rand<9) {//if between 6 and 9
          Pickup p = new Pickup("token", newPos, false);//create new pickup as atoken at this new position
          pickupsToCreate.add(p);//add this token to the pickups creation list
        } else if (rand>=9) {//if random is greater than 9
          Pickup p = new Pickup("invincible", newPos, false);//create new pickup of invincible at the position
          pickupsToCreate.add(p);//add it the the pickups creation list
        } else { //end if, didnt roll any pickup make a box
          Box newbox = new Box(new Vec2(newPos.x+(i*10), newPos.y), size, false, .1, false);//make new box
          parent.boxesToCreate.add(newbox);//add box to the parents boxes list, boom this parts crazy
          if (hitByPlayer)newbox.initVel=vel;//if hit by player than set its vel to players vel
        }
        if (j==h/10) {
          newPos.y+=(i+1)*5;//if made ten already then go up a bit on the y for a new row
        }//end add to height
      }//end for each row
    }//end creating new objects
  }//end explosion
}//end box