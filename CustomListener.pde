
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

      if (o1[0]=="player"&&o2[0]=="ground")player.touchedGround();
      if (o1[0]=="ground"&&o2[0]=="player")player.touchedGround();
      if (o1[0]=="box"&&o2[0]=="ground")        b2.setUserData(new Object[]{"box", "dead"});
      if (o1[0]=="ground"&&o2[0]=="box")        b2.setUserData(new Object[]{"box", "dead"});


      if (o1[0]=="weight") {
        if (o2[0]=="box") {
          Vec2 vel = b1.getLinearVelocity();
          if (mag(vel.x, vel.y)>25||player.invincible) b2.setUserData(new Object[]{"box", "deadByPlayer"});
        } else if (o2[0]=="life") {
          if (lives<3)lives+=1;
          b2.setUserData(new Object[]{"life", "dead"});//Collect pickup
        } else if (o2[0]=="token"&&o2[1]=="alive") {
          pointsPickedUp+=10;
          b2.setUserData(new Object[]{"token", "dead"});//Collect pickup
        } else if (o2[0]=="invincible"&&o2[1]=="alive") {
          player.invincible=true;
          b2.setUserData(new Object[]{"invincible", "dead"});//Collect pickup
        }
      }

      if (o1[0]=="token"&&o2[0]=="player"&&o1[1]=="alive") {
        pointsPickedUp+=10;
        b2.setUserData(new Object[]{"token", "dead"});//Collect pickup
      }
      if (o1[0]=="invincible"&&o2[0]=="player"&&o1[1]=="alive") {
        player.invincible=true;
        b2.setUserData(new Object[]{"invincible", "dead"});//Collect pickup
      }

      if (o1[0]=="life"&&o2[0]=="player"&&o1[1]=="alive") {
        if (lives<3)lives+=1;
        b2.setUserData(new Object[]{"life", "dead"});//Collect pickup
      }

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
      if (o1[0]=="player") {

        if (o2[0]=="box") {//Explode Box if players velocity is over a limit
          Vec2 vel =b1.getLinearVelocity();
          if (mag(vel.x, vel.y)>50&&!player.invincible) {
            b2.setUserData(new Object[]{"box", "deadByPlayer"});
            player.prevVel = player.basket.getLinearVelocity();
            player.setPrevVel=true;
            player.touchedGround();
          }
        } else if (o2[0]=="life") {
          if (lives<3)lives+=1;
          b2.setUserData(new Object[]{"life", "dead"});//Collect pickup
        } else if (o2[0]=="token"&&o2[1]=="alive") {
          pointsPickedUp+=10;
          b2.setUserData(new Object[]{"token", "dead"});//Collect pickup
        } else if (o2[0]=="invincible"&&o2[1]=="alive") {
          player.invincible=true;
          b2.setUserData(new Object[]{"invincible", "dead"});//Collect pickup
        }
      }//END if first obj is PLAYER


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