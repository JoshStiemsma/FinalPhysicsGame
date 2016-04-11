public class Input {

  boolean Left = false;
  boolean Right = false;
  boolean Up = false;
  boolean Enter = false;
  void handleKey(int keyCode, boolean state) {
    switch(keyCode) {
    case 37:
      Left = state;
      break;
    case 38:
      Up = state;
      break;
    case 39:
      Right=state;
      break;
    case 10:
      Enter=state;
      break;
    }
  }
}