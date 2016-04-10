class Landscape {
  //ArrayList<Vec2> landscape;
  ChainShape lowChain;
  ChainShape topChain;
  Body lowBody;
  Body topBody;

Landscape(ArrayList<Vec2> topPoints, ArrayList<Vec2> lowPoints){
   lowChain = new ChainShape();
    topChain = new ChainShape();
    //With our arraylist  
    //We need to convert them to Box2d coordinates
    Vec2[] lowVerts = new Vec2[lowPoints.size()];
    for (int i = 0; i < lowVerts.length; i ++) {
      Vec2 edge = box2d.coordPixelsToWorld(lowPoints.get(i));
      lowVerts[i] = edge;
    }
    Vec2[] topVerts = new Vec2[topPoints.size()];
    for (int i = 0; i < topVerts.length; i ++) {
      Vec2 edge = box2d.coordPixelsToWorld(topPoints.get(i));
      topVerts[i] = edge;
    }

    //create the chain
    lowChain.createChain(lowVerts, lowVerts.length);
    //create the chain
    topChain.createChain(topVerts, topVerts.length);


    //attach the chain to a body via a fixture
    BodyDef topbd = new BodyDef();
    topbd.position.set(0.0f, 0.0f);
    topBody = box2d.createBody(topbd);
    //attach the chain to a body via a fixture
    BodyDef lowbd = new BodyDef();
    lowbd.position.set(0.0f, 0.0f);
    lowBody = box2d.createBody(lowbd);



    //Define a fixture 
    FixtureDef topfd = new FixtureDef();
    topfd.shape = topChain;
    topfd.friction = .3;
    topfd.density = 1;
    topfd.restitution = 0.5;
    //Define a fixture 
    FixtureDef lowfd = new FixtureDef();
    lowfd.shape = lowChain;
    lowfd.friction = .3;
    lowfd.density = 1;
    lowfd.restitution = 0.5;


    lowBody.createFixture(lowfd);
    topBody.createFixture(topfd);
    //Shortcut
    //body.createFixture(cahin,1.0);

 topBody.setUserData(Landscape.class);
 lowBody.setUserData(Landscape.class);
}
  
  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(lowBody);
    box2d.destroyBody(topBody);
  }



  void display() {

    strokeWeight(2);
    stroke(0);
    noFill();
    beginShape();
    for (Vec2 v : lowLandPoints) {
      vertex(v.x, v.y);
    }
    endShape();
    beginShape();
    for (Vec2 v : topLandPoints) {
      vertex(v.x, v.y);
    }
    endShape();
  }
  
  
  
}