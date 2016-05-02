class Building {

  PImage brick;
  Building(Vec2 pos, boolean toCreate) {
    this.position=pos;
    if (toCreate) {
      SetPlat();
      int rand = int(random(0, 2)); 
      switch(rand) {
      case 0:
        MakeStack(pos);
        break;
      case 1:
        MakeBuilding(pos);
        break;
      }
      
      int rand2 = int(random(3));
      if(rand2==0) brick = brick01;
      else if(rand2==1)brick = brick02;
      else if(rand2==2) brick = brick03;
    }
  }

  Vec2 position = new Vec2();

  Platform platform; 


  ArrayList<Box> boxes = new ArrayList<Box>();
  ArrayList<Box> boxesToKill = new ArrayList<Box>();


  void destroy() {
    for (Box b : boxes) b.destroyBody();
    //boxes=null;
  }

  void update() {
    for (Box b : boxes) {
      if (b.parent!=null&&b.parent.getClass()==Building.class) { //Check for parent to see if this is a building piece or rouge block
        Object[] o1 = (Object[])b.body.getUserData();
        if (o1[1]=="dead") {
          boxesToKill.add(b);
        }//end if block dead
      }//end for each bloack within a parent
    }//end for each blcok
  }
  void display() {

    for ( int i = 0; i <boxes.size(); i++) {
      Vec2 pos = box2d.getBodyPixelCoord(boxes.get(i).body);
      float a1 = boxes.get(i).body.getAngle();
      pushMatrix();
      imageMode(CENTER);       
      translate(pos.x, pos.y);
      rotate(-a1);
      scale(1);
      image(brick, 0, 0, boxes.get(i).w, boxes.get(i).h);

      popMatrix();

      // b.display(255);
    }
    for (Box b : boxes) {
      //b.display(175);
    }
  }

  void removeFromArray(Box b) {
    boxes.remove(b);
  }

  void SetPlat() {

    platforms.add( new Platform(position.x, position.y));
  }


  void MakeStack(Vec2 pos) {
    int rand = int(random(2, 6));
    for (int i =0; i <rand; i++) {
      Vec2 newSize = new Vec2(95, 37); 
      Vec2 newPos = new Vec2(pos.x, pos.y-((newSize.y+1)*(i+1)));
      Box b = new Box(newPos, newSize, false, .1 );
      b.parent = this;
      boxes.add(b);
    }
  }

  void MakeBuilding(Vec2 pos) {

    int rand = int(random(1, 6));
    for (int i =0; i <rand; i++) {
      Vec2 newPos = new Vec2(pos.x-35, pos.y-40);
      if (i==0) {
        newPos = new Vec2(pos.x-35, pos.y-40);
      } else {
        newPos = new Vec2(pos.x-35, pos.y-(40*(i+1)));
      }

      Box b = new Box(newPos, new Vec2( 25, 40 ), false, .1 );
      b.parent = this;
      boxes.add(b);

      newPos.x+=20;
      int random = int(random(1, 10));
      if (random<=1) {
        Pickup p = new Pickup("life", newPos, false);
        pickupsToCreate.add(p);
      }

      newPos.x+=25;
      Box c = new Box(newPos, new Vec2( 25, 40 ), false, .1 );
      c.parent = this;  
      boxes.add(c); 


      newPos.x-=25;
      newPos.y-=34;

      Box d = new Box(newPos, new Vec2( 90, 10 ), false, .1 );
      d.parent = this;
      boxes.add(d);
    }
  }

  void HandleDeaths() {

    for (Box b : boxesToKill) {
      b.destroyBody();
      b.Explode();

      boxes.remove(b);
      //remove box from its array of boxes in either rope or building
    }
    boxesToKill = new ArrayList<Box>();
  }
}