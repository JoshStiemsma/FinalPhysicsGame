//the landscape cass holds the information for the ceiling and floor arrays as well as their jbox 2d bodies
class Landscape {


  ChainShape lowChain;//fllor chainshape object
  ChainShape topChain;//ceiling chain shape object
  Body lowBody;//fllor Body
  Body topBody;//ceiling body

//cunstructor that is being passed an ArrayList<Vec2> for the ceiling Points and another for the floor points
  Landscape(ArrayList<Vec2> topPoints, ArrayList<Vec2> lowPoints) {
    lowChain = new ChainShape();//set lowchain to new chainshape
    topChain = new ChainShape();//set top chain to new chainshape
    //With our arraylist  
    //We need to convert them to Box2d coordinates
    Vec2[] lowVerts = new Vec2[lowPoints.size()];
    for (int i = 0; i < lowVerts.length; i ++) {
      Vec2 edge = box2d.coordPixelsToWorld(lowPoints.get(i));//convert the given point to the world position
      lowVerts[i] = edge;//create edge at this point
    }
    Vec2[] topVerts = new Vec2[topPoints.size()];
    for (int i = 0; i < topVerts.length; i ++) {
      Vec2 edge = box2d.coordPixelsToWorld(topPoints.get(i));
      topVerts[i] = edge;//create edge at this point
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

    lowBody.setUserData(new Object[]{"ground", "alive"});//set the user data to ground type and alive
    topBody.setUserData(new Object[]{"ground", "alive"});//setthe user data to ground tpe and alive
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
    noStroke();
    fill(100, 100, 100);

    ////////////////Top Layer
    beginShape();
    for (Vec2 v : lowLandPoints) {
      vertex(v.x, v.y);
    }
    vertex(-100, 1000);
    vertex(10000, 10000);

    endShape();



    /////////Bottom layer
    for (int i =0; i<topLandPoints.size(); i+=20) {//for every 20 points in the array
      //int k = 0;  
      beginShape();//make a new shape
      vertex(topLandPoints.get(i).x, topLandPoints.get(i).y-1000);//make apoint aboce the first points first

      for (int j = i; j <=i+20; j++) {
        if (j<topLandPoints.size()) vertex(topLandPoints.get(j).x, topLandPoints.get(j).y);//draw the points
      }
      if (i+20<topLandPoints.size()) vertex(topLandPoints.get(i+20).x, topLandPoints.get(i+20).y-1000);//make a point above the last point
      else  vertex(topLandPoints.get(topLandPoints.size()-1-10).x, topLandPoints.get(topLandPoints.size()-1).y-1000);//if end of array and last points might not exsits,,do this one

      endShape();//end the shape
    }//end for each 20 points in array
    popStyle();//end style



    for (int i =0; i<topLandPoints.size()-1; i++) {//for each point

      if (abs(topLandPoints.get(i).x-box2d.getBodyPixelCoord(player.basket).x)<=width) {//if within range of player view, draw a stroke
        strokeWeight(10);
        float j = topLandPoints.get(i).y-topLandPoints.get(i+1).y;//grab direction of vec between enxt point
        //set color of stroke based of of angle 
        if (j>=7) {
          stroke(10);
        } else if (j<=-7) {
          stroke(50);
        } else {
          stroke(50);
        }
        line( topLandPoints.get(i).x, topLandPoints.get(i).y, topLandPoints.get(i+1).x, topLandPoints.get(i+1).y  );//draw the line

//do the same for low land points
        j = lowLandPoints.get(i).y-lowLandPoints.get(i+1).y;
        if (j>=7) {
          stroke(100);
        } else if (j<=-7) {
          stroke(10);
        } else {
          stroke(75);
        }
        line( lowLandPoints.get(i).x, lowLandPoints.get(i).y, lowLandPoints.get(i+1).x, lowLandPoints.get(i+1).y  );
      }
    }//close for each top point
    noStroke();
  }//Close Display


/*
*this function update terrain, updates the terrain when the player has gone far enough that it needs to lengthened to continue
*
*/
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
  }//end update terrain
}//end landscape class