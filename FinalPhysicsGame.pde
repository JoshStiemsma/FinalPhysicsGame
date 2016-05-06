import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

import processing.sound.*;
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



PFont bubble; //Main font

SoundFile pop01;//First pop noise
SoundFile pop02;//Second pop noise
SoundFile pop03;//third pop noise

SoundFile rock01;//rock noise 01
SoundFile rock02;//rock noise 02
SoundFile rock03;//rock noise 03
SoundFile rock04;//rock noise 04
SoundFile rock05;//rock noise 05
SoundFile rock06;//rock noise 06
//Pickup sounds
SoundFile invin;
SoundFile tokenSound;
SoundFile healthSound;



//Image for fading screen to black
PGraphics black;
//value used for alpha of black image for fading
float titleFade = 255;

//boolean used for indicating the game is in starting mode
boolean starting=true;
//Title image
PImage Title;
//The balloon PImages
PImage ballImg01;
PImage ballImg02;
PImage ballImg03;
//Rope and ropeKnot image
PImage ropeKnot;
PImage rope;
//Basket image with addition damgaed basket images
PImage basketImg01;
PImage basketImg02;
PImage basketImg03;
//invincible basket image
PImage basketInv;
//Health Pickup image
PImage health;
//invin pickup image
PImage invincible;
//toke pickup image
PImage token;
//Weight image
PImage weightImg;
//Three color variations of brick image
PImage brick01;
PImage brick02;
PImage brick03;
//UI element images
PImage greenPad;
PImage bluePad;
PImage redPad;
PImage yellowPad;
PImage pedalUI;

//Camera class object named camera
Camera camera;
//Box2d world called box2d
Box2DProcessing box2d;
//Player class object called player
Player player;
//Float for the final distance the player achieved
float finalDistance;
//Game state string starting at "Title" but also uses  "Dead" and"Play"
String gameState = "Title";

////////////Object Arrays w/ Sorting Arrays
ArrayList<Building> buildings = new ArrayList<Building>();//the array of live buildings
ArrayList<Platform> platforms = new ArrayList<Platform>();//the array of live platforms
ArrayList<Rope> ropes = new ArrayList<Rope>();//the array of live ropes
ArrayList<Pickup> pickups = new ArrayList<Pickup>();//the array of live pickups


ArrayList<Platform> platformsToCreate = new ArrayList<Platform>();//the array of platforms that need to be created
ArrayList<Platform> platformsToKill = new ArrayList<Platform>();//the array of live platforms that need to be killed
ArrayList<Building> buildingsToKill = new ArrayList<Building>();//the array of live buildings that need to be killed
ArrayList<Building> buildingsToCreate = new ArrayList<Building>();//the array of buildings that need to be created
ArrayList<Rope> ropesToKill = new ArrayList<Rope>();//the array of live ropes that need to be killed
ArrayList<Rope> ropesToCreate = new ArrayList<Rope>();//the array of ropes that need to be created
ArrayList<Pickup> pickupsToKill = new ArrayList<Pickup>();//the array of live pickups that need to be killed
ArrayList<Pickup> pickupsToCreate = new ArrayList<Pickup>();//the array of pickups that need to be created




/////////////////Landscape class  object named landscape
Landscape landscape;
//String direction starting Flat but also uses UpRight and UpLeft
String direction = "Flat";
//Float TSLDirectionChange stands for Time Since Last Direction Change
//When this reches the set directionChangeTime the terrain picks another direction to go in
Float TSLDirectionChange = 0.0;
//directionChngeTime is an amount predetermined that once the TSLDC reaches the terrain changes direction
float directionChangeTime = 100.0;
//currentGap is a float that is the current distance from the floor to the ceiling
float currentGap = 500.0;
//target Gap is the float that we are trying to get the currentGap to sit at so that when we change the gap it happens gradualy by heading towads the target
float targetGap = 500;

//Array of lowLandPoints passed into a new landscape for the creation of the ground
ArrayList<Vec2> lowLandPoints   = new ArrayList<Vec2>();
//Array of topLAndPoint passed into a new landscape for the creation of the ceiling
ArrayList<Vec2> topLandPoints   = new ArrayList<Vec2>();
///Low and High list in float values for shader
FloatList lowPoints = new FloatList();//MAY NOT NEED THESE BUT LEFT JUST IN CASE
FloatList highPoints = new FloatList();//MAY NOT NEED THESE BUT LEFT JUST IN CASE


