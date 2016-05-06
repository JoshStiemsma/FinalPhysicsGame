//this input class handles the keyboards input
public class Input {

  boolean Left = false;//boolean for left button
  boolean Right = false;//boolean for right button
  boolean Up = false;//boolean for up button
  boolean Down = false;//boolean for down button
  boolean Enter = false;//boolean for enter button
  boolean EnterReleased = false;//boolean for enter being released 
  boolean Space = false;//boolean for space button
  boolean Pause = false;//boolean for pause button
  
  /*
  *this function update is called every frame in main update
  */
  void update(){
   if(EnterReleased) EnterReleased=!EnterReleased; //if enter has been released then togle enter released
  }

/*
*this function handle key, handles the keycode and state of the button being pressed and passed in, it also then toggles the boolean of the
*corrilating button boolean
*/
  void handleKey(int keyCode, boolean state) {
    switch(keyCode) {
    case 32:
      Space=state;
      break;
    case 37:
      Left = state;
      break;
    case 38:
      Up = state;
      break;
    case 39:
      Right=state;
      break;
    case 40:
      Down=state;
      break;
    case 10:
    if(state==false) EnterReleased=true;
      Enter=state;
      break;
    case 80:
      Pause=state;
      break;
    }
  }
}