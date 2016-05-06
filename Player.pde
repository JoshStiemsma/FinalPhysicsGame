class Player {

  //the players basket and weight body
  Body basket;
  Box basketBox;
  Body weight;
  Box weightBox;

  Circle CenterLinkCircle;//the cirlce class object connecting chains from balloons to chains on basket

  int weightAmount = 1;//variable representing increasing weight on player

  boolean dead= false;//boolean for if player is dead or not
  int balloonCount = 3;//balloon count of player, when 0 player is dead

  boolean ball1Alive = true;//boolean for if balloon1 is alive
  boolean ball2Alive = true;//boolean for if ball2 is alive
  boolean ball3Alive = true;//boolean for if ball3 is alive

  PVector startingPosition = new PVector(500, 500);//starting positiong PVector
  Vec2 startingPostionVec = new Vec2(500, 500);//starting position Vec2
  Vec2 position = new Vec2(0, 0);//current position Vec2
  float LastTerrainUpdate = startingPostionVec.x;//last terrain update float related to players x axis progression

  boolean invincible =false;//invin boolean
  float invincibleCounter = 20;//invin counter, starts at 20


  float alphaFade =00;//alpha fade varaible for invin tin starts at 0
  float finalDistance =0;//final player distance 
  boolean finalSet =false;//boolean flagging if final has been set

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
  Circle centerLink;

  //Array lists used to hold chains on the players balls
  ArrayList<Box>ball1chain = new ArrayList<Box>();
  ArrayList<Box>ball2chain = new ArrayList<Box>();
  ArrayList<Box>ball3chain = new ArrayList<Box>();


  //arraylist of boxes that the player, including chain boxes
  ArrayList<Box>boxes = new ArrayList<Box>();
  ArrayList<Circle> circles = new ArrayList<Circle>();//players circles araylist
  ArrayList<Box>boxesToKill = new ArrayList<Box>();//players boxes to kill array list
  ArrayList<Circle> circlesToKill = new ArrayList<Circle>();//player circles to kill array list


  //Constructor
  Player() {
    MakePlayersBody();//make the palyer
    basket.setUserData(new Object[]{"player", "alive"});//set the weight user data
    weight.setUserData(new Object[]{"weight", "alive"});//set the baskets user data
  }

  Vec2 playerPrevPos = startingPostionVec;//set the previouse position to start position at start
  Vec2 prevVel;//make a Vec2 for previose Velocity
  boolean setPrevVel = false;//boolean for if player needs to be set to last frames velocity
  float timeSinceLastWallHit = 0;//Time since last wall hit, to make hits not happen every single frame and too fast
  /*
*the function udpate is called every frame within the main update function and handles all the palyer physics update 
   *
   */
  void update() {
    weightAmount =int((millis()/1000-timeSinceLastStart)/10)+1;//add the the number on the weight object to show increaseing weight

    updateWeight();//also update the actual weight being pplied to the palyer

    if (circles.size()==1)dead=true;//if only the center link cirlce is left the all balloons have popped
    if (!dead) {//if player is not dead
      ApplyInput();//apply user input
      ApplyLift();//apply balloon lift
      float dist = position.x-playerPrevPos.x;//see how much ground the player had moved since last checked
      if (dist>0&&camera.yOffset<=0) {//if palyer has made posative Xaxis movement
        camera.xOffset+=dist;//add that to the caera
        score = int(millis()/1000-timeSinceLastStart)+pointsPickedUp;//add tot he score
      } else if (dist>0&&camera.yOffset>0) {//if palyer has moved left
        camera.yOffset-=dist;//track that amount
      } else if (dist<0) {
        camera.yOffset-=dist;
      }
      camera.position = new Vec2(startingPosition.x+camera.xOffset, position.y-startingPosition.y);//set camera position

      playerPrevPos = position;//set previose positono
    }


    if (invincible) {//if invincible 
      invincibleCounter-=.1;//subtract from invin count down
      if (invincibleCounter<=0) { //if reached 0 on couner
        invincible=false;//no more invin
        invincibleCounter=20;//reset invin amount for enxt time
      }
    }


    position = box2d.getBodyPixelCoord(basket);//grab and set position of basket


    CheckBoundaries();//chck bounds
  }
  /*
*Display presents all the players bodies to the screen in thier proper position
   *IT uses the boxes and circles arrays of the players as well as the players basket box
   */
  void display() {

    position = box2d.getBodyPixelCoord(basket);//grab posiiton in physics world
    float a = basket.getAngle();//grab angle



    pushStyle();
    //draw rope length for each box
    for ( int i = 0; i <boxes.size(); i++) {
      Vec2 pos = box2d.getBodyPixelCoord(boxes.get(i).body);
      float a1 = boxes.get(i).body.getAngle();
      pushMatrix();//enter the matrix neo
      imageMode(CENTER);  //center image     
      translate(pos.x, pos.y);//transsalte by possition
      rotate(-a1);//rotate
      scale(.09);//scale down
      image(rope, 0, 0);//draw this rope segment
      popMatrix();//leave matrix
    }
    popStyle();


    pushStyle();
    if (ball1Alive&&ball1.body!=null) {//if balloon 1 is alive then draw it in it matrix
      Vec2 ball ;
      ball = box2d.getBodyPixelCoord(ball1.body);     

      float ball1a = ball1.body.getAngle();
      pushMatrix();
      imageMode(CENTER);
      translate(ball.x, ball.y);
      rotate(-ball1a);
      scale(.04);
      image(ballImg02, 0, 0);
      popMatrix();
    }
    if (ball2Alive &&ball2.body!=null) {//if ball 2 is alive then grab its pos and draw it in its matrix
      Vec2 ball = box2d.getBodyPixelCoord(ball2.body);

      float ball1a = ball2.body.getAngle();
      pushMatrix();
      imageMode(CENTER);
      translate(ball.x, ball.y);
      rotate(-ball1a);
      scale(.04);
      image(ballImg01, 0, 0);
      popMatrix();
    }
    if (ball3Alive &&ball3.body!=null) {//iff balloon 3 is alive then grab its stuff and draw it in its matrix
      Vec2 ball1 = box2d.getBodyPixelCoord(ball3.body);
      float ball1a = ball3.body.getAngle();
      pushMatrix();
      imageMode(CENTER);
      translate(ball1.x, ball1.y);
      rotate(-ball1a);
      scale(.04);
      image(ballImg03, 0, 0);
      popMatrix();
    }
    Vec2 pos;
    float a1;

    pos = box2d.getBodyPixelCoord(centerLink.body);//grab centerlink position and rotation
    a1 = centerLink.body.getAngle();

    pushMatrix();//enter the matrix neo
    imageMode(CENTER);
    translate(pos.x, pos.y);
    rotate(-a1);
    scale(.04);

    scale(2.5);
    image(ropeKnot, 0, 0  );//Draw center link as rope knot
    popMatrix();//leave the matrix neo
    popStyle();



    pushStyle();


    imageMode(CENTER);
    pushMatrix();//enter the matrix neo
    translate(position.x, position.y);
    rotate(-a);
    scale(.3);
    if (player.invincible==true) {
      switch (lives) {//Switch case for lives that adds cracks to the players basket
      case 3:
        image(basketImg01, 0, 0);
        tint(0, 0, 255, map(invincibleCounter, 20, 0, 255, 0));
        image(basketImg01, 0, 0);

        break;
      case 2:
        image(basketImg02, 0, 0);
        tint(0, 0, 255, map(invincibleCounter, 20, 0, 255, 0));
        image(basketImg02, 0, 0);       
        break;
      case 1:
        image(basketImg03, 0, 0);
        tint(0, 0, 255, map(invincibleCounter, 20, 0, 255, 0));
        image(basketImg03, 0, 0);
        break;
      }
    } else {
      switch (lives) {//Switch case for lives that adds cracks to the players basket
      case 3:
        image(basketImg01, 0, 0);
        break;
      case 2:
        image(basketImg02, 0, 0);
        break;
      case 1:
        image(basketImg03, 0, 0);
        break;
      }
    }


    popMatrix();


    imageMode(CENTER);
    position = box2d.getBodyPixelCoord(weight);
    a = weight.getAngle();

    pushMatrix();
    translate(position.x, position.y );
    rotate(-a);
    scale(.05);
    tint(255);
    image(weightImg, 0, 0);
    if (player.invincible)tint(0, 0, 255, map(invincibleCounter, 20, 0, 255, 25));
    else tint(255);
    image(weightImg, 0, 0);
    popMatrix();
    popStyle();




    pushStyle();
    pushMatrix();
    fill(255);
    imageMode(CENTER);
    translate(position.x, position.y );

    rotate(-a);
    scale(.2);
    textFont(bubble);
    if (dead)text(weightAmount + "lb", 5, 20);
    else  text(weightAmount + "lb", -30, 20);
    popMatrix();
    popStyle();
  }//end display

  /*
   *Apply Input takes the Input class variables and applies them to the player 
   *
   */
  void ApplyInput() {

    if (in.Down || pedal.getValue() >= .5) Thrust(); //Push down on the basket



    Vec2 vel = basket.getLinearVelocity();
    if (in.Right || bttnA.pressed()) basket.setLinearVelocity(new Vec2( vel.x + bttnA.getValue()/2, vel.y));//Push left
    if (in.Left || bttnB.pressed()) basket.setLinearVelocity(new Vec2( vel.x - bttnB.getValue()/2, vel.y));//Push Right
    if (bttnX.pressed()) basket.setLinearVelocity(new Vec2( vel.x + bttnX.getValue()/2, vel.y - bttnA.getValue()/2));//Push left
    if (bttnY.pressed()) basket.setLinearVelocity(new Vec2( vel.x - bttnY.getValue()/2, vel.y - bttnA.getValue()/2));//Push Right

    if (basket.getAngularVelocity()!=0) {
      basket.setAngularVelocity(basket.getAngularVelocity()*.64);//Re aligns players rotation
    }
  }
/*
*the functio update weight adds to the density of the player wight as they progress to make the game increasingly hard
*
*/
  void updateWeight() {
    Fixture f =weight.getFixtureList();
    float value = constrain(map(millis()/1000-timeSinceLastStart, 0, 500, .1, .5), .1, .5);
    f.setDensity(value);
    weight.resetMassData();
  }


  /*
*touched Ground is called every time the player hits the ground
   *For fairness, time Since Last hit must be over half a second for damage to take effect,
   *or the player can hit it too much
   *
   */
  void touchedGround() {
    //println("hit ground");
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
    //ball1.destroyBody();
    //ball2.destroyBody();
    //ball3.destroyBody();
    //centerLink.destroyBody();
    if (basket!=null)box2d.destroyBody(basket);
    if (weight!=null)box2d.destroyBody(weight);
  }


  /*
*Apply Lift adds an upward thrust to the balloons and lifts the basket
   *The lift amount is blanced relative to the balloons/lives remaining to make the game play smoother
   */
  void ApplyLift() {


    for (Circle c : circles) {//for each circle apply lift
      if (balloonCount==3) {
        Vec2 pos = c.body.getWorldCenter();
        c.body.applyForce(new Vec2(0, 130  ), pos);
      } else if (balloonCount==2) {
        Vec2 pos = c.body.getWorldCenter();
        c.body.applyForce(new Vec2(0, 150  ), pos);
      } else if (balloonCount==1) {
        Vec2 pos = c.body.getWorldCenter();
        c.body.applyForce(new Vec2(0, 170  ), pos);
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
    basket.applyForce(new Vec2(0, -500), pos);
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
*this function sets the final score of the player based on distance only one
*
*/
  void setFinal() {
    if (!finalSet) {
      finalDistance = int(camera.xOffset+500+pointsPickedUp/100);
      finalSet=true;
    }
  }

  /*

   *LoseBalloon 1 is called when the first balloon hits the ceiling and pop
   *It also removes the proper balloon from the circles array as well as the baloons chain from the boxes array
   */
  void loseBalloon1() {
    if (ball1Alive) {
      //println("deleteball1");
      ball1Alive=false;
      circlesToKill.add(ball1);
      pop01.play();
      pop01.amp(.5);
    }
  }
  /*
*LoseBalloon 2 is called when the first balloon hits the ceiling and pop
   *It also removes the proper balloon from the circles array as well as the baloons chain from the boxes array
   */
  void loseBalloon2() {
    if (ball2Alive) {
      circlesToKill.add(ball2);
      //println("deleteball2");
      ball2Alive=false;
      pop02.play();
      pop02.amp(.5);
    }
  }
  /*
*LoseBalloon 3 is called when the first balloon hits the ceiling and pop
   *It also removes the proper balloon from the circles array as well as the baloons chain from the boxes array
   */
  void loseBalloon3() {
    if (ball3Alive) {
      circlesToKill.add(ball3);
      //println("deleteball3");
      ball3Alive=false;
      pop03.play();
      pop03.amp(.5);
    }
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
    //make the balloons and add them to circles arrayList
    ball1 = new Circle( new Vec2(startingPostionVec.x, startingPostionVec.y-100), 20, "b1");
    circles.add(ball1);
    ball2 = new Circle( new Vec2(startingPostionVec.x+30, startingPostionVec.y-100), 20, "b2");
    circles.add(ball2);
    ball3 = new Circle( new Vec2(startingPostionVec.x-30, startingPostionVec.y-100), 20, "b3");
    circles.add(ball3);

  
    FirstBallChain();//add first chain
    SecondBallChain();//add second chain
    ThirdBallChain();//add third chain
    CenterLink();//add and attach chains to centerlink
    Basket();//add the bakset and then weight
  }


  /*
  *First ball chain creates the chain links for first balloon that will later be linked to the center link once it is created
   *
   */
  void FirstBallChain() {
    Box Link;
    for (int i=0; i<=3; i++) {
      Link = new Box(new Vec2(startingPostionVec.x, startingPostionVec.y-75+i*15), new Vec2(2, 10), false, .9, true);
      Link.body.setUserData(new Object[]{"chain", "alive", "offChain"});//set the Links user data to box that is alive
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
      Link = new Box(new Vec2(startingPostionVec.x+30, startingPostionVec.y-75+i*15), new Vec2(2, 10), false, .9, true);
      Link.body.setUserData(new Object[]{"chain", "alive", "offChain"});//set the Links user data to box that is alive
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
      Link = new Box(new Vec2(startingPostionVec.x-30, startingPostionVec.y-75+i*15), new Vec2(2, 10), false, .9, true);
      Link.body.setUserData(new Object[]{"chain", "alive", "offChain"});//set the Links user data to box that is alive
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
    Circle centerl =new Circle(new Vec2(startingPostionVec.x, startingPostionVec.y-40), 10, "Link");
    //centerl.body.setUserData(new Object[]{"chain", "alive"});//set the Links user data to box that is alive
    circles.add(centerl);
    centerLink = centerl;
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
    Box Basket = new Box(startingPostionVec, new Vec2(50, 30), false, .1, true);
    basket = Basket.body;
    //Create LEft Chain
    Box Link;
    for (int i=0; i<=3; i++) {
      Link = new Box(new Vec2(startingPostionVec.x+30, startingPostionVec.y+(i+1)*15), new Vec2(2, 10), false, .9, true);
      Link.body.setUserData(new Object[]{"chain", "alive", "offChain"});//set the Links user data to box that is alive
      boxes.add(Link);
      RevoluteJointDef rjd = new RevoluteJointDef();
      if (i==0) rjd.bodyA= centerLink.body;
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
    rjd.localAnchorA.set(2.5, 2);
    rjd.localAnchorB.set(0, .3);
    RevoluteJoint dj = (RevoluteJoint) box2d.world.createJoint(rjd);

    //Create Right Chain
    for (int i=0; i<=3; i++) {
      Link = new Box(new Vec2(startingPostionVec.x+30, startingPostionVec.y+5+i*20), new Vec2(2, 10), false, .9, true);
      Link.body.setUserData(new Object[]{"chain", "alive", "offChain"});//set the Links user data to box that is alive
      boxes.add(Link);
      RevoluteJointDef rjd2 = new RevoluteJointDef();
      if (i==0) rjd2.bodyA= centerLink.body;
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
    rjd2.localAnchorA.set(-2.5, 2);
    rjd2.localAnchorB.set(0, .3);
    RevoluteJoint dj2 = (RevoluteJoint) box2d.world.createJoint(rjd2);




    //create weight
    Box Weight = new Box(new Vec2(startingPostionVec.x, startingPostionVec.y+150), new Vec2(40, 25), false, .2, true);
    weight = Weight.body;
    //attach to basket with chain

    for (int i=0; i<=1; i++) {
      Link = new Box(new Vec2(startingPostionVec.x, startingPostionVec.y-10*(i+1)), new Vec2(2, 10), false, .9, true);
      Link.body.setUserData(new Object[]{"chain", "alive", "offChain"});//set the Links user data to box that is alive
      boxes.add(Link);
      rjd = new RevoluteJointDef();
      if (i==0) rjd.bodyA= basket;
      else rjd.bodyA=previouse;
      rjd.bodyB = Link.body;
      rjd.collideConnected=false;
      if (i==0)  rjd.localAnchorA.set(0, -1.7);
      else rjd.localAnchorA.set(0, -.3);
      rjd.localAnchorB.set(0, 1);
      //rjd.dampingRatio = 0.5;
      dj = (RevoluteJoint) box2d.world.createJoint(rjd);
      previouse = Link.body;
    }
    //Create  Chain Joint to weight
    rjd2 = new RevoluteJointDef();
    rjd2.bodyA= weight;
    rjd2.bodyB = previouse;
    rjd2.collideConnected=false;
    rjd2.localAnchorA.set(0, 2);
    rjd2.localAnchorB.set(0, .3);
    dj2 = (RevoluteJoint) box2d.world.createJoint(rjd2);
  }//end make player Basket
}