float viewOffset;//View offset keeps track of the cameras offset from origin for calculating objects that went off screen and terrain creation
float xoff = 0.0;//xoff is a variable used in terrain creation for the xoffset distance
boolean flatLand = false;//flatland is a boolean used to keep track of if the terrain is in flatmode for a building or not
int flatCounter = 0;//flatCounter keeps track of how longs we have been in flatland for a building so that we can exit at the right time
//increasing Value for incline
float incline = 0;
float adjuster = 2;//Adjuster previously used to very ceiling height, not realy used anymore, kept just in case

//class onbject Input
Input in = new Input();


//float framesSinceLastUpdate;
//float lastUpdate = 0;

//resetGame is a boolean used to tell if the player wants to restart game, once flagged resetGame() gets launched
boolean resetGame= false;
//int containing players score
public int score =0;
//int contaiing points the player has picked up within the round
int pointsPickedUp =0;
//int for highest score achieved
int highScore=0;
//float of time since last game restart, used a lot for per session timers
float timeSinceLastStart=0;
//int for player amount of lives
int lives = 3;
//boolean for if game is within pause or not
boolean paused = false;
//boolean for if puse button has been released to help for smoother restart
boolean pauseReleased =true;



/*
*LoadImages is a function called during setup to load all the images in the beginning
 *
 */
void loadImages() {

  bubble = createFont("Bubblegum.ttf", 64);
  black = createGraphics (width+50, height+50 );
  black.beginDraw();
  black.background(0);
  black.endDraw();
  Title = loadImage("img/Title-01-01.png");
  ballImg01 = loadImage("img/balloonBlue-01.png");
  ballImg02 = loadImage("img/balloonGreen-01.png");
  ballImg03 = loadImage("img/balloonRed-01.png");
  ropeKnot = loadImage("img/ropeKnot.png");
  rope = loadImage("img/rope-01.png");
  basketImg01 = loadImage("img/Player-01.png");
  basketImg02 = loadImage("img/PlayerCrack1-01.png");
  basketImg03 = loadImage("img/PlayerCrack2-01.png");
  basketInv = loadImage("img/PlayerBlue-01.png");
  token = loadImage("img/Token-01.png");
  health =loadImage("img/Health-01.png");
  invincible = loadImage("img/Invincibility-01.png");
  weightImg = loadImage("img/Weight.png");

  brick01 =loadImage("img/brickVariant1-01.png");
  brick02 =loadImage("img/brickVariant2.png");
  brick03 =loadImage("img/brickVariant3-01.png");

  greenPad =loadImage("img/greenPad-01.png");
  redPad =loadImage("img/redPad-01.png");
  bluePad =loadImage("img/bluePad-01.png");
  yellowPad =loadImage("img/yellowPad.png");
  pedalUI =loadImage("img/pedal-01.png");
}
/*
*loadSounds is a function used to load all the sounds at the start in setup
 *
 */
void loadSounds() {
  pop01 =new SoundFile(this, "audio/BalloonBurst01.wav");
  pop02=new SoundFile(this, "audio/BalloonBurst02.wav");
  pop03=new SoundFile(this, "audio/BalloonBurst03.wav");

  rock01=new SoundFile(this, "audio/rock01.wav");
  rock02=new SoundFile(this, "audio/rock02.wav");
  rock03=new SoundFile(this, "audio/rock03.wav");
  rock04=new SoundFile(this, "audio/rock04.wav");
  rock05=new SoundFile(this, "audio/rock05.wav");
  rock06=new SoundFile(this, "audio/rock06.wav");
  invin =new SoundFile(this, "audio/invincible.wav");
  tokenSound =new SoundFile(this, "audio/token.wav");

  //basket01=new SoundFile(this, "basket01.mp3");
  //basket02=new SoundFile(this, "basket02.mp3");
}


//ControlButtons are the controls input objects
ControlButton bttnA;
ControlButton bttnB;
ControlButton bttnX;
ControlButton bttnY;
ControlButton pedal;
ControlButton pause;
ControlButton back;


/*
*setup is ran first and initiates the game with the first frame
 */
void setup() {
  size(900, 600, P2D); //Set up the size of the window and set P2D for a 2D world
  loadImages();//load images
  loadSounds();//load sounds

  //initialize box2d and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();//Create the jBox world
  box2d.setGravity(0, -50);//set the gravity to -50



  //create a Custom Listener class object and set as worlds contact listener
  box2d.world.setContactListener(new CustomListener());
  //player is set to new player
  player=new Player();
  //camera is set to new camera
  camera = new Camera();


  //Controller control grabs instance of this
  ControlIO control = ControlIO.getInstance(this);
  //device is set to getDevice of Harmonix xbox 360 Drum Kit
  ControlDevice device = control.getDevice("Drum Kit (Harmonix Drum Kit for Xbox 360)");
  //Each bttn is assigned its bttn with getButton
  bttnA = device.getButton("Button 0");
  bttnB = device.getButton("Button 1");
  bttnX = device.getButton("Button 2");
  bttnY = device.getButton("Button 3");
  pedal = device.getButton("Button 4");
  pause = device.getButton("Button 7");
  back = device.getButton("Button 6");

  println(control.devicesToText(""));
}


