
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
    //UserData u1 = new UserData( f1.getBody().getUserData());
    if (o1[0]=="player") {
      if (o2[0]=="box") {
        println("hitbox");
        b2.setUserData(new Object[]{"box", "dead"});
        player.dead=true;
      } else if (o2[0]=="ground") {
        println("hitGround");
      }
    }
    // If object 1 is a Box, then object 2 must be a particle
    // Note we are ignoring particle on particle collisions
    //if (o1.getClass() == Player.class ) {

    //  if (o2.getClass() == Platform.class) {
    //    //println("plat");
    //  } else if (o2.getClass() == Box.class) {
    //    for (Building building : buildings) {
    //      for (Box box : building.boxes) {
    //        if(o2==box)  buildingsToKill.add(building);
    //      }
    //    }

    //  } else {

    //    if (!player.dead) {
    //      println(b2.getUserData()+  "killed the player");
    //      playerDied();
    //    }
    //  }
    //}
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