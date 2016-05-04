class Camera {
  //float xOffset = player.position.x-player.startingPosition.x;
  float xOffset = -500;
  float yOffset = 0;
  Vec2 position = new Vec2(0, player.position.y);

  


  void update() {

  }

  void reset() {
    xOffset = -500;
    yOffset = 0;
    player.playerPrevPos = player.startingPostionVec;
    position = new Vec2(0, player.position.y);
  }
}