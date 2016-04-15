class Player {

  //the players body
  Body basket;
  Box basketBox;
  boolean dead= false;
  int balloonCount = 3;
  Vec2 position;

  //These are used for storing relative data when making the body and linking joints
  Circle ball1;
  Circle ball2;
  Circle ball3;
  Body previouse;
  Body ballStringEnd1;
  Body ballStringEnd2;
  Body ballStringEnd3;
  Body ropeEnd1;
  Body ropeEnd2;
  Body centerLink;
  ArrayList<Box>ball1chain = new ArrayList<Box>();
  ArrayList<Box>ball2chain = new ArrayList<Box>();
  ArrayList<Box>ball3chain = new ArrayList<Box>();



  ArrayList<Box>boxes = new ArrayList<Box>();
  ArrayList<Circle> circles = new ArrayList<Circle>();
  ArrayList<Box>boxesToKill = new ArrayList<Box>();
  ArrayList<Circle> circlesToKill = new ArrayList<Circle>();


  //Constructor
  Player() {
    MakePlayersBody();
    //platforms.add(new Platform(startingPosition.x-30, startingPosition.y));
    basket.setUserData(new Object[]{"player", "alive"});
  }

  PVector startingPosition = new PVector(500, 450);
  Vec2 spv = new Vec2(500, 450);
  Vec2 prevVel;
  boolean setPrevVel = false;
  float timeSinceLastWallHit = 0;

  void display() {
    if (!dead) {
      ApplyInput();
      ApplyLift();
    }




    position = box2d.getBodyPixelCoord(basket);
    float a = basket.getAngle();

    Fixture f = basket.getFixtureList();
    PolygonShape ps = (PolygonShape) f.getShape();

    CheckBoundaries();
    pushStyle();
    for (Box b : boxes) b.display(125);
    for (int i=0; i<circles.size(); i++) {
      if (i<3)  circles.get(i).display(color(255, 0, 0));
      else circles.get(i).display(125);
    }

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
    switch (lives) {
    case 3:
      break;
    case 2:

      line(25, 15, 15, 8);
      line(15, 8, 10, 10);
      line(10, 10, 7, 8);
      line(15, 8, 3, 5);
      line(3, 5, -2, -3);
      line(3, 5, -2, 5);
      line(15, 8, 20, 5);
      line(20, 5, 18, -2);

      break;
    case 1:

      line(25, 15, 15, 8);
      line(15, 8, 10, 10);
      line(10, 10, 7, 8);
      line(7, 8, 10, 3);
      line(15, 8, 3, 5);
      line(3, 5, -2, -3);
      line(-2, -3, -10, -12);
      line(3, 5, -2, 5);
      line(-2, 5, -5, 7);
      line(15, 8, 20, 5);
      line(20, 5, 18, -2);
      line(20, 5, 15, -5);
      line(18, -2, 23, 2);
      break;
    }


    popMatrix();
    popStyle();
  }//end display

  void touchedGround() {
    println("hit ground");
    if (millis()/1000-timeSinceLastWallHit>.5) {//hit wall take away life
      lives-=1;
      timeSinceLastWallHit=millis()/1000;
    }
  }


  void destroyBodies() {
    for (Box b : boxes) b.destroyBody();
    for (Circle c : circles) c.destroyBody();
    box2d.destroyBody(basket);
  }

  void reset() {
    lives=3;
    //platforms.add(new Platform(startingPosition.x-30, startingPosition.y));
    basket.setLinearVelocity(new Vec2(0, 0));
    basket.setTransform(box2d.coordPixelsToWorld(startingPosition), float(0));
    dead=false;
  }

  void ApplyLift() {

    for (Circle c : circles) {
      if (balloonCount==3) {
        Vec2 pos = c.body.getWorldCenter();
        c.body.applyForce(new Vec2(0, 40  ), pos);
      } else if (balloonCount==2) {
        Vec2 pos = c.body.getWorldCenter();
        c.body.applyForce(new Vec2(0, 50  ), pos);
      }
      if (balloonCount==1) {
        Vec2 pos = c.body.getWorldCenter();
        c.body.applyForce(new Vec2(0, 60  ), pos);
      }
    }
  }
  void ApplyInput() {
    if (in.Down) Thrust(); 
    Vec2 vel = basket.getLinearVelocity();
    if (in.Left) basket.setLinearVelocity(new Vec2( vel.x-1, vel.y));
    if (in.Right) basket.setLinearVelocity(new Vec2( vel.x+1, vel.y));

    //println(body.getAngularVelocity());
    if (basket.getAngularVelocity()!=0) {
      basket.setAngularVelocity(basket.getAngularVelocity()*.64);
    }
    if (in.Space)  Push();
  }


  void Push() {
    //println("push");
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
    Vec2 pos = basket.getWorldCenter();
    basket.applyForce(force, pos);
  }//end apply force

  void Thrust() {

    Vec2 pos = basket.getWorldCenter();
    basket.applyForce(new Vec2(0, -200), pos);
  }


  /*
*This functions collects the players position relative to the screen,
   *And kills the player if they go too far out of view
   */
  void CheckBoundaries() {
    Vec2 pos =  box2d.getBodyPixelCoord(basket);
    if (pos.x>width+viewOffset||pos.y>height-viewOffset+30) player.dead=true;     //Kill Player if the go out of bounds
  }





  void loseBalloon1() {
    println("kill1");
    circlesToKill.add(ball1);
    for (Box b : ball1chain) boxesToKill.add(b);
    balloonCount--;
  }
  void loseBalloon2() {
    println("kill2");
    circlesToKill.add(ball2);
    for (Box b : ball2chain) boxesToKill.add(b);
    balloonCount--;
  }
  void loseBalloon3() {
    println("kill3");
    circlesToKill.add(ball3);
    for (Box b : ball3chain) boxesToKill.add(b);
    balloonCount--;
  }




  ////////////////////////All body making stuff
  void MakePlayersBody() {
    boxes= new ArrayList<Box>();
    circles = new ArrayList<Circle>();
    ball1 = new Circle( new Vec2(spv.x, spv.y-100), 20, "b1");
    circles.add(ball1);
    ball2 = new Circle( new Vec2(spv.x+30, spv.y-100), 20, "b2");
    circles.add(ball2);
    ball3 = new Circle( new Vec2(spv.x-30, spv.y-100), 20, "b3");
    circles.add(ball3);


    FirstBall();
    SecondBall();
    ThirdBall();
    CenterLink();
    Basket();
  }
  void FirstBall() {
    Box Link;
    for (int i=0; i<=3; i++) {
      Link = new Box(new Vec2(spv.x, spv.y-100+i*15), new Vec2(2, 10), false, .1);
      boxes.add(Link);
      ball1chain.add(Link);
      RevoluteJointDef rjd = new RevoluteJointDef();

      if (i==0) rjd.bodyA= ball1.body;
      else rjd.bodyA=previouse;
      rjd.bodyB = Link.body;
      rjd.collideConnected=false;
      if (i==0)  rjd.localAnchorA.set(0, -2);
      else rjd.localAnchorA.set(0, -.3);
      rjd.localAnchorB.set(0, 1);
      RevoluteJoint dj = (RevoluteJoint) box2d.world.createJoint(rjd);

      previouse = Link.body;
      if (i==3)    ballStringEnd1 = Link.body;
    }
  }//Close FisrtBall
  void SecondBall() {
    Box Link;
    for (int i=0; i<=3; i++) {
      Link = new Box(new Vec2(spv.x+30, spv.y-100+i*15), new Vec2(2, 10), false, .1);
      boxes.add(Link);
      ball2chain.add(Link);
      RevoluteJointDef rjd = new RevoluteJointDef();

      if (i==0) rjd.bodyA= ball2.body;
      else rjd.bodyA=previouse;
      rjd.bodyB = Link.body;
      rjd.collideConnected=false;
      if (i==0)  rjd.localAnchorA.set(0, -2);
      else rjd.localAnchorA.set(0, -.3);
      rjd.localAnchorB.set(0, 1);
      RevoluteJoint dj = (RevoluteJoint) box2d.world.createJoint(rjd);

      previouse = Link.body;
      if (i==3)    ballStringEnd2 = Link.body;
    }
  }
  void ThirdBall() {
    Box Link;
    for (int i=0; i<=3; i++) {
      Link = new Box(new Vec2(spv.x-30, spv.y-100+i*15), new Vec2(2, 10), false, .1);
      boxes.add(Link);
      ball3chain.add(Link);
      RevoluteJointDef rjd = new RevoluteJointDef();

      if (i==0) rjd.bodyA= ball3.body;
      else rjd.bodyA=previouse;
      rjd.bodyB = Link.body;
      rjd.collideConnected=false;
      if (i==0)  rjd.localAnchorA.set(0, -2);
      else rjd.localAnchorA.set(0, -.3);
      rjd.localAnchorB.set(0, 1);
      RevoluteJoint dj = (RevoluteJoint) box2d.world.createJoint(rjd);

      previouse = Link.body;
      if (i==3)    ballStringEnd3 = Link.body;
    }
  }
  void CenterLink() {
    //Create Center Link box
    Circle centerl =new Circle(new Vec2(spv.x, spv.y-50), 7, "Link");
    circles.add(centerl);
    centerLink = centerl.body;
    //Link Center Link to last chain linkA
    RevoluteJointDef rjd2 = new RevoluteJointDef();
    rjd2.bodyA= centerl.body;
    rjd2.bodyB = ballStringEnd3;
    rjd2.collideConnected=false;
    rjd2.localAnchorA.set(-1, .5);
    rjd2.localAnchorB.set(0, -.4);
    RevoluteJoint dj2 = (RevoluteJoint) box2d.world.createJoint(rjd2);

    //Link center link to last chain linkB
    RevoluteJointDef rjd1 = new RevoluteJointDef();
    rjd1.bodyA= centerl.body;
    rjd1.bodyB = ballStringEnd1;
    rjd1.collideConnected=false;
    rjd1.localAnchorA.set(0, 1);
    rjd1.localAnchorB.set(0, -.4);
    RevoluteJoint dj1 = (RevoluteJoint) box2d.world.createJoint(rjd1);
    //Link center link to last chain link c
    RevoluteJointDef rjd3 = new RevoluteJointDef();
    rjd3.bodyA= centerl.body;
    rjd3.bodyB = ballStringEnd2;
    rjd3.collideConnected=false;
    rjd3.localAnchorA.set(1, .5);
    rjd3.localAnchorB.set(0, -.4);
    RevoluteJoint dj3 = (RevoluteJoint) box2d.world.createJoint(rjd3);
  }



  /*
*This Function creates the Box2d Basket for the player
   *As well as the two chains that connect it to the center link piece
   */
  void Basket() {
    //Create Basket
    Box Basket = new Box(spv, new Vec2(50, 30), false, .1);
    basket = Basket.body;
    //Create LEft Chain
    Box Link;
    for (int i=0; i<=3; i++) {
      Link = new Box(new Vec2(spv.x+30, spv.y+5+i*10), new Vec2(2, 10), false, .1);
      boxes.add(Link);
      RevoluteJointDef rjd = new RevoluteJointDef();
      if (i==0) rjd.bodyA= centerLink;
      else rjd.bodyA=previouse;
      rjd.bodyB = Link.body;
      rjd.collideConnected=false;
      if (i==0)  rjd.localAnchorA.set(0, -.5);
      else rjd.localAnchorA.set(0, -.3);
      rjd.localAnchorB.set(0, 1);
      RevoluteJoint dj = (RevoluteJoint) box2d.world.createJoint(rjd);
      previouse = Link.body;
    }
    //Create LEft Chain Joint
    RevoluteJointDef rjd = new RevoluteJointDef();
    rjd.bodyA= basket;
    rjd.bodyB = previouse;
    rjd.collideConnected=false;
    rjd.localAnchorA.set(2.5, 1);
    rjd.localAnchorB.set(0, .3);
    RevoluteJoint dj = (RevoluteJoint) box2d.world.createJoint(rjd);

    //Create Right Chain
    for (int i=0; i<=3; i++) {
      Link = new Box(new Vec2(spv.x+30, spv.y+5+i*10), new Vec2(2, 10), false, .1);
      boxes.add(Link);
      RevoluteJointDef rjd2 = new RevoluteJointDef();
      if (i==0) rjd2.bodyA= centerLink;
      else rjd2.bodyA=previouse;
      rjd2.bodyB = Link.body;
      rjd2.collideConnected=false;
      if (i==0)  rjd2.localAnchorA.set(0, -.5);
      else rjd2.localAnchorA.set(0, -.3);
      rjd2.localAnchorB.set(0, 1);
      RevoluteJoint dj2 = (RevoluteJoint) box2d.world.createJoint(rjd2);
      previouse = Link.body;
    }
    //Create Right Chain Joint
    RevoluteJointDef rjd2 = new RevoluteJointDef();
    rjd2.bodyA= basket;
    rjd2.bodyB = previouse;
    rjd2.collideConnected=false;
    rjd2.localAnchorA.set(-2.5, 1);
    rjd2.localAnchorB.set(0, .3);
    RevoluteJoint dj2 = (RevoluteJoint) box2d.world.createJoint(rjd2);
  }//end make player Basket
}