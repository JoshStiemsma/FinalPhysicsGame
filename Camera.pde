//camera class is used to follow the player and keep things centered around that
class Camera {
  float xOffset = -500;//the xoffset starts at -500
  float yOffset = 0;//yoffset starts at 0
  Vec2 position = new Vec2(0, player.position.y);//the y position starts at 0 and player position


/*
*The function reset, resets variabls within caera between games that need to be reset, and thats all of them
*/
  void reset() {
    xOffset = -500;
    yOffset = 0;
    player.playerPrevPos = player.startingPostionVec;
    position = new Vec2(0, player.position.y);
  }
}