class Building {

  PImage brick;
  Building(Vec2 pos, boolean toCreate) {
    this.position=pos;
    if (toCreate) {
      SetPlat();
      int rand = int(random(2));
      
      switch(rand) {
      case 0:
        MakeStack(pos);
        break;
      case 1:
        MakeBuilding(pos);
        break;
      }

      int rand2 = int(random(3));
      if (rand2==0) brick = brick01;
      else if (rand2==1)brick = brick02;
      else if (rand2==2) brick = brick03;
    }
  }

  Vec2 position = new Vec2();

  Platform platform; 


  ArrayList<Box> boxes = new ArrayList<Box>();
  ArrayList<Box> boxesToKill = new ArrayList<Box>();
  ArrayList<Box> boxesToCreate = new ArrayList<Box>();

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
        } else if (o1[1]=="deadByPlayer") {
          boxesToKill.add(b);
          b.hitByPlayer=true;
        }//end if block dead
      }//end for each bloack within a parent
    }//end for each blcok
  }
  void display() {

    for ( int i = 0; i <boxes.size(); i++) {
      Vec2 pos = box2d.getBodyPixelCoord(boxes.get(i).body);
      boxes.get(i).pos=pos;
      float a1 = boxes.get(i).body.getAngle();
      pushMatrix();
      imageMode(CENTER);       
      translate(pos.x, pos.y);
      rotate(-a1);
      scale(1);
      image(brick, 0, 0, boxes.get(i).w, boxes.get(i).h);

      popMatrix();
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
      //Box b = new Box(newPos, newSize, false, .1, this, false);
      //b.parent = this;
      boxesToCreate.add(new Box(newPos, newSize, false, .1, this, false));
    }
  }

  void MakeBuilding(Vec2 pos) {

    int rand = int(random(1, 6));
    for (int i =0; i <rand; i++) {
      Vec2 newPos = new Vec2(pos.x, pos.y-40);
      if (i==0) {
        newPos = new Vec2(pos.x, pos.y-40);
      } else {
        newPos = new Vec2(pos.x, pos.y-(40*(i+1)));
      }
      Box d = new Box(newPos, new Vec2( 90, 10 ), false, .1, this, false );
      //d.parent = this;
      boxesToCreate.add(d);

      Box b = new Box(new Vec2(newPos.x+20,newPos.y), new Vec2( 25, 40 ), false, .1, this, false);
      //b.parent = this;
      boxesToCreate.add(b);

      //newPos.x+=20;
      int random = int(random(1, 10));
      if (random<=1) {
        Pickup p = new Pickup("life", newPos, false);
        pickupsToCreate.add(p);
      }

   
      Box c = new Box(new Vec2(newPos.x-20,newPos.y), new Vec2( 25, 40 ), false, .1, this, false);
      // c.parent = this;  
      boxesToCreate.add(c); 


      
      newPos.y-=34;
    }
  }
  void HandleBirths() {
    for (Box b : this.boxesToCreate) {
      Box nb;
      if (b.parent!=null&&b.parent.getClass()==Building.class) {
        nb = new Box( b.pos, b.size, b.fixed, b.density, b.parent, true);
        boxes.add(nb);//add box to the parents boxes list
      } else {
        nb =new Box( b.pos, b.size, b.fixed, b.density, true);
        boxes.add(nb);//add box to the parents boxes list
      }
      println("Made at" + nb.pos.x);
      nb.body.setLinearVelocity(new Vec2(b.initVel.x*3, b.initVel.y*3  ));//set velocity to palyers elocity
    }
    this.boxesToCreate=new ArrayList<Box>();
  }


  void HandleDeaths() {

    for (Box b : boxesToKill) {
      b.Explode();
      b.destroyBody();


      boxes.remove(b);
      //remove box from its array of boxes in either rope or building
    }
    boxesToKill = new ArrayList<Box>();
  }
}