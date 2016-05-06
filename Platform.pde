//platforms are stationary bxes used at the base of buildings to give them stable ground
class Platform{
  Vec2 position = new Vec2();//position vector
  
  
  Body b;//body of plat
  
  Vec2 size = new Vec2(100,10);//chosen size of plat
    float x;//x postion
  float y;//y pos
  float w;//width
  float h;//height
  //cunstructor with x and y position
 Platform(float x, float y){
   this.x=x;
   this.y=y;
   this.position = new Vec2(x,y);
   MakePlat();
    //b.setUserData(this);
    b.setUserData(new Object[]{"platform","alive"});

 }
  
  /*
*Destroy the body of the platform fromt he physics world
*
*/
  void destroy(){
     box2d.destroyBody(b); 
  }
  
 /*
*called withint he main function and draw the plat to screen
*
*/
  void display() {
    fill(100);
    noStroke();
    rectMode(CENTER);
    rect(position.x,position.y,size.x,size.y);
  }
  /*
*make plat actualy created th platform into the physics world
*
*/
  void MakePlat(){
   // Define the polygon
    PolygonShape sd = new PolygonShape();
    // Figure out the box2d coordinates
    float box2dW = box2d.scalarPixelsToWorld(size.x/2);
    float box2dH = box2d.scalarPixelsToWorld(size.y/2);
    // We're just a box
    sd.setAsBox(box2dW, box2dH);
    
     // Create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(position.x,position.y));
    b = box2d.createBody(bd);
    
    // Attached the shape to the body using a Fixture
    b.createFixture(sd,1);
    
  }
  
}