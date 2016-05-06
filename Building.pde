//The building class is a collection of boxes managed by this class
class Building {
//brick image holder
  PImage brick;
  //constructor for building
  Building(Vec2 pos, boolean toCreate) {//position and boolean toCreate that is true when a createList makes the object as to actualy make it and its physics body, then and only then
    this.position=pos;//set position
    if (toCreate) {//if a create list is creating this
      SetPlat();//make and set the platform for the building
      int rand = int(random(2));//grab a random var
      switch(rand) {//depending on the rand, make building or stack type building
      case 0:
        MakeStack(pos);
        break;
      case 1:
        MakeBuilding(pos);
        break;
      }

      int rand2 = int(random(3));//grab another rand and use that to set brick color
      if (rand2==0) brick = brick01;
      else if (rand2==1)brick = brick02;
      else if (rand2==2) brick = brick03;
    }//end to create
  }//end constructor

  Vec2 position = new Vec2();//Position Vec2 
//platform class object named platform
  Platform platform; 


  ArrayList<Box> boxes = new ArrayList<Box>();//array list of all boxes
  ArrayList<Box> boxesToKill = new ArrayList<Box>();//arraylist of boxes that need to be killed, we dont like them
  ArrayList<Box> boxesToCreate = new ArrayList<Box>();//arraylst of boxes that need to be made, we play god
/*
*the function destroy is used to destroy alll of the bodies within this building
*
*/
  void destroy() {
    for (Box b : boxes) b.destroyBody();
  }
/*
*the function update is called every frame within the main classes update function
*
*/
  void update() {
    for (Box b : boxes) {//for each box
      Object[] o1 = (Object[])b.body.getUserData();//grab its used data
     //println(o1[2]);
      //if (o1[2]!=null) {
      //  if (o1[2]=="onChain") {
      //    b.onChainCount++;
      //    o1[2]="offChain";
      //  } else {
      //    b.onChainCount=0;
      //    o1[2]="offChain";
      //  }
      //  if (b.onChainCount>60) {
      //    boxesToKill.add(b);
      //  }
      //}

      if (b.parent!=null&&b.parent.getClass()==Building.class) { //Check for parent to see if this is a building piece or rouge block

        if (o1[1]=="dead") {//if flagged for dead
          boxesToKill.add(b);//add to kill list
        } else if (o1[1]=="deadByPlayer") {//if tagged for dead by player hit
          boxesToKill.add(b);//add to kill list
          b.hitByPlayer=true;//also flag that hit by palyer
        }//end if block dead
      }//end for each bloack within a parent
    }//end for each blcok
  }
  
  /*
  *the function display is called every fram within the main classes display function
  */
  void display() {

    for ( int i = 0; i <boxes.size(); i++) {//for each box in boxes array
      Vec2 pos = box2d.getBodyPixelCoord(boxes.get(i).body);//grab its physics world position
      boxes.get(i).pos=pos;//set its pos to its grabbed physics pos
      float a1 = boxes.get(i).body.getAngle();//grab is ph angle
      pushMatrix();//Enter the matrix neo
      imageMode(CENTER);       //image mode center
      translate(pos.x, pos.y);//move to its position
      rotate(-a1);//rotate
      image(brick, 0, 0, boxes.get(i).w, boxes.get(i).h);//draw brick image , with boxes width and height
      popMatrix();//leave matrix neo
    }
  }
/*
*The function remove from array, removes the passed box from this buildings main array
*/
  void removeFromArray(Box b) {
    boxes.remove(b);//remove the box
  }
/*
*The function set PLat creates a new platform for the building to set on
*/
  void SetPlat() {
    platforms.add( new Platform(position.x, position.y));
  }

/*
*The function make Stack, makes a building of the stacked type at the passed Vec2 position
*/
  void MakeStack(Vec2 pos) {
    int rand = int(random(2, 6));//grab new ran between 2-6 int
    for (int i =0; i <rand; i++) {//for each amount of rand make a new boxleve
      Vec2 newSize = new Vec2(95, 37); //grab a new size
      Vec2 newPos = new Vec2(pos.x, pos.y-((newSize.y+1)*(i+1)));//grab a new position that increases with rand the size of half new box
      boxesToCreate.add(new Box(newPos, newSize, false, .1, this, false));//add this box to the creation list
    }
  }
/*
*The function make buiulding, mkaes  building of the building type at the passed Vec2 position
*/
  void MakeBuilding(Vec2 pos) {
    int rand = int(random(1, 6));//grab random between 1-6
    for (int i =0; i <rand; i++) {//make  new box per rand
      Vec2 newPos = new Vec2(pos.x, pos.y-40);//grab new pos
      if (i==0) {//if first box 
        newPos = new Vec2(pos.x, pos.y-40);
      } else {//if not first box
        newPos = new Vec2(pos.x, pos.y-(40*(i+1)));
      }
      Box d = new Box(newPos, new Vec2( 90, 10 ), false, .1, this, false );//create new box
      boxesToCreate.add(d);//add it to create list

      Box b = new Box(new Vec2(newPos.x+20, newPos.y), new Vec2( 25, 40 ), false, .1, this, false);//create new box    
      boxesToCreate.add(b);//add to create list

      //newPos.x+=20;
      int random = int(random(1, 10));//grab new rand for pickup
      if (random<=1) {//1/10 chance
        Pickup p = new Pickup("life", newPos, false);//create life pickup within building
        pickupsToCreate.add(p);//add to pickup create list
      }

      Box c = new Box(new Vec2(newPos.x-20, newPos.y), new Vec2( 25, 40 ), false, .1, this, false);//creat third box
      boxesToCreate.add(c); 

      newPos.y-=34;//add to height for next level
    }//end each leve
  }//end create building
  /*
*The function handle births hanldes all the creations of new boxes in this building at a decent time
*/
  void HandleBirths() {
    for (Box b : this.boxesToCreate) {//for each box in boxes to create
      Box nb;//create new box
      if (b.parent!=null&&b.parent.getClass()==Building.class) {//if this box has a parent 
        nb = new Box( b.pos, b.size, b.fixed, b.density, b.parent, true);//use the constructor that includes setting the parent
        boxes.add(nb);//add box to the parents boxes list
      } else {//if no parent
        nb =new Box( b.pos, b.size, b.fixed, b.density, true);//use the cunstructor for having no parent
        boxes.add(nb);//add box to the parents boxes list
      }//end if has parent
      nb.body.setLinearVelocity(new Vec2(b.initVel.x*3, b.initVel.y*3  ));//set velocity to palyers elocity
    }
    this.boxesToCreate=new ArrayList<Box>();//clear creation list
  }

/*
*The function handle deaths eleminates any objects on the list at the proper time within the frame
*/
  void HandleDeaths() {

    for (Box b : boxesToKill) {//for each box in boxes to kill
      b.Explode();//explode the box
      b.destroyBody();//destroy its body

      int rand = int(random(5));//grab a random int to select a random noise 
      switch (rand){//based off of rand, play the corrilating noise
       case 0:
       rock01.play();
       break;
        case 1:
        rock02.play();
       break;
       case 2:
       rock03.play();
       break;
       case 3:
       rock04.play();
       break;
       case 4:
       rock05.play();
       break;
        case 5:
        rock06.play();
       break;
      }
      boxes.remove(b);//remove the box from the boxes array
    }//end for each box
    boxesToKill = new ArrayList<Box>();//clear the boxes to kill list
  }//end handle deaths
}//close class