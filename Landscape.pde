class Landscape {
  
  
  ChainShape lowChain;
  ChainShape topChain;
  Body lowBody;
  Body topBody;


  Landscape(ArrayList<Vec2> topPoints, ArrayList<Vec2> lowPoints) {
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

    lowBody.setUserData(new Object[]{"ground", "alive"});
    topBody.setUserData(new Object[]{"ground", "alive"});
  }


  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(lowBody);
    box2d.destroyBody(topBody);
  }


  /*
  *This is the desiplay function and draws a shape for each the lowLAndPoints and the highLand Points 
   *
   */
  void display() {
    pushStyle();
    strokeWeight(2);
    stroke(0);
    fill(100, 100, 100);
    beginShape();
    for (Vec2 v : lowLandPoints) {
      vertex(v.x, v.y);
    }

    //vertex(-width+viewOffset, height);
    //vertex(width+viewOffset, height+20-incline);
    vertex(-100, 1000);
    vertex(10000, 10000);


    //line(0,0,width,height);
    //close shape so fill works
    popStyle();
    pushStyle();
    fill(100, 100, 100);
    endShape();
    
    

    //for (Vec2 v : topLandPoints) {
    //  vertex(v.x, v.y);
    //}
    //vertex(topLandPoints.get(topLandPoints.size()-1).x-1000, topLandPoints.get(topLandPoints.size()-1).y);
    //vertex(topLandPoints.get(topLandPoints.size()-1).x-1000, topLandPoints.get(0).y);
    //vertex(topLandPoints.get(0).x+1000, topLandPoints.get(0).y-1000-incline);

for(int i =0; i<topLandPoints.size();i+=20){
  //int k = 0;   
  beginShape();
   vertex(topLandPoints.get(i).x, topLandPoints.get(i).y-1000);
  for(int j = i; j <=i+20;j++){
    if(j<topLandPoints.size()) vertex(topLandPoints.get(j).x, topLandPoints.get(j).y);
    
  }
   if(i+20<topLandPoints.size()) vertex(topLandPoints.get(i+20).x, topLandPoints.get(i+20).y-1000);
  else vertex(topLandPoints.get(topLandPoints.size()-1).x, topLandPoints.get(topLandPoints.size()-1).y-1000);;
  
  //k+=100;
  
  //vertex(v.x, v.y);
  
   endShape();
}
    

   
    
    
    
    popStyle();
  }

 

  void   UpdateTerrain() {

    if (flatLand) {//if peviously rolled a flatLAnd terrain
      flatCounter++;//keep going and tally the flat ground
    } else {
      RollForObsticle();//keep going but roll for chance of falt
    }  //end if flat land is ture

    if (flatCounter>4&&flatCounter<6) buildingsToCreate.add(new Building(lowLandPoints.get(0), false ));//if in middle of flat land, place building
    if (flatCounter>10) {   //if added 10 points of flattness stop and reset the flat counter
      flatLand=false;
      flatCounter=0;
    }
    player.LastTerrainUpdate=player.position.x;
    UpdateChainArray();//update chain array 
  }
}