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

ArrayList<Platform> platformsToCreate = new ArrayList<Platform>();
ArrayList<Platform> platformsToKill = new ArrayList<Platform>();


ArrayList<Building> buildingsToKill = new ArrayList<Building>();
ArrayList<Building> buildingsToCreate = new ArrayList<Building>();

ArrayList<Rope> ropes = new ArrayList<Rope>();
ArrayList<Rope> ropesToKill = new ArrayList<Rope>();
ArrayList<Rope> ropesToCreate = new ArrayList<Rope>();



/////////////////Landscape class  
Landscape landscape;
ArrayList<Vec2> lowLandPoints   = new ArrayList<Vec2>();
ArrayList<Vec2> topLandPoints   = new ArrayList<Vec2>();
///Low and High list in float values for shader
FloatList lowPoints = new FloatList();
FloatList highPoints = new FloatList();


float offset;
float xoff = 0.0;
boolean flatLand = false;
int flatCounter = 0;
//increasing Value for incline
float incline = 0;


//class onbject Input
Input in = new Input();



float fps =0;
float lastFps = 0;
float timeSinceLastFrame;
float lastFrameTime;
float framesSinceLastUpdate;
float lastUpdate = 0;




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
 //landscape.topBody.setUserData(Landscape.class);
 //landscape.lowBody.setUserData(Landscape.class);
  UpdateChainArray();
}



void UpdateChainArray() {

  //If currenlty in flat land mode then make then y same as previouse y aka end of points array
  float y=0;
  if (flatLand)y= lowLandPoints.get(0).y;
  else  y = (lowLandPoints.get(0).y-incline+height*.3+map(random(10), 0, 10, -30, 30))/2;


  ArrayList<Vec2> newLowLand=new ArrayList<Vec2>();
  ArrayList<Vec2> newTopLand=new ArrayList<Vec2>();
  newLowLand.add( new Vec2(lowLandPoints.get(0).x+10, y)); 
  newTopLand.add( new Vec2(topLandPoints.get(0).x+10, y-height+random(-10-(flatCounter*10), 10-(flatCounter*10)))); 

  for (int i = 0; i <100; i++) {
    newLowLand.add(lowLandPoints.get(i));
    newTopLand.add(topLandPoints.get(i));
  }

  lowLandPoints = newLowLand;
  topLandPoints = newTopLand;
  landscape.killBody();
  landscape = new Landscape(topLandPoints, lowLandPoints);
  //CreateChainArray();

  xoff+=.01+random(-1, 1);
  incline+=10;
  //cut shorter than seconds for more precision
  lastUpdate= millis()/10;
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
    ropes.add(new Rope(l, n, topLandPoints.get(0)));
  }
}



/*
*This function is called durring setup to creat the initial inclined low and high points 
 *used for the terrain
 */
void CreateChainArray() {
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

void draw() {
  background(255);


//println(player.killed);

  //always step
  box2d.step();

  UpdateTerrainEveryNFrame(9);
  pushMatrix();
  translate(-offset, offset);


  UpdateDisplays();
  UpdateBirthsDeaths();
  popMatrix();
  offset+=1;
}

void UpdateDisplays() {
  landscape.display();
  player.display();
  // Display all the boxes
  for (Building b : buildings)   b.display();
  for (Building b : buildings)  if (b.position.x-offset<0)buildingsToKill.add(b);


  for (Platform p : platforms)  if (p.position.x-offset<0)platformsToKill.add(p);   
  for (Platform p : platforms)  p.display();


  for (Rope r : ropes) if (r.position.x-offset<0)ropesToKill.add(r);
  for (Rope r : ropes)  r.display();
}

void UpdateBirthsDeaths() {
  HandleBirths();
  HandleDeaths();
}


void   UpdateTerrainEveryNFrame(float n) {

  if (framesSinceLastUpdate>=n) {//UpdateTerrain
    if (flatLand) {//if peviously rolled a flatLAnd terrain
      flatCounter++;//keep going and tally the flat ground
    } else {
      RollForObsticle();//keep going but roll for chance of falt
    }  //end if flat land is ture

    if (flatCounter>4&&flatCounter<6) PlaceBuilding(lowLandPoints.get(0));//if in middle of flat land, place building
    if (flatCounter>10) {   //if added 10 points of flattness stop and reset the flat counter
      flatLand=false;
      flatCounter=0;
    }
    UpdateChainArray();//update chain array 
    framesSinceLastUpdate=0;//Reset framecounting of update
  } else {//still hasn't been n frames
    framesSinceLastUpdate++;
  }//Close if it has been n frame since last terrain update
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

  for (Building b : buildingsToCreate) buildings.add( new Building(b.position));
  buildingsToCreate = new ArrayList<Building>();

  for (Rope r : ropesToCreate) ropes.add(new Rope(r.totalLength, r.numPoints, r.position));
  ropesToCreate = new ArrayList<Rope>();
}



/*
*This function handles the deaths of objects added their objects list
 *Once cycling through the kill list each object on the list is removed from their main objects list
 *and then the kill list is emptied for the next frame
 *This helps destroy any object from an array right now and only not to save from arraylist erros
 */
void HandleDeaths() {
  for (Platform p : platformsToKill) platforms.remove(p);
  platformsToKill = new ArrayList<Platform>();

  for (Building b : buildingsToKill) buildings.remove(b);
  buildingsToKill = new ArrayList<Building>();

  for (Rope r : ropesToKill) ropes.remove(r);
  ropesToKill = new ArrayList<Rope>();
}



/*
*This function adds a building to the buildings to creat list at a specific location
 *@param Vec2 points is the location of the bottom of the new building
 */
void PlaceBuilding(Vec2 point) {
  buildings.add(new Building(point));
}






/*
*This function handles the presseing of all keys
 *and passes the keycode and state to the input class's handlekey function 
 */
void keyPressed() {
  // println(keyCode);
  in.handleKey(keyCode, true);
}
/*
*This function handles the releasing of all keys
 *and passes the keycode and state to the input class's handlekey function 
 */
void keyReleased() {
  in.handleKey(keyCode, false);
}