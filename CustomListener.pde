//custom listener is called when objects are colliding with each other
class CustomListener implements ContactListener {
  CustomListener() {
  }

  // This function is called when a new collision occurs
  void beginContact(Contact cp) {
    // Get both fixtures
    Fixture f1 = cp.getFixtureA();
    Fixture f2 = cp.getFixtureB();
    // Get both bodies
    Body b1 = f1.getBody();
    Body b2 = f2.getBody();
    // Get our objects that reference these bodies
    //Object obj1 = b1.getUserData();
    //Object obj2 = b2.getUserData();
    Object[] o1 = (Object[])b1.getUserData();
    Object[] o2 = (Object[])b2.getUserData();
    if (player.dead!=true) {

      if (o1[0]=="player"&&o2[0]=="ground")player.touchedGround();//if player touches ground, call touchedGround()
      if (o1[0]=="ground"&&o2[0]=="player")player.touchedGround();//if player touches ground, call touchedGround()
      if (o1[0]=="box"&&o2[0]=="ground")        b2.setUserData(new Object[]{"box", "dead", "offChain"});//if box touches ground, flag as dead
      if (o1[0]=="ground"&&o2[0]=="box")        b2.setUserData(new Object[]{"box", "dead", "offChain"});//if box touches ground, flag as dead

      //if a box is on the players chians for a while then flag it as onchain to be deleted smoothly
      if (o1[0]=="chain"&&o2[0]=="box") {
        b2.setUserData(new Object[]{"box", o2[1], "onChain"});
      } else if (o1[0]=="box"&&o2[0]=="chain") {
        b1.setUserData(new Object[]{"box", o1[1], "onChain"});
      }


      if (o1[0]=="weight") {//if the first object is th wieght
        if (o2[0]=="box") {//and the second is a box
          Vec2 vel = b1.getLinearVelocity();//grab weight velocity
          if (mag(vel.x, vel.y)>25||player.invincible) b2.setUserData(new Object[]{"box", "deadByPlayer", "offChain" });//if the weight hit with a big enoguh celocity then flag box as dead by player
        } else if (o2[0]=="life") {//if weight hit a life pickup
          if (lives<3)lives+=1;//add to  players lives
          b2.setUserData(new Object[]{"life", "dead"});//Collect pickup
        } else if (o2[0]=="token"&&o2[1]=="alive") {//if weight hit a token pickup
          pointsPickedUp+=10;//add ten points tp palyer score
          b2.setUserData(new Object[]{"token", "dead"});//Collect pickup
        } else if (o2[0]=="invincible"&&o2[1]=="alive") {//if weight hit a invincibel pickup
          player.invincible=true;//set palyer to invin
          b2.setUserData(new Object[]{"invincible", "dead"});//Collect pickup
        }
      }//end if first object is weight

      if (o1[0]=="token"&&o2[0]=="player"&&o1[1]=="alive") {//if palyer hit token and token was first object
        pointsPickedUp+=10;//add to points
        b2.setUserData(new Object[]{"token", "dead"});//Collect pickup
      }
      if (o1[0]=="invincible"&&o2[0]=="player"&&o1[1]=="alive") {//if invin pickup hit player
        player.invincible=true;//set player to invin
        b2.setUserData(new Object[]{"invincible", "dead"});//Collect pickup
      }

      if (o1[0]=="life"&&o2[0]=="player"&&o1[1]=="alive") {//if life pickup hit player
        if (lives<3)lives+=1;//add to lives
        b2.setUserData(new Object[]{"life", "dead"});//Collect pickup
      }
      //////PRetty sure this is redundent but no need to break anything now
      if (o2[0]=="player"&&o1[1]=="alive") {
        if (o1[0]=="token") {
          pointsPickedUp+=10;
          b2.setUserData(new Object[]{"token", "dead"});//Collect pickup
        }
        if (o1[0]=="invincible") {
          player.invincible=true;
          b2.setUserData(new Object[]{"invincible", "dead"});//Collect pickup
        }
        if (o1[0]=="life") {
          if (lives<3)lives+=1;
          b2.setUserData(new Object[]{"life", "dead"});//Collect pickup
        }
      }

      //if first object is player
      if (o1[0]=="player") {
        //and second object is box
        if (o2[0]=="box") {//Explode Box if players velocity is over a limit
          Vec2 vel =b1.getLinearVelocity();//grab palyer elocity
          if (mag(vel.x, vel.y)>50&&!player.invincible) {//if player was going fast enough, break box
            b2.setUserData(new Object[]{"box", "deadByPlayer", "offChain"});//set box to dead by player
            player.prevVel = player.basket.getLinearVelocity();//set player velocity to not be effected by breaking the box
            player.setPrevVel=true;/
            set prev vel boolean to true to do that
              player.touchedGround();//also damage player for big hit
          }
        } else if (o2[0]=="life") {//if basket/player hits a life
          if (lives<3)lives+=1;//add life
          b2.setUserData(new Object[]{"life", "dead"});//Collect pickup
        } else if (o2[0]=="token"&&o2[1]=="alive") {//if basket/player hits a token
          pointsPickedUp+=10;//add to piints
          b2.setUserData(new Object[]{"token", "dead"});//Collect pickup
        } else if (o2[0]=="invincible"&&o2[1]=="alive") {//if basket/player hits a invin
          player.invincible=true;//set player to invin
          b2.setUserData(new Object[]{"invincible", "dead"});//Collect pickup
        }
      }//END if first obj is PLAYER

      //if any of the balloons hit the ground/ceiling the call the function that kills it
      if (o2[0]=="b1") if (o1[0]=="ground")player.loseBalloon1();
      if (o2[0]=="b2") if (o1[0]=="ground")player.loseBalloon2();
      if (o2[0]=="b3") if (o1[0]=="ground")player.loseBalloon3();
      if (o2[0]=="ground") if (o1[0]=="b1")player.loseBalloon1();
      if (o2[0]=="ground") if (o1[0]=="b2")player.loseBalloon2();
      if (o2[0]=="ground") if (o1[0]=="b3")player.loseBalloon3();
    }
  }//End if player is alive

  void endContact(Contact contact) {
    // TODO Auto-generated method stub
  }

  void preSolve(Contact contact, Manifold oldManifold) {
    // TODO Auto-generated method stub
  }

  void postSolve(Contact contact, ContactImpulse impulse) {
    // TODO Auto-generated method stub
  }
}