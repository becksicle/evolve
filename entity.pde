class Entity {
  public float direction;
  public float speed;
  public float energy; 

}

/*
  For predators:
   - movements use energy
   - eating prey gives energy
   - no energy means death
   - during digestion, no energy gained from eating prey
*/
class Predator extends Entity {
  // time require to digest prey in seconds
  static final float DIGESTION_TIME = 5;
  static final float ENERGY_TO_MOVE = 2;
  
  // time this predator has spent digesting
  public float elapsedDigestionTime;
  
  
}

class Prey extends Entity {
    public float splitTime;
  // 0 energy means no movement
  // staying still gives energy
  // if live long enough, they split
}
