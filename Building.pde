class Building {

  Building(Vec2 pos, boolean toCreate) {
    this.position=pos;
    if (toCreate) {
      int rand = int(random(0, 2)); 
      SetPlat();
      switch(rand) {
      case 0:
        MakeStack(pos);
        break;
      case 1:
        MakeBuilding(pos);
        break;
      }
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

  void display() {
    for (Box b : boxes) {
      Object[] o1 = (Object[])b.body.getUserData();
      if (o1[1]=="dead") boxesToKill.add(b);
      b.display(175);
    }
  }

  void removeFromArray(Box b) {
    boxes.remove(b);
  }

  void SetPlat() {

    platforms.add( new Platform(position.x, position.y));
  }


  void MakeStack(Vec2 pos) {
    int rand = int(random(2, 10));
    for (int i =0; i <rand; i++) {
      Vec2 newSize = new Vec2(95, 37); 
      Vec2 newPos = new Vec2(pos.x, pos.y-((newSize.y+1)*(i+1)));
      boxes.add(new Box(newPos, newSize, false, .1 ));
    }
  }

  void MakeBuilding(Vec2 pos) {

    int rand = int(random(1, 10));
    for (int i =0; i <rand; i++) {
      Vec2 newPos = new Vec2(pos.x-35, pos.y-10);
      if (i==0) {
        newPos = new Vec2(pos.x-35, pos.y-10);
      } else {
        newPos = new Vec2(pos.x-35, pos.y-(47*(i+1)));
      }

      boxes.add(new Box(newPos, new Vec2( 25, 40 ), false, .1)); 
      newPos.x+=45;
      boxes.add(new Box(newPos, new Vec2( 25, 40 ), false, .1)); 
      newPos.x-=25;
      newPos.y-=34;
      boxes.add(new Box(newPos, new Vec2( 90, 10 ), false, .1));
    }
  }

  void HandleDeaths() {
    for (Box b : boxesToKill) {
      b.destroyBody();
      boxes.remove(b);
      //remove box from its array of boxes in either rope or building
    }
    boxesToKill = new ArrayList<Box>();
  }
}