/*
*draw is a function called every frame 
 *
 */
void draw() {

  ///background color stuff
  float r;//red variable fro background color
  if (incline>=10000) r = map(incline, 10000, 20000, 10, 255);//as level progresses up the back get more blue
  else  r = 10;
  float g = 10;//green variable is 10
  float b = map(incline, 0, 10000, 20, 255);//blue is mapped to the incline
  background(r, g, b);//set background to this frames color

  if (gameState=="Title") {//if on Title scree

    pushMatrix();//enter the matrix neo, to shrink the screen 
    scale(.24);//scale title screen
    imageMode(CORNER);//set image mode to center
    image(Title, 0, 0);//present the image
    popMatrix();//shut matrix


    if (in.EnterReleased || bttnA.pressed())resetGame=true;//wait for player to press enter then reset game
    if (resetGame) ResetGame();//if resetGame is true then reset the game by calling the function ResetGame
  } else if (gameState=="Play"||gameState=="Dead") {//if gameState is in Play or Dead, so not Title screen

    pushMatrix();//enter the matrix neo and use players offset Matrix
    translate(-camera.position.x, -camera.position.y);//offset by camera
    if (!paused) {//if game is not paused
      HandleDeaths();//handle all of the deaths
      HandleBirths();//Handle all of the births of all objects
      UpdateDisplays();//update all displays
      UpdateBoundaries();//update all boundaries 
      Update();//update
    } else UpdateDisplays();//if game is paused, only update displays
    popMatrix();//close camera matrix



    drawHud();//draw hud elements

    if (pause.pressed() && pauseReleased == true) {//if paused pressed then toggle paused
      paused=!paused;
      pauseReleased=false;
    }
    if (!pause.pressed()&&pauseReleased==false) pauseReleased=true;


    if (gameState=="Dead"&&back.pressed()) endGame();//if dead and pressed back then endGAme
    if (titleFade>0) {//if Title fade is bigger that 0  show the title with the fading alpha amount
      pushMatrix();//enter the matrix neo and scale size
      scale(.24);//scale size
      imageMode(CORNER);//image mode center
      tint(255, titleFade);//fade the image the given amount
      image(Title, 0, 0);//present the faded image
      popMatrix();//close matrix
      tint(255);///make sure tint is reset
      titleFade-=3;//subtract from title fade amount
    }
  }//end if Dead or Play 


  in.update();//Update input class
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

  if (gameState=="Dead") {//if game state is dead

    if (player.alphaFade<255) {//adjuct alpha value for black screen fading
      player.alphaFade++;
      camera.position = new Vec2(camera.position.x, camera.position.y+3);//adjust camera down once player is dead and falling
    }
    pushStyle();//push a style on
    imageMode(CORNER);//image mode corner
    tint(255, player.alphaFade);//fade image by varying amount player.alphafade
    image(black, camera.position.x, camera.position.y);   //put fading image and caeras position
    popStyle();//get out of style

    pushMatrix();//enter the matris neo
    pushStyle();//you need some style, how much do coats cost in the matrix?
    fill(255);//make sure fill is up to 255
    textAlign(CENTER);//align text in the center
    translate( camera.position.x, camera.position.y);//translate by cameras position
    scale(.5);//scale by half
    text("You Scored  " + int(player.finalDistance), width/2+400, 200);//show player their score
    text("Press back to reset", width/2+400, 300);//tell them to press back 
    popMatrix();//leave the matrix neo

    pushMatrix();//enter the matrix neo

    fill(255);//make sure fill is full
    textAlign(CENTER);//align text in center
    translate( camera.position.x, camera.position.y  );//translate matrix by cam position
    scale(.25);//scale by Quarter
    text("Thanks for Playing", width+800, 1000); //htank the player with text
    fill(255);//make sure fill is 255
    text("by", width+800, 1800); //text
    text("Josh Stiemsma      and      Devon Ducharme", width+800, 2200); //authors text
    popStyle();//retire style
    popMatrix();//leave the matrix neo


    pushMatrix();//Enter The matrix neo
    textAlign(CENTER);//align text in center
    translate( camera.position.x, camera.position.y);//translate matrix by cam position
    scale(.75);//scale to 3/4
    fill(255, 0, 0);//set blue fill
    //stroke(255);//set stroke, doesnt work though
    text("The", width*.5+(sin(millis()/100)/4)*100-100, 500); //the
    fill(0, 255, 0);//green fill
    text("Crate", width*.5+(sin(millis()/100)/4)*50+100, 500); //Crate
    fill(0, 0, 255);//blue fill
    text("Escape", width*.5+(sin(millis()/100)/4)*100+350, 500); //Escape
    popMatrix();//LEAVE THE MATRIX NEO
  }



  //if players basket has hit ground enough to make livs hit 0
  if (lives<=0) {
    gameOver();
    //player.dead=true;
  }
  if (!player.dead) {//if player is alive

    float dist = player.position.x-player.LastTerrainUpdate;//grab the distance the player has moved past the position where the terrain was last updated
    if (dist>=10)landscape.UpdateTerrain();//if the player has moved ten then we need to add ten to the terrain
  } else {//if player is dead  
    gameOver();//game over you dead
  }
}//End update
/*
*The function gameOver is called whent he player has reached the point of death and this calls the phases needed when dead
 */
