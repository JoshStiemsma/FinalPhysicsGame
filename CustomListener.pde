
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

    if (o1[0]=="player"||o2[0]=="player") {

      if (o2[0]=="box") {
        Vec2 vel =b1.getLinearVelocity();
        if (mag(vel.x, vel.y)>25) b2.setUserData(new Object[]{"box", "dead"});//Explode Box if players velocity is over a limit
      } else if (o2[0]=="ground"||o1[0]=="ground") {
        if (millis()/1000-player.timeSinceLastWallHit>.5) {//hit wall take away life
          lives-=1;
          player.timeSinceLastWallHit=millis()/1000;
        }
      } else if (o2[0]=="life") {
        if (lives<3)lives+=1;
        b2.setUserData(new Object[]{"life", "dead"});//Collect pickup
      }

    }
      if (o2[0]=="b1") if (o1[0]=="ground")player.loseBalloon1();
      if (o2[0]=="b2") if (o1[0]=="ground")player.loseBalloon2();
      if (o2[0]=="b3") if (o1[0]=="ground")player.loseBalloon3();
      if (o2[0]=="ground") if(o1[0]=="b1")player.loseBalloon1();
      if (o2[0]=="ground") if(o1[0]=="b2")player.loseBalloon2();
      if (o2[0]=="ground") if(o1[0]=="b3")player.loseBalloon3();

      
    
  }


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