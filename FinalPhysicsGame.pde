import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;


import org.jbox2d.callbacks.ContactImpulse;
import org.jbox2d.callbacks.ContactListener;
import org.jbox2d.collision.Manifold;


PShader shader;
PImage cover;

Box2DProcessing box2d;

Player player;

////////////Object Arrays w/ Sorting Arrays
ArrayList<Building> buildings = new ArrayList<Building>();
ArrayList<Platform> platforms = new ArrayList<Platform>();
ArrayList<Rope> ropes = new ArrayList<Rope>();
ArrayList<Pickup> pickups = new ArrayList<Pickup>();


ArrayList<Platform> platformsToCreate = new ArrayList<Platform>();
ArrayList<Platform> platformsToKill = new ArrayList<Platform>();
ArrayList<Building> buildingsToKill = new ArrayList<Building>();
ArrayList<Building> buildingsToCreate = new ArrayList<Building>();
ArrayList<Rope> ropesToKill = new ArrayList<Rope>();
ArrayList<Rope> ropesToCreate = new ArrayList<Rope>();
ArrayList<Pickup> pickupsToKill = new ArrayList<Pickup>();
ArrayList<Pickup> pickupsToCreate = new ArrayList<Pickup>();




//ArrayList<Box> rougeBoxesToCreate = new ArrayList<Box>();

/////////////////Landscape class  
Landscape landscape;
ArrayList<Vec2> lowLandPoints   = new ArrayList<Vec2>();
ArrayList<Vec2> topLandPoints   = new ArrayList<Vec2>();
///Low and High list in float values for shader
FloatList lowPoints = new FloatList();
FloatList highPoints = new FloatList();


float viewOffset;
float xoff = 0.0;
boolean flatLand = false;
int flatCounter = 0;
//increasing Value for incline
float incline = 0;


//class onbject Input
Input in = new Input();


float framesSinceLastUpdate;
//float lastUpdate = 0;

boolean resetGame= false;

int score =0;
int highScore=0;
float timeSinceLastStart=2;

int lives = 3;




void setup() {
  size(900, 600, P2D); 
  cover = loadImage("Empty.png");
  shader = loadShader("frag.glsl");

  //initialize box2d and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -50);

  box2d.world.setContactListener(new CustomListener());

  player=new Player();
  CreateChainArray(); 
  landscape= new Landscape(topLandPoints, lowLandPoints);
  UpdateChainArray();
}








void draw() {
  background(255);
  if (player.setPrevVel) {
    player.basket.setLinearVelocity(player.prevVel);
    player.setPrevVel=false;
  }
  pushMatrix();
  translate(-viewOffset, viewOffset);
  HandleDeaths();
  HandleBirths();
  UpdateDisplays();
  UpdateBoundaries();
  popMatrix();

  box2d.step(); //always step the physics world




  if (lives<=0) player.dead=true;


  if (!player.dead) {
    landscape.UpdateTerrainEveryNFrame(9);
    viewOffset+=1;
  } else {
    if (in.Enter)resetGame=true;
  }

  drawHud();
  if (resetGame) ResetGame();
}

void ResetGame() {
  resetArrays();
  ResetLandscape();

  player.destroyBodies(); 

  player = new Player();
  lives=3;
  //platforms.add(new Platform(player.startingPosition.x-30, player.startingPosition.y));
  viewOffset=0;
  resetGame=false;
  timeSinceLastStart=millis()/1000;
}

void resetArrays() {

  for (Building b : buildings) buildingsToKill.add(b);
  for (Platform p : platforms) platformsToKill.add(p);
  for (Rope r : ropes) ropesToKill.add(r);
  for (Pickup p : pickups) pickupsToKill.add(p);
  buildings=new ArrayList<Building>();
  platforms = new ArrayList<Platform>();
  ropes = new ArrayList<Rope>();
  pickups = new ArrayList<Pickup>();
  buildingsToCreate= new ArrayList<Building>();
  platformsToCreate = new ArrayList<Platform>();
  ropesToCreate= new ArrayList<Rope>();
  pickupsToCreate = new ArrayList<Pickup>();
}

void ResetLandscape() {
  flatLand=false;
  xoff=0.0;
  flatCounter=0;
  incline=0;
  CreateChainArray(); 
  UpdateChainArray();//in update it kills the body and then makes a landscape intoa  ewn landscpe
}




void UpdateDisplays() {
  landscape.display();
  player.display();
  // Display all the obsticls
  for (Building b : buildings)   b.display();
  for (Platform p : platforms)  p.display();
  for (Rope r : ropes)  r.display();
  for (Pickup p : pickups)p.display();
}
void UpdateBoundaries() {

  //Destroy OBsticls if past window frame
  for (Building b : buildings)  if (b.position.x-viewOffset<0)buildingsToKill.add(b);
  for (Platform p : platforms)  if (p.position.x-viewOffset<0)platformsToKill.add(p);  
  for (Rope r : ropes) if (r.position.x-viewOffset<0)ropesToKill.add(r);
}

/*
* DrawHud is responsible for drawing hud elements to the screen.
 *
 */
