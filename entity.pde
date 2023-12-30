abstract class Entity {
  static final float RAD = 20;
  static final float ENERGY_ON_EAT = 20;
  
  public float direction = random(TWO_PI);
  public float speed = 1;
  public float energy = random(250, 500); 
  public PVector position;
  public boolean isAlive = true;
  public boolean isSplitting = false;
  public float lastEatTime;
  public int foodConsumed = 0;
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
        
        if ((thisIsPredator == otherIsPredator) || (thisIsPredator && this.isDigesting()) || (otherIsPredator && other.isDigesting())) {
          this.direction += PI;
          other.direction += PI;
        } else {
          if (thisIsPredator) {
            other.isAlive = false;
            this.lastEatTime = millis();
            this.energy += ENERGY_ON_EAT;
            this.foodConsumed++;
          } else {
            this.isAlive = false;
            other.lastEatTime = millis();
            other.energy += ENERGY_ON_EAT;
            other.foodConsumed++;
          }
        }
      }
    }
  }
  
  boolean isDigesting() {
    return false;
  }
  
  abstract void update(ArrayList<Entity> entities);
  abstract Entity split();
  
  public Entity(float x, float y) {
    this.position = new PVector(x, y);
  }
  
  public Entity() {
    this.position = new PVector(random(width), random(height));
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
  // time require to digest prey in milliseconds
  static final float DIGESTION_TIME = 1000;
  
  public Predator(float x, float y) {
    super(x, y);
    
    this.col = color(255, 0, 0);
  }
  
  public Predator() {
    super();
    
    this.col = color(255, 0, 0);
  }
  
  void update(ArrayList<Entity> entities) {
    this.move(entities);
    
    if (energy <= 0) this.isAlive = false;
    if (foodConsumed >= 3) this.isSplitting = true;
  }
  
  boolean isDigesting() {
    return (millis() - lastEatTime) < DIGESTION_TIME;
  }
  
  Entity split() {
    this.foodConsumed = 0;
    this.isSplitting = false;
    return new Predator(this.position.x, this.position.y);
  }
}

class Prey extends Entity {
  static final float REPRODUCTION_TIME = 3500;
  
  public float birthTime = millis();
  // 0 energy means no movement
  // staying still gives energy
  // if live long enough, they split
  
  public Prey(float x, float y) {
    super(x, y);
    
    col = color(0, 255, 0);
  }
  
  public Prey() {
    super();
    
    this.col = color(0, 255, 0);
  }
  
  Entity split() {
    this.birthTime = millis();
    this.isSplitting = false;
    return new Prey(this.position.x, this.position.y);
  }
  
  void update(ArrayList<Entity> entities) {
    if (energy > 0) move(entities);
    if (speed <= 0) energy++; // figure out units
    if ((millis() - birthTime) > REPRODUCTION_TIME) this.isSplitting = true;
  }
}
