public class Input {

  boolean Left = false;
  boolean Right = false;
  boolean Up = false;
  boolean Down = false;
  boolean Enter = false;
  boolean Space = false;

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
      Enter=state;
      break;
    }
  }
}