class Camera {
  float xOffset = player.position.x-player.startingPosition.x;
  float yOffset = 0;
  Vec2 position = new Vec2(0, player.position.y);

  


  void update() {

    //float dist = player.position.x-playerPrevPos.x;
    //if (dist>0&&yOffset<=0) {
    //  xOffset+=dist;
    //} else if (dist>0&&yOffset>0) {
    //  yOffset-=dist;
    //} else if (dist<0) {
    //  yOffset-=dist;
    //}
    //xOffset = player.position.x-player.startingPosition.x; 
    //position = new Vec2(player.startingPosition.x+xOffset, player.position.y-player.startingPosition.y);

    //playerPrevPos = player.position;
  }

  void reset() {
    xOffset = -500;
    yOffset = 0;
    player.playerPrevPos = player.startingPostionVec;
    position = new Vec2(0, player.position.y);
  }
}