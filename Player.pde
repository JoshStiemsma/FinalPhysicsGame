class Player {

  //the players body
  Body basket;
  Box basketBox;
  boolean dead= false;
  int balloonCount = 3;
  PVector startingPosition = new PVector(500, 450);
  Vec2 startingPostionVec = new Vec2(500, 450);
  Vec2 position = new Vec2(0, 0);
  float LastTerrainUpdate = startingPostionVec.x;

  boolean invincible =false;
  float invincibleCounter = 20;





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

  Vec2 playerPrevPos = startingPostionVec;
  Vec2 prevVel;
  boolean setPrevVel = false;
  float timeSinceLastWallHit = 0;

  void update() {
    if (circles.size()==1)dead=true;
    if (!dead) {
      ApplyInput();
      ApplyLift();

      float dist = position.x-playerPrevPos.x;
      
      if (dist>0&&camera.yOffset<=0) {
        camera.xOffset+=dist;
      } else if (dist>0&&camera.yOffset>0) {
        camera.yOffset-=dist;
      } else if (dist<0) {
        camera.yOffset-=dist;
      }
      camera.position = new Vec2(startingPosition.x+camera.xOffset, position.y-startingPosition.y);
      
      playerPrevPos = position;
    }


    if (invincible) {
      invincibleCounter-=.1;
      if (invincibleCounter<=0) { 
        invincible=false;
        invincibleCounter=20;
      }
    }


    position = box2d.getBodyPixelCoord(basket);
    float a = basket.getAngle();

    Fixture f = basket.getFixtureList();
    PolygonShape ps = (PolygonShape) f.getShape();

    CheckBoundaries();
  }
  /*
*Display presents all the players bodies to the screen in thier proper position
   *IT uses the boxes and circles arrays of the players as well as the players basket box
   */
  void display() {

    position = box2d.getBodyPixelCoord(basket);
    float a = basket.getAngle();


    Fixture f = basket.getFixtureList();
    PolygonShape ps = (PolygonShape) f.getShape();


    pushStyle();
    //draw rope length for each box
    for ( int i = 0; i <boxes.size(); i++) {
      Vec2 pos = box2d.getBodyPixelCoord(boxes.get(i).body);
      float a1 = boxes.get(i).body.getAngle();
      pushMatrix();
      imageMode(CENTER);       
      translate(pos.x, pos.y);
      rotate(-a1);
      scale(.09);
      image(rope, 0, 0);

      popMatrix();

      // b.display(255);
    }
    for (int i=0; i<circles.size(); i++) {
      //draw each balloon img at circls123 position

      Vec2 pos = box2d.getBodyPixelCoord(circles.get(i).body);
      float a1 = circles.get(i).body.getAngle();
      pushMatrix();
      imageMode(CENTER);
      translate(pos.x, pos.y);
      rotate(-a1);
      scale(.04);
      if (i==circles.size()-1) {
        scale(2.5);
        image(ropeKnot, 0, 0  );
      } else if (i==0) image(ballImg01, 0, 0);
      else if (i==1) image(ballImg02, 0, 0);
      else if (i==2) image(ballImg03, 0, 0);
      popMatrix();
    }
    popStyle();



    pushStyle();


    //rectMode(CENTER);
    imageMode(CENTER);
    pushMatrix();
    translate(position.x, position.y);
    rotate(-a);
    scale(.3);
    image(basketImg, 0, 0);
    fill(255);
    textSize(75);
    text("Score:"+ score, -150, 175);//Score text
    //beginShape();
    //for (int i = 0; i < ps.getVertexCount(); i++) {
    //  Vec2 v = box2d.vectorWorldToPixels(ps.getVertex(i));
    //  vertex(v.x, v.y);
    //}
    //endShape(CLOSE);
    switch (lives) {//Switch case for lives that adds cracks to the players basket
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

  /*
   *Apply Input takes the Input class variables and applies them to the player 
   *
   */
  void ApplyInput() {

    if (in.Down) Thrust(); //Push down on the basket



    Vec2 vel = basket.getLinearVelocity();
    if (in.Left) basket.setLinearVelocity(new Vec2( vel.x-1, vel.y));//Push left
    if (in.Right) basket.setLinearVelocity(new Vec2( vel.x+1, vel.y));//Push Right

    if (basket.getAngularVelocity()!=0) {
      basket.setAngularVelocity(basket.getAngularVelocity()*.64);//Re aligns players rotation
    }
  }


  /*
*touched Ground is called every time the player hits the ground
   *For fairness, time Since Last hit must be over half a second for damage to take effect,
   *or the player can hit it too much
   *
   */
  void touchedGround() {
    println("hit ground");
    if (millis()/1000-timeSinceLastWallHit>.5) {//hit wall take away life
      lives-=1;
      timeSinceLastWallHit=millis()/1000;
    }
  }

  /*
*destroy Bodies is called when resetingt he player and ALL bodies need to be destroyed so that they are not there and invisiable in the next play
   *
   */
  void destroyBodies() {
    for (Box b : boxes) b.destroyBody();
    for (Circle c : circles) c.destroyBody();
    box2d.destroyBody(basket);
  }


  /*
*Apply Lift adds an upward thrust to the balloons and lifts the basket
   *The lift amount is blanced relative to the balloons/lives remaining to make the game play smoother
   */
  void ApplyLift() {

    for (Circle c : circles) {
      if (balloonCount==3) {
        Vec2 pos = c.body.getWorldCenter();
        c.body.applyForce(new Vec2(0, 50  ), pos);
      } else if (balloonCount==2) {
        Vec2 pos = c.body.getWorldCenter();
        c.body.applyForce(new Vec2(0, 60  ), pos);
      }else if (balloonCount==1) {
        Vec2 pos = c.body.getWorldCenter();
        c.body.applyForce(new Vec2(0, 80  ), pos);
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


  /*
*When given input to push down, Thrust is called
   *A downward force is applied to the basket to pull on everything mutualy
   */
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
    //if (pos.x>width+viewOffset||pos.y>height-viewOffset+30) player.dead=true;     //Kill Player if the go out of bounds
  }




  /*
*LoseBalloon 1 is called when the first balloon hits the ceiling and pop
   *It also removes the proper balloon from the circles array as well as the baloons chain from the boxes array
   */
  void loseBalloon1() {
    circlesToKill.add(ball1);
    // for (Box b : ball1chain) boxesToKill.add(b);
    balloonCount--;
  }
  /*
*LoseBalloon 2 is called when the first balloon hits the ceiling and pop
   *It also removes the proper balloon from the circles array as well as the baloons chain from the boxes array
   */
  void loseBalloon2() {
    circlesToKill.add(ball2);
    // for (Box b : ball2chain) boxesToKill.add(b);
    balloonCount--;
  }
  /*
*LoseBalloon 3 is called when the first balloon hits the ceiling and pop
   *It also removes the proper balloon from the circles array as well as the baloons chain from the boxes array
   */
  void loseBalloon3() {
    circlesToKill.add(ball3);
    //for (Box b : ball3chain) boxesToKill.add(b);
    balloonCount--;
  }




  ////////////////////////All body making stuff
  /*
  *Make Player Body is called when player is initiated and it runs all the functions needed to build the player
   *First BAlloons are made and added to thecircles array, next are thier chains, then the center link, and last the baskets with
   *its chains that link it to the center link
   */
  void MakePlayersBody() {
    boxes= new ArrayList<Box>();
    circles = new ArrayList<Circle>();

    ball1 = new Circle( new Vec2(startingPostionVec.x, startingPostionVec.y-100), 20, "b1");
    circles.add(ball1);
    ball2 = new Circle( new Vec2(startingPostionVec.x+30, startingPostionVec.y-100), 20, "b2");
    circles.add(ball2);
    ball3 = new Circle( new Vec2(startingPostionVec.x-30, startingPostionVec.y-100), 20, "b3");
    circles.add(ball3);


    FirstBallChain();
    SecondBallChain();
    ThirdBallChain();
    CenterLink();
    Basket();
  }


  /*
  *First ball chain creates the chain links for first balloon that will later be linked to the center link once it is created
   *
   */
  void FirstBallChain() {
    Box Link;
    for (int i=0; i<=3; i++) {
      Link = new Box(new Vec2(startingPostionVec.x, startingPostionVec.y-100+i*15), new Vec2(2, 10), false, .1);
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

  /*
  *Second ball chain creates the chain links for second balloon that will later be linked to the center link once it is created
   *
   */
  void SecondBallChain() {
    Box Link;
    for (int i=0; i<=3; i++) {
      Link = new Box(new Vec2(startingPostionVec.x+30, startingPostionVec.y-100+i*15), new Vec2(2, 10), false, .1);
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
  /*
  *Third ball chain creates the chain links for third balloon that will later be linked to the center link once it is created
   *
   */
  void ThirdBallChain() {
    Box Link;
    for (int i=0; i<=3; i++) {
      Link = new Box(new Vec2(startingPostionVec.x-30, startingPostionVec.y-100+i*15), new Vec2(2, 10), false, .1);
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
  /*
  *Center Link creates a sphere for a center link that will be a connector and cneter force piece between the balloons and the basket
   *It allows for mutual balance between the balloons regardless of how many are left and the players basket rectangle
   *The center link connets itself to the ends of the balloon strings
   */
  void CenterLink() {
    //Create Center Link box
    Circle centerl =new Circle(new Vec2(startingPostionVec.x, startingPostionVec.y-50), 7, "Link");
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
   *then it connects those ends to the center peice
   */
  void Basket() {
    //Create Basket
    Box Basket = new Box(startingPostionVec, new Vec2(50, 30), false, .1);
    basket = Basket.body;
    //Create LEft Chain
    Box Link;
    for (int i=0; i<=3; i++) {
      Link = new Box(new Vec2(startingPostionVec.x+30, startingPostionVec.y+5+i*10), new Vec2(2, 10), false, .1);
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
      Link = new Box(new Vec2(startingPostionVec.x+30, startingPostionVec.y+5+i*10), new Vec2(2, 10), false, .1);
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
