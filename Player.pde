class Player {

  //the players body
  Body body;

  boolean dead= false;

  Vec2 position;
  //Constructor
  Player() {
    MakePlayersBody();
    platforms.add(new Platform(startingPosition.x-30, startingPosition.y));
    body.setUserData(new Object[]{"player", "alive"});
  }

  PVector startingPosition = new PVector(350, 450);

  float timeSinceLastWallHit = 0;

  void display() {
    if (!dead) {
      ApplyInput();
      ApplyLift();
    }
    position = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();

    Fixture f = body.getFixtureList();
    PolygonShape ps = (PolygonShape) f.getShape();

    CheckBoundaries();

    rectMode(CENTER);
    pushMatrix();
    translate(position.x, position.y);
    rotate(-a);
    beginShape();
    for (int i = 0; i < ps.getVertexCount(); i++) {
      Vec2 v = box2d.vectorWorldToPixels(ps.getVertex(i));
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
    popMatrix();
  }//end display




  void reset() {
    lives=3;
    platforms.add(new Platform(startingPosition.x-30, startingPosition.y));
    body.setLinearVelocity(new Vec2(0, 0));
    body.setTransform(box2d.coordPixelsToWorld(startingPosition), float(0));
    dead=false;
  }

  void ApplyLift() {
    Vec2 pos = body.getWorldCenter();
    body.applyForce(new Vec2(0, 1250  ), pos);
  }
  void ApplyInput() {
    if (in.Down) Thrust(); 
   // if (in.Left) body.setAngularVelocity(.5);
    //if (in.Right) body.setAngularVelocity(-.5);
    Vec2 vel = body.getLinearVelocity();
    if (in.Left) body.setLinearVelocity(new Vec2( vel.x-1, vel.y));
    if (in.Right) body.setLinearVelocity(new Vec2( vel.x+1, vel.y));

    //println(body.getAngularVelocity());
    if (body.getAngularVelocity()!=0) {
      body.setAngularVelocity(body.getAngularVelocity()*.64);
    }
    if (in.Space) {
      Push();
    } else {
      println("not push");
    }
  }


  void Push() {
    println("push");
    for (Building building : buildings) {
      for (Box box : building.boxes) {
        Vec2 bPos = box2d.getBodyPixelCoord(box.body);
        Vec2 distV = position.sub(bPos);
        if (mag(distV.x, distV.y)<200) {
          float a = atan2(distV.y, distV.x);
          a-=HALF_PI;
          float fx = 10*sin(a);
          float fy = 10*cos(a);  
          box.body.setLinearVelocity(new Vec2(fx, fy));
        }
      }
    }
    for (Rope r : ropes) {
      for (Box box : r.boxes) {
        Vec2 bPos = box2d.getBodyPixelCoord(box.body);
        Vec2 distV = position.sub(bPos);
        if (mag(distV.x, distV.y)<200) {
          float a = atan2(distV.y, distV.x);
          a-=HALF_PI;
          float fx = 10*sin(a);
          float fy = 10*cos(a);  
          box.body.setLinearVelocity(new Vec2(fx, fy));
        }
      }
    }
  }


  /*
*
   *This functions applies force to the player when given a Vec2 of force 
   */
  void applyForce(Vec2 force) {
    Vec2 pos = body.getWorldCenter();
    body.applyForce(force, pos);
  }//end apply force

  void Thrust() {
    float a = body.getAngle();

    if (abs(a)>TWO_PI) {
      int d= int(abs(a)/TWO_PI); 
      if (a>0)a-=(d*TWO_PI);
      if (a<0)a+=(d*TWO_PI);
    }
    a=a+HALF_PI;
    Vec2 force = new Vec2(-1500*cos(a), -1500*sin(a));
    Vec2 pos = body.getWorldCenter();
    body.applyForce(force, pos);
  }


  /*
*This functions collects the players position relative to the screen,
   *And kills the player if they go too far out of view
   */
  void CheckBoundaries() {
    Vec2 pos =  box2d.getBodyPixelCoord(body);
    if (pos.x>width+viewOffset||pos.y>height-viewOffset+30) player.dead=true;     //Kill Player if the go out of bounds
  }

  /*
*This Function creates the Box2d Body for the player
   *
   */
  void MakePlayersBody() {
    //define the plygon
    PolygonShape sd = new PolygonShape();


    Vec2[] vertices = new Vec2[5];
    vertices[0] = box2d.vectorPixelsToWorld(new Vec2(0, -50));
    vertices[1] = box2d.vectorPixelsToWorld(new Vec2(10, -35));
    vertices[2] = box2d.vectorPixelsToWorld(new Vec2(10, 0));
    vertices[3] = box2d.vectorPixelsToWorld(new Vec2(-10, 0));
    vertices[4] = box2d.vectorPixelsToWorld(new Vec2(-10, -35));


    sd.set(vertices, vertices.length);

    //Define the bodydef and make it from the shape
    //Define the TYPE and POSITION here
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(startingPosition));
    body = box2d.createBody(bd);

    //Define a fixture 
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    fd.friction = .3;
    fd.density = 2;
    fd.restitution = 0.5;

    body.createFixture(fd);
    //Shortcut
    //body.createFixture(sd,1.0);

    //Functions to attach initial velocity and angle are
    //body.setLinearVelocity(new Vec2(random(-5,5), random(2,5)));
    //body.setAngularVelocity(random(-5,5));
  }//end make player body
}