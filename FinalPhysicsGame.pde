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
PGraphics canvas;

PImage Title;

PImage ballImg01;
PImage ballImg02;
PImage ballImg03;

PImage ropeKnot;
PImage rope;
PImage basketImg01;
PImage basketImg02;
PImage basketImg03;
PImage basketInv;
PImage health;
PImage invincible;
PImage token;

PImage brick01;
PImage brick02;
PImage brick03;

Camera camera;
Box2DProcessing box2d;

Player player;

String gameState = "Play";

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
String direction = "Flat";
Float TSLDirectionChange = 0.0;
float directionChangeTime = 100.0;


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
float adjuster = 2;

//class onbject Input
Input in = new Input();


float framesSinceLastUpdate;
//float lastUpdate = 0;

boolean resetGame= false;

public int score =0;
int pointsPickedUp =0;
int highScore=0;
float timeSinceLastStart=2;

int lives = 3;

boolean paused = false;
boolean pauseReleased =true;




void loadImages() {
  Title = loadImage("Title-01-01.png");
  cover = loadImage("Empty.png");
  ballImg01 = loadImage("balloonBlue-01.png");
  ballImg02 = loadImage("balloonGreen-01.png");
  ballImg03 = loadImage("balloonRed-01.png");
  ropeKnot = loadImage("ropeKnot.png");
  rope = loadImage("rope-01.png");
  basketImg01 = loadImage("Player-01.png");
  basketImg02 = loadImage("PlayerCrack1-01.png");
  basketImg03 = loadImage("PlayerCrack2-01.png");
  basketInv = loadImage("PlayerBlue-01.png");
  token = loadImage("Token-01.png");
  health =loadImage("Health-01.png");
  invincible = loadImage("Invincibility-01.png");
  brick01 =loadImage("brickVariant1-01.png");
  brick02 =loadImage("brickVariant2.png");
  brick03 =loadImage("brickVariant3-01.png");
}

void setup() {
  size(900, 600, P2D); 
  loadImages();
  shader = loadShader("frag.glsl");
  canvas = createGraphics(width, height);

  //initialize box2d and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -50);

  box2d.world.setContactListener(new CustomListener());

  player=new Player();
  camera = new Camera();
  CreateChainArray(); 
  landscape= new Landscape(topLandPoints, lowLandPoints);
  UpdateChainArray();
}



void draw() {
  ///background color stuff
  float r;
  if (incline>=10000) r = map(incline, 10000, 20000, 10, 255);
  else  r = 10;
  float g = 10;
  float b = map(incline, 0, 10000, 20, 255);
  background(r, g, b);

  if (gameState=="Title") {

    pushMatrix();
    scale(.235);
    image(Title, 0, 0);
    popMatrix();
    if (in.EnterReleased)resetGame=true;//wait for player to press enter then reset game
    if (resetGame) ResetGame();//if resetGame is true then reset the game by calling the function ResetGame
  } else if (gameState=="Play"||gameState=="Dead") {

    pushMatrix();
    translate(-camera.position.x, -camera.position.y);
    if (!paused) {
      HandleDeaths();
      HandleBirths();
      UpdateDisplays();
      UpdateBoundaries();
      Update();
    } else UpdateDisplays();
    popMatrix();
    drawHud();

    if (in.Pause&&pauseReleased) {
      paused=!paused;
      pauseReleased=false;
    }
    if (!in.Pause&&pauseReleased==false) pauseReleased=true;
    
    
    if(gameState=="Dead"&&in.EnterReleased==true) endGame();
  }//end if Dead or Play 
  
    in.update();
}//close Draw




void Update() {

  //if score is greater than highscore then thats the new highscore
  if (score>highScore) highScore=score;
  //if players bollean setPreviouseVelocity is set to true, then set it and make the boolean false
  if (player.setPrevVel) {
    player.basket.setLinearVelocity(player.prevVel);
    player.setPrevVel=false;
  }

  //update the player
  player.update();
  //update the buildings
  for (Building b : buildings)   b.update();
  //update the ropes
  for (Rope r : ropes)  r.update();
  //update the pickups
  for (Pickup p : pickups)p.update();


  box2d.step(); //always step the physics world



  //if players basket has hit ground enough to make livs hit 0
  if (lives<=0) player.dead=true;

  if (!player.dead) {//if player is alive

    float dist = player.position.x-player.LastTerrainUpdate;
    if (dist>=10)landscape.UpdateTerrain();
  } else {//if player is dead  

    gameState = "Dead";
    //gameOver();
  }
  
  

  
}//End update