void gameOver() {
  player.setFinal();//set the final score based on the palyers distance at this time
  finalDistance = player.position.x;//set the final distane to where the palyer is at this time
  player.dead=true;//set the players boolean dead to true
  gameState = "Dead";//set the game State to Dead
  if (player.invincible)player.invincible=!player.invincible;//set the palyers invincability boolean to false for display effect
}
/*
*the function endGame is called after the player has been dead and wants to start a new game
 */
void endGame() {
  gameState="Title";//set the gamestate to Title
  resetArrays();//Reset all the arrays adds all objects to their kill lists, then sets all lists and creation lists to null,but not kill list cause they need to run and self destroy after 
  ResetLandscape();//reset the landscape which destroys the chin arrays bodies as well as its arrays then creates new beginning arrays
  player.destroyBodies(); //destroy the players body
  camera.reset();//reset the camera and its variables
}
/*
*This is the main reset game function that calls individual resets as well as reinitializes thing for the reset
 *Things to be reset are   Arrays   Landscape     Player   and alll previouse box2d bodies must be deleted
 */
void ResetGame() {
  if (starting)player.destroyBodies(); //if we started at the title screen, like we do at start, then destroy the players body tht was created at startt
  starting=false;//set strating boolean to false so we dont do this other than the first time


  CreateChainArray(); //create new chain array
  UpdateChainArray();//in update it kills the body and then makes a landscape into a new landscpe

  //then create new player by setting player to new player
  player = new Player();
  //reset lives to 3; basket damage
  lives=3;
  //reset amount of pickups grabbed
  pointsPickedUp=0;

  camera.position.x=0;//set cam.x to 0
  camera.position.y=0;//set cam.y to 0
  //reset the boolean that triggerd this function
  resetGame=false;
  //set the time since last restart to now so that the next sessions timers and counters will work from this point intead of start of program
  timeSinceLastStart=millis()/1000;

  gameState="Play";//set the game State to play because the game is starting
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
  for (Pickup p : pickups) if (p.position.x-viewOffset<0)pickupsToKill.add(p);
  if (player.position.x-viewOffset<0)player.dead=true;//if player goes too far left then they are dead
}

/*
* DrawHud is responsible for drawing hud elements to the screen.
 *
 */
void drawHud() {

  pushMatrix();//enter the matrix neo

  scale(.2);//shrink the matrix neo
  //these if statements will show their given image if the input bttn being asked is true
  if (bttnA.pressed())image(greenPad, (width-80)/.2, (height-40)/.2);
  if (pedal.pressed())image(pedalUI, (width-50)/.2, (height-40)/.2);
  if (bttnY.pressed())image(yellowPad, (width-140)/.2, (height-40)/.2);
  if (bttnX.pressed())image(bluePad, (width-110)/.2, (height-40)/.2);
  if (bttnB.pressed())image(redPad, (width-170)/.2, (height-40)/.2);

  popMatrix();//leave the matrix neo

}



/*
*Keep in main tab, because landscape is deleted in here so it cant be kept inside landscape.
 *Update Chain Array adds a new point to the lo and top land point arrays
 *then it adds it to the landscape by deleteing the previouse landscape and its body,
 *adding the new point to the START of the srray and then readding their points after that.
 *Then create the new landscape with these points
 */