void drawHud() {
  if (!player.dead) score = int(millis()/1000-timeSinceLastStart); 
  if (score>highScore) highScore=score;
  for (int i = lives; i>0; i--) {
    pushStyle();
    fill(255, 0, 0);
    ellipse(width-50-(i*30), height-20, 20, 20);
    popStyle();
  }
  pushStyle();
  fill(200);
  textSize(40);
  text("Score:       "+ score, 50, 50);
  text("Highscore:  "+ highScore, 50, 100);
  if (player.dead)  text("Press enter to restart", width/2-100, height/2);


  popStyle();
}




void playerDied() {
  player.dead=true;
}






/*
*These chain functions need to be in the main tab
 *
 */
void UpdateChainArray() {
  //If currenlty in flat land mode then make then y same as previouse y aka end of points array
  float y=0;
  if (flatLand)y= lowLandPoints.get(0).y;
  else  y = (lowLandPoints.get(0).y-incline+height*.3+map(random(10), 0, 10, -30, 30))/2;


  ArrayList<Vec2> newLowLand=new ArrayList<Vec2>();
  ArrayList<Vec2> newTopLand=new ArrayList<Vec2>();
  newLowLand.add( new Vec2(lowLandPoints.get(0).x+10, y)); 
  newTopLand.add( new Vec2(topLandPoints.get(0).x+10, y-height+random(-10-(flatCounter*10), 10-(flatCounter*10)))); 

  for (int i = 0; i <110; i++) {
    newLowLand.add(lowLandPoints.get(i));
    newTopLand.add(topLandPoints.get(i));
  }

  lowLandPoints = newLowLand;
  topLandPoints = newTopLand;
  landscape.killBody();
  landscape = new Landscape(topLandPoints, lowLandPoints);

  xoff+=.01+random(-1, 1);
  incline+=10;
}

/*
*This function is called when adding new terrain to see if a object sshould be added
 *
 */
void RollForObsticle() {
  int rand = int(random(0, 100));
  if (rand<25) {
    flatLand=true;
  } else if (rand>75) {
    int n = int(random(2, 12));
    int l = n*15;
    ropesToCreate.add(new Rope(l, n, topLandPoints.get(0), false));
  }
}
/*
*This function is called durring setup to creat the initial inclined low and high points 
 *used for the terrain
 */
void CreateChainArray() {
  lowLandPoints = new ArrayList<Vec2>();
  topLandPoints = new ArrayList<Vec2>();

  for (float x=width+100; x>-100; x -= 10) {
    float y = incline+height*.3;
    lowLandPoints.add( new Vec2(x, y));    
    y-=height;
    topLandPoints.add(new Vec2(x, y));

    xoff+=0.1;
    incline+=10;
  }
  incline=0;
}





/*
*This function handles the births of most objects in the game
 *It does it in a synchronized order useing arrayLists of objects waiting to be made from the
 *previouse frame
 *****This and the next function HandleDeaths() are key for keeping array lists organized and
 *function else they will break with the adding and deleteing of spots within a frame.
 */
void HandleBirths() {
  for (Platform p : platformsToCreate) platforms.add(new Platform(p.x, p.y));
  platformsToCreate= new ArrayList<Platform>();

  for (Building b : buildingsToCreate) buildings.add( new Building(b.position, true));
  buildingsToCreate = new ArrayList<Building>();

  for (Rope r : ropesToCreate) ropes.add(new Rope(r.totalLength, r.numPoints, r.position, true));
  ropesToCreate = new ArrayList<Rope>();



  for (Pickup p : pickupsToCreate) pickups.add(new Pickup(p.type, p.position, true));
  pickupsToCreate= new ArrayList<Pickup>();
}



/*
*This function handles the deaths of objects added their objects list
 *Once cycling through the kill list each object on the list is removed from their main objects list
 *and then the kill list is emptied for the next frame
 *This helps destroy any object from an array right now and only not to save from arraylist erros
 */
void HandleDeaths() {
  for (Circle c : player.circlesToKill) {
    c.destroyBody();
    player.circles.remove(c);
  }
  player.circlesToKill = new ArrayList<Circle>();
  for (Box b : player.boxesToKill) {
    b.destroyBody();
    player.boxes.remove(b);
  }
  player.boxesToKill = new ArrayList<Box>();

  for (Platform p : platformsToKill) {
    p.destroy();
    platforms.remove(p);
  }
  platformsToKill = new ArrayList<Platform>();
  for (Building b : buildings) b.HandleDeaths();
  for (Building b : buildingsToKill) {
    b.destroy();
    buildings.remove(b);
  }
  buildingsToKill = new ArrayList<Building>();


  for (Rope r : ropes) r.HandleDeaths();
  for (Rope r : ropesToKill) {
    r.destroy();
    ropes.remove(r);
  }
  ropesToKill = new ArrayList<Rope>();

  for (Pickup p : pickupsToKill) {
    p.destroy();
    pickups.remove(p);
  }
  pickupsToKill = new ArrayList<Pickup>();
}
/*
*This function handles the presseing of all keys
 *and passes the keycode and state to the input class's handlekey function 
 */
void keyPressed() {
  println(keyCode);
  in.handleKey(keyCode, true);
}
/*
*This function handles the releasing of all keys
 *and passes the keycode and state to the input class's handlekey function 
 */
void keyReleased() {
  in.handleKey(keyCode, false);
}