void gameOver() {

  gameState = "Dead";
  if(player.invincible)player.invincible=!player.invincible;
}

void endGame() {
  gameState="Title";
  resetArrays();//Reset all the arrays adds all objects to their kill lists, then sets all lists and creation lists to null,but not kill list cause they need to run and self destroy after 
  ResetLandscape();//reset the landscape which destroys the chin arrays bodies as well as its arrays then creates new beginning arrays
  player.destroyBodies(); 
  camera.reset();
}
/*
*This is the main reset game function that calls individual resets as well as reinitializes thing for the reset
 *Things to be reset are   Arrays   Landscape     Player   and alll previouse box2d bodies must be deleted
 */
void ResetGame() {
  //resetArrays();//Reset all the arrays adds all objects to their kill lists, then sets all lists and creation lists to null,but not kill list cause they need to run and self destroy after 
  // ResetLandscape();//reset the landscape which destroys the chin arrays bodies as well as its arrays then creates new beginning arrays
  //destroy the player body
  // player.destroyBodies(); 


  //camera.reset();
  CreateChainArray(); //create new chain array
  UpdateChainArray();//in update it kills the body and then makes a landscape into a new landscpe

  //then create new player by setting player to new player
  player = new Player();
  //reset lives to 3; basket damage
  lives=3;
  //reset amount of pickups grabbed
  pointsPickedUp=0;

  camera.position.x=0;
  camera.position.y=0;
  //reset the boolean that triggerd this function
  resetGame=false;
  //set the time since last restart to now so that the next sessions timers and counters will work from this point intead of start of program
  timeSinceLastStart=millis()/1000;

  gameState="Play";
}
/*
*This function resets all of the arrays that hold objects within the game.
 *It also resets the  Kill and Birth lists so that nothing that was previously in those lists gets spawned
 *
 */
void resetArrays() {

  for (Building b : buildings) buildingsToKill.add(b);//add each building to its kill list
  for (Platform p : platforms) platformsToKill.add(p);//add each platform to its kill list
  for (Rope r : ropes) ropesToKill.add(r);//add each rope to its kill list
  for (Pickup p : pickups) pickupsToKill.add(p);//add each pickup to its kill list
  buildings=new ArrayList<Building>();//reset building array
  platforms = new ArrayList<Platform>();//reset platfrom array
  ropes = new ArrayList<Rope>();//reset rope array
  pickups = new ArrayList<Pickup>();//reset pickup array
  buildingsToCreate= new ArrayList<Building>();//reset buildings creation array
  platformsToCreate = new ArrayList<Platform>();//reset platforms creation array
  ropesToCreate= new ArrayList<Rope>();//reset ropes creation array
  pickupsToCreate = new ArrayList<Pickup>();//reset pickups creation array
}
/*
*Reset Landscape resets a few variables like the screen and landscape generators xoffset as well was the flatland boolean and flatlandcounter
 *the inlcine is reset and the the new landscape chain array is created plus updated because within update
 *all previouse landscape chain bodies are properly removed and then the new ones are added
 *
 */
void ResetLandscape() {
  flatLand=false;//reset the boolean that indicates flatland
  xoff=0.0;//set the s offset back to 0
  flatCounter=0;//reset the flatcounter incase player died in the middle of flat creation
  incline=0;//reset the inlcined amount
}



/*
*Update Displays is the main function for updateing the display of everything
 *Starting with landscape and its chain array, then players box's and circle arrays are displayed
 *then each building displays its boxes, same whitheach platform displays itself
 *Then each rope and then each pickup
 */
void UpdateDisplays() {
  landscape.display();//display the landscapes chain
  player.display();//display the player and all its parts
  // Display all the obsticls
  for (Building b : buildings)   b.display();
  for (Platform p : platforms)  p.display();
  for (Rope r : ropes)  r.display();
  for (Pickup p : pickups)p.display();
}



/*
*Update boundaries checks all obsticals in the game to see if they have moved out of screen,
 *If so they are added to their designated toKill list so that at the start of the next frame they can be deleted at the right time
 */
void UpdateBoundaries() {

  //Destroy Obsticls if past window frameon the left side using view offset
  for (Building b : buildings)  if (b.position.x-viewOffset<0)buildingsToKill.add(b);
  for (Platform p : platforms)  if (p.position.x-viewOffset<0)platformsToKill.add(p);  
  for (Rope r : ropes) if (r.position.x-viewOffset<0)ropesToKill.add(r);
}

