class Player {

  //the players body
  Body body;

  boolean dead= false;
  //Constructor
  Player() {
    MakePlayersBody();
    platforms.add(new Platform(startingPosition.x-30, startingPosition.y));
    body.setUserData(new Object[]{"player","alive"});

  }

  PVector startingPosition = new PVector(350, 450);


  void display() {
    CheckInput();
    Vec2 pos = box2d.getBodyPixelCoord(body);

    float a = body.getAngle();

    Fixture f = body.getFixtureList();
    PolygonShape ps = (PolygonShape) f.getShape();

    CheckBoundaries();

    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
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
    platforms.add(new Platform(startingPosition.x-30, startingPosition.y));
    body.setTransform(box2d.coordPixelsToWorld(startingPosition), float(0));
    dead=false;
  }


  void CheckInput() {
    if (in.Up==true) Thrust(); 
    if (in.Left==true) body.setAngularVelocity(2);
    if (in.Right==true) body.setAngularVelocity(-2);
    //println(body.getAngularVelocity());
    if (body.getAngularVelocity()!=0) {
      body.setAngularVelocity(body.getAngularVelocity()*.64);
    }
  }


  //This functions applies force to the player when given a Vec2 of force 
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
    Vec2 force = new Vec2(1500*cos(a), 1500*sin(a));
    Vec2 pos = body.getWorldCenter();
    body.applyForce(force, pos);
  }

  void CheckBoundaries() {

    Vec2 pos =  box2d.getBodyPixelCoord(body);

    if (pos.x>width+viewOffset) {
      float a = body.getAngle();

      if (abs(a)>TWO_PI) {
        int d= int(abs(a)/TWO_PI); 
        if (a>0)a-=(d*TWO_PI);
        if (a<0)a+=(d*TWO_PI);
      }
      a=a+HALF_PI;

      body.applyForce(  new Vec2(-100, 0), body.getWorldCenter());
    }
    if (pos.y<0-viewOffset) {
      float a = body.getAngle();

      if (abs(a)>TWO_PI) {
        int d= int(abs(a)/TWO_PI); 
        if (a>0)a-=(d*TWO_PI);
        if (a<0)a+=(d*TWO_PI);
      }
      a=a+HALF_PI;

      body.applyForce(  new Vec2(0, -100), body.getWorldCenter());
    }
  }


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