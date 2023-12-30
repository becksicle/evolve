abstract class Entity {
  static final float RAD = 20;
  
  public float direction = random(TWO_PI);
  public float speed = 1;
  public float energy = 10000; 
  public PVector position;
  public boolean isAlive = true;
  color col;
  
  void draw() {
    fill(col);
    circle(position.x, position.y, RAD);
  }
  
  void move(ArrayList<Entity> entities) {
    if (speed <= 0) return;
    
    float vx = speed * cos(direction);
    float vy = speed * sin(direction);
    
    position.add(new PVector(vx, vy));
    
    if (position.x < 0) position.x = width;
    if (position.x > width) position.x = 0;
    if (position.y < 0) position.y = height;
    if (position.y > height) position.y = 0;
    
    energy -= speed;
  
    for (Entity other: entities) {
      if (other == this) continue;
      
      float dist = PVector.sub(this.position, other.position).mag();
      
      if (dist < RAD) {
        boolean thisIsPredator = this instanceof Predator;
        boolean otherIsPredator = other instanceof Predator;
        
        if ((thisIsPredator && otherIsPredator) || (!thisIsPredator && !otherIsPredator)) {
          this.direction += PI;
          other.direction += PI;
        } else {
          if (thisIsPredator) other.isAlive = false;
          else this.isAlive = false;
        }
      }
    }
  }
  
  abstract void update(ArrayList<Entity> entities);
  
  public Entity(float x, float y) {
    this.position = new PVector(x, y);
  }
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
  public float lastEatTime;
  public float foodConsumed;
  
  public Predator(float x, float y) {
    super(x, y);
    
    this.col = color(255, 0, 0);
  }
  
  void update(ArrayList<Entity> entities) {
    this.move(entities);
    
    // die if no energy
  }
}

class Prey extends Entity {
  public float birthTime;
  // 0 energy means no movement
  // staying still gives energy
  // if live long enough, they split
  
  public Prey(float x, float y) {
    super(x, y);
    
    col = color(0, 255, 0);
  }
  
  void update(ArrayList<Entity> entities) {
    if (energy > 0) move(entities);
    if (speed <= 0) energy++; // figure out units
  }
}