/*
* DrawHud is responsible for drawing hud elements to the screen.
 *
 */
void drawHud() {


  
  
  
  
}








/*
*Keep in main tab, because landscape is deleted in here so it cant be kept inside landscape.
 *Update Chain Array adds a new point to the lo and top land point arrays
 *then it adds it to the landscape by deleteing the previouse landscape and its body,
 *adding the new point to the START of the srray and then readding their points after that.
 *Then create the new landscape with these points
 */
void UpdateChainArray() {

  float y=0;
  if (flatLand)y= lowLandPoints.get(0).y;//If currenlty in flat land mode then make then y same as previouse y which is end of points array
  else  y = (lowLandPoints.get(0).y-incline+height*.3+map(random(10), 0, 10, -30, 30))/2;//get last point and subtract the current inclined position, then add the amought of screen height then add a random amount

  //adjuster is a variable randomly increasing and reset after a certain hight, that is added to the cielings points array to make it different from the ground array
  if (adjuster>.9) adjuster  -= map(millis()/100, 0, 800000, 0, 1);//if adjuster is over 1, subtract time in millis mapped from 0-8000,000 mapped as 0-1
  else adjuster+=random(0.5);//subtract random amount under .5
  ArrayList<Vec2> newLowLand=new ArrayList<Vec2>();//create new lowland Vec2 array that will get this new point but then the rest of the old array points, and then set it to current landscape
  ArrayList<Vec2> newTopLand=new ArrayList<Vec2>();//same for newTopLand
  newLowLand.add( new Vec2(lowLandPoints.get(0).x+15, y)); //add the new point to the array at 0 but make it 10 over on the x axis
  newTopLand.add( new Vec2(topLandPoints.get(0).x+15, y-height/1.5*adjuster+random(-10-(flatCounter*10), 10-(flatCounter*10)))); //add new point to the topland array at 0, add ten to the x, at the adjuster to the y plus a random



  if (lowLandPoints.size()<500) {
    for (Vec2 v : lowLandPoints) newLowLand.add(v);
    for (Vec2 v : topLandPoints) newTopLand.add(v);
  } else {
    for (int i = 0; i <499; i++) {
      newLowLand.add(lowLandPoints.get(i));
      newTopLand.add(topLandPoints.get(i));
    }
  }

  lowLandPoints = newLowLand;//set low land points to the new low land points
  topLandPoints = newTopLand;// set top land points to the new top land points
  landscape.killBody();//kill the landscapes body
  landscape = new Landscape(topLandPoints, lowLandPoints);//create new landscape with the new top and low points

  xoff+=.01+random(-1, 1);//add a random small amount to the xoff
  
  if(TSLDirectionChange>=directionChangeTime) GetNextDirection();
  TSLDirectionChange++;
  switch (direction) {
    case "UpRight":
    incline+=10;//add ten to the incline
    break;
    case "DownRight":
    incline-=10;//add ten to the incline
    break;
    case "Flat":
    break;
    case "Up":   
    break;
    case "Down":
    break;
    
    
  }
  
  
  
}

void GetNextDirection(){
  TSLDirectionChange=0.0;
  int rand = int(random(5));
  println("roll for   "+ rand);
  switch(rand){
   case 0:direction ="UpRight";break;
   case 1:direction ="DownRight";break;
   case 2:direction ="UpRight";break;
   case 3:direction ="DownRight";break;
   case 4:direction ="UpRight";break;
    
    
  }
  
  
}

/*
*This function is called when adding new terrain to see if a object sshould be added
 *IF under 25 then start flat land section by flipping the boolean
 *if above 75 then add a new rope
 */
void RollForObsticle() {
  int rand = int(random(0, 100));//create a random int between 0 and 100
  if (rand<25) {//if rand is under 25 than new building spot
    flatLand=true;//set fltland to true
  } else if (rand>75) {//if greater than 75 than create new rope
    int n = int(random(2, 12));//create a int for how many boxes on rope
    int l = n*15;//creat int for random length of new rope

    //add this new rope the the ropes creation list with its leangth, amount of boxes, position, 
    //and boolean of false so that it is not realy created yet beacuse the creation list will make it with true
    ropesToCreate.add(new Rope(l, n, topLandPoints.get(0), false));
  }
}
/*
*This function is called durring setup to creat the initial inclined low and high points 
 *used for the terrain
 */