void UpdateChainArray() {

  float y=0;//set y to 0 at start of update
  if (flatLand)y= lowLandPoints.get(0).y;//If currenlty in flat land mode then make then y same as previouse y which is end of points array
  else  y = (lowLandPoints.get(0).y-incline+height*.3+map(random(10), 0, 10, -30, 30))/2;//get last point and subtract the current inclined position, then add the amought of screen height then add a random amount

  //adjuster is a variable randomly increasing and reset after a certain hight, that is added to the cielings points array to make it different from the ground array
  if (adjuster>2||adjuster<.8) adjuster  =.8;//if adjuster is over 1, subtract time in millis mapped from 0-8000,000 mapped as 0-1
  else adjuster+=random(.01);//subtract random amount under .5

  if (currentGap>targetGap)currentGap-=.5;//adjust the gap to get closer to target gap
  if (currentGap<targetGap)currentGap+=.5;//adjust the gap to get closer to target gap


  float gap = currentGap;//set the gap tot he current gap


  ArrayList<Vec2> newLowLand=new ArrayList<Vec2>();//create new lowland Vec2 array that will get this new point but then the rest of the old array points, and then set it to current landscape
  ArrayList<Vec2> newTopLand=new ArrayList<Vec2>();//same for newTopLand
  newLowLand.add( new Vec2(lowLandPoints.get(0).x+15, y)); //add the new point to the array at 0 but make it 10 over on the x axis
  //newTopLand.add( new Vec2(topLandPoints.get(0).x+15, y-gap*adjuster+random(-10-(flatCounter*10), 10-(flatCounter*10)))); //add new point to the topland array at 0, add ten to the x, at the adjuster to the y plus a random
  if (flatLand&&direction=="UpRight") newTopLand.add( new Vec2(topLandPoints.get(0).x+15, y-gap-flatCounter*6));
  else if ( flatLand&&direction=="DownRight") newTopLand.add( new Vec2(topLandPoints.get(0).x+15, y-gap+flatCounter*6));
  else newTopLand.add( new Vec2(topLandPoints.get(0).x+15, y-gap)); //add new point to the topland array at 0, add ten to the x, at the adjuster to the y plus a random



  if (lowLandPoints.size()<500) {//if array is less that a size of 500
    for (Vec2 v : lowLandPoints) newLowLand.add(v);//add the points of the old array to the new array
    for (Vec2 v : topLandPoints) newTopLand.add(v);//add the points of the old array to the new array
  } else {//else if arrray is bigger than a size of 500
    for (int i = 0; i <499; i++) {//only add 500 points to the new array
      newLowLand.add(lowLandPoints.get(i));//add the points of the old array to the new array
      newTopLand.add(topLandPoints.get(i));//add the points of the old array to the new array
    }
  }

  lowLandPoints = newLowLand;//set low land points to the new low land points
  topLandPoints = newTopLand;// set top land points to the new top land points
  if (landscape!=null)landscape.killBody();//kill the landscapes body
  landscape = new Landscape(topLandPoints, lowLandPoints);//create new landscape with the new top and low points
//if Time Since Last DirectionChange is greater that DirectionChange Time  call the GetNextDirection() Function
  if (TSLDirectionChange>=directionChangeTime) GetNextDirection();
//add to the time since last direction change amount
  TSLDirectionChange++;
  
  switch (direction) {//based off of what direction the string is currently at, adjuct the incline variable
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
/*
*this function Get Next Dirction decides what directiont he terrain will go in next 
*/
void GetNextDirection() {
  TSLDirectionChange=0.0;//reset the TSLDC
  targetGap=random(300, 700);//select a new random target gap
  int rand = int(random(5));//grab a random variable
  switch(rand) {//depending on what we rolled for random we change the direction to a new direction
  case 0:
    direction ="UpRight";
    break;
  case 1:
    direction ="DownRight";
    break;
  case 2:
    direction ="UpRight";
    break;
  case 3:
    direction ="DownRight";
    break;
  case 4:
    direction ="UpRight";
    break;
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
  float j = 400;
  for (float x=width+100; x>-100; x -= 10) {//for every 10 points on the x axis add a point to the array at increasing height
    float y = incline+height*.3;//each y is set to the increasing incline amount plus the screens height time .3
    lowLandPoints.add( new Vec2(x, y));    //add the point to the vector
    y-=height-j+300+random(-10, 10);//subtract the height of the view for the new ceilings point
    topLandPoints.add(new Vec2(x, y));//add the point to the end of the vector
    j-=4;
    //println("j  " + j);
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
  for (Building b : buildings) b.HandleBirths();
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