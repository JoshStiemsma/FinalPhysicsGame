class Building {

  Building(Vec2 pos) {
    //SetPlat();

    int rand = int(random(0, 2));
    //int rand = 1;
    this.position=pos;
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

  Vec2 position = new Vec2();

  Platform platform; 


  ArrayList<Box> boxes = new ArrayList<Box>();



  void display() {
    for (Box b : boxes) {

      b.display(175);
    }
  }
  void SetPlat() {

    platforms.add( new Platform(position.x, position.y));
  }

  void MakeStack(Vec2 pos) {
    int rand = int(random(2, 10));
    for (int i =0; i <rand; i++) {
      Vec2 newSize = new Vec2(95, 37); 
      Vec2 newPos = new Vec2(pos.x, pos.y-((newSize.y+1)*(i+1)));

      boxes.add(new Box(newPos, newSize, false,1 ));
    }
  }

  void MakeBuilding(Vec2 pos) {

    int rand = int(random(1, 10));
    for (int i =0; i <rand; i++) {
       Vec2 newPos = new Vec2(pos.x-35, pos.y-10);
      if(i==0){
         newPos = new Vec2(pos.x-35, pos.y-10);

      }else{
       newPos = new Vec2(pos.x-35, pos.y-(47*(i+1)));
  
      }
      
      boxes.add(new Box(newPos, new Vec2( 25, 40 ), false ,1)); 
      newPos.x+=45;
      boxes.add(new Box(newPos, new Vec2( 25, 40 ), false ,1)); 
      newPos.x-=25;
      newPos.y-=34;
      boxes.add(new Box(newPos, new Vec2( 90, 10 ), false ,1));
    }
  }
}