void CreateChainArray() {
  lowLandPoints = new ArrayList<Vec2>();//initiate low land points array list
  topLandPoints = new ArrayList<Vec2>();//initiate top land points array list

  for (float x=width+100; x>-100; x -= 10) {//for every 10 points on the x axis add a point to the array at increasing height
    float y = incline+height*.3;//each y is set to the increasing incline amount plus the screens height time .3
    lowLandPoints.add( new Vec2(x, y));    //add the point to the vector
    y-=height*1.5+random(-10, 10);//subtract the height of the view for the new ceilings point
    topLandPoints.add(new Vec2(x, y));//add the point to the end of the vector

    xoff+=0.1;//add to the xoff
    incline+=10;//add to the incline
  }
  incline=0;//set inlcine back to 0 after creating new array
}





/*
*This function handles the births of most objects in the game
 *It does it in a synchronized order useing arrayLists of objects waiting to be made from the
 *previouse frame
 *****This and the next function HandleDeaths() are key for keeping array lists organized and
 *function else they will break with the adding and deleteing of spots within a frame.
 */
void HandleBirths() {
  //for each platform in the platforms creations array, create the platform at position x and y
  for (Platform p : platformsToCreate) platforms.add(new Platform(p.x, p.y));
  platformsToCreate= new ArrayList<Platform>();//once all are created set the creation list to null
  //for each bulding in the buildings creation list, create that building at the position, with the boolean to actualy create the body and add to main array
  for (Building b : buildingsToCreate) buildings.add( new Building(b.position, true));
  buildingsToCreate = new ArrayList<Building>();//once all are created set the creations list to null
  //for each rope in the ropes creation list, create that rope with its leangth, amount of points, position, and boolean that states the body be made and siaplyed
  for (Rope r : ropesToCreate) ropes.add(new Rope(r.totalLength, r.numPoints, r.position, true));
  ropesToCreate = new ArrayList<Rope>();//once all are created set the array to null


  //for each pickup in te pickup creations array, create it as its set type, at a position with the boolean stating to actualy create the body and add to main lists
  for (Pickup p : pickupsToCreate) pickups.add(new Pickup(p.type, p.position, true));
  pickupsToCreate= new ArrayList<Pickup>();//once all are created then reset the list for next frame
}



/*
*This function handles the deaths of objects added their objects list
 *Once cycling through the kill list each object on the list is removed from their main objects list
 *and then the kill list is emptied for the next frame
 *This helps destroy any object from an array right now and only not to save from arraylist erros
 */
void HandleDeaths() {
  for (Circle c : player.circlesToKill) {
    c.destroyBody();//call function within object that destroys its body from box world
    player.circles.remove(c);//remove object from main list
    player.balloonCount--;
  }
  player.circlesToKill = new ArrayList<Circle>();//reset the death list
  for (Box b : player.boxesToKill) {
    b.destroyBody();//call function within object that destroys its body from box world
    player.boxes.remove(b);//remove object from main list
  }
  player.boxesToKill = new ArrayList<Box>();//reset the death list

  for (Platform p : platformsToKill) {
    p.destroy();//call function within object that destroys its body from box world
    platforms.remove(p);//remove object from main list
  }
  platformsToKill = new ArrayList<Platform>();//reset the death list
  for (Building b : buildings) b.HandleDeaths();
  for (Building b : buildingsToKill) {
    b.destroy();//call function within object that destroys its body from box world
    buildings.remove(b);//remove object from main list
  }
  buildingsToKill = new ArrayList<Building>();//reset the death list


  for (Rope r : ropes) r.HandleDeaths();
  for (Rope r : ropesToKill) {
    r.destroy();//call function within object that destroys its body from box world
    ropes.remove(r);//remove object from main list
  }
  ropesToKill = new ArrayList<Rope>();//reset the death list

  for (Pickup p : pickupsToKill) {
    p.destroy();//call function within object that destroys its body from box world
    pickups.remove(p);//remove object from main list
  }
  pickupsToKill = new ArrayList<Pickup>();//reset the death list
}
/*
*This function handles the presseing of all keys
 *and passes the keycode and state to the input class's handlekey function 
 */
void keyPressed() {
  //println(keyCode);
  in.handleKey(keyCode, true);//call the handle key function within the input class and pass it the pressed key plus the boolean set to true that it is being pressed
}
/*
*This function handles the releasing of all keys
 *and passes the keycode and state to the input class's handlekey function 
 */
void keyReleased() {
  in.handleKey(keyCode, false);//call the handle key function within the input class and pass it the released key plus the boolean set to false that it is being pressed
}