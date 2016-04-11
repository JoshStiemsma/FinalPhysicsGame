class Platform{
  Vec2 position = new Vec2();
  
  
  Body b;
  
  Vec2 size = new Vec2(100,10);
    float x;
  float y;
  float w;
  float h;
  
 Platform(float x, float y){
   this.x=x;
   this.y=y;
   this.position = new Vec2(x,y);
   MakePlat();
    //b.setUserData(this);
    b.setUserData(new Object[]{"platform","alive"});

 }
  
  
  void destroy(){
     box2d.destroyBody(b); 
  }
  
 
  void display() {
    fill(0);
    stroke(0);
    rectMode(CENTER);
    rect(position.x,position.y,size.x,size.y);
  }
  
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