class Box {
  //the players body
  Body body;

  float w, h;

  float c = 175;
  color clr = color(0, 0, 200);
  boolean fixed = false;
  Vec2 pos = new Vec2();
  float density;

  Building parent;

  //Constructor
  Box(Vec2 _pos, Vec2 size, boolean fixed_, float density) {
    this.density = density;
    this.pos=_pos;
    w = size.x;
    h = size.y;
    this.fixed = fixed_;//Fixed makes it Static usualy for rope ends

    MakeBox(_pos);
    body.setUserData(new Object[]{"box", "alive"});
  }



  /*
  *TThis Function Destroys the body of the box from the box2d world
   *
   */
  void destroyBody() {
    box2d.destroyBody(this.body);
  }




  /*
  *This Display function draws each box within a matrix at its Coordinate Position, its bodies angle and 
   *Parameter or Color cl
   *
   */
  void display(color cl) {
    pos = box2d.getBodyPixelCoord(body);
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

  void MakeBox( Vec2 pos) {
    // Build Body
    //Set the Type
    //Set the position Coordinate pixles to box world
    BodyDef bd = new BodyDef();
    if (fixed==false) {
      bd.type = BodyType.DYNAMIC;
    } else if (fixed==true) {
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

  void Explode() {
    Vec2 newPos = pos;
    Vec2 vel = player.body.getLinearVelocity();
    newPos.x+=40;
    Vec2 size = new Vec2(30, 15);
float level =3;
  for(float j=0;j<((w+h)/2)/10;j++){
    float s = size.x/ (((w+h)/2)/10);
    Box box = new Box( newPos,size,false, .1);
    box.body.setLinearVelocity(vel.add(new Vec2 (random(-50,50),random(-50,50))));
    box.body.setAngularVelocity(random(-10,10));
    parent.boxes.add(box);

    newPos.x-=32;
    if(j/level>1){
      newPos.y+=25;
    level+=3;
    }
  }

    //Box a = new Box(newPos, size, false, .1);
    //a.body.setLinearVelocity(vel.add(new Vec2 (random(-50,50),random(-50,50))));
    //a.body.setAngularVelocity(random(-10,10));
    //parent.boxes.add(a);

    //newPos.x-=32;
    //Box b = new Box(newPos, size, false, .1);
    //b.body.setLinearVelocity(vel.add(new Vec2 (random(-50,50),random(-50,50))));
    //b.body.setAngularVelocity(random(-10,10));
    //parent.boxes.add(b);   

    //newPos.x-=32;
    //Box c = new Box(newPos, size, false, .1);
    //c.body.setLinearVelocity(vel.add(new Vec2 (random(-50,50),random(-50,50))));
    //c.body.setAngularVelocity(random(-10,10));
    //parent.boxes.add(c);


    //newPos.y+=25;    
    //Box d = new Box(newPos, size, false, .1);
    //d.body.setLinearVelocity(vel.add(new Vec2 (random(-50,50),random(-50,50))));
    //d.body.setAngularVelocity(random(-10,10));
    //parent.boxes.add(d);

    //newPos.x+=32;
    //Box e = new Box(newPos, size, false, .1);
    //e.body.setLinearVelocity(vel.add(new Vec2 (random(-50,50),random(-50,50))));
    //e.body.setAngularVelocity(random(-10,10));
    //parent.boxes.add(e);

    //newPos.x+=32;
    //Box f = new Box(newPos, size, false, .1);
    //f.body.setLinearVelocity(vel.add(new Vec2 (random(-50,50),random(-50,50))));
    //f.body.setAngularVelocity(random(-10,10));
    //parent.boxes.add(f);
  }
}