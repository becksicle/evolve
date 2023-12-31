/*  
  For predators:
     - movements use energy
     - eating prey gives energy
     - no energy means death
     - during digestion, no energy gained from eating prey
     
  For prey:
     - 0 energy means no movement
     - staying still gives energy
     - if live long enough, they split
*/

class Entity {
  // radius of entities
  static final float RAD = 20;
  
  // energy gained when predator eats prey
  static final float ENERGY_ON_EAT = 20;
  
  // time required to digest prey in milliseconds
  static final float DIGESTION_TIME = 750;
  
  // how long prey need to stay alive to split
  static final float REPRODUCTION_TIME = 3500;

  // above and below their direction of travel
  static final float PREDATOR_FOV = 0.785398; // 45 degrees
  static final float PREY_FOV = 2.79253; // 160 degrees
  
  // discretize field of view into 10 degree steps
  static final float FOV_STEP = 0.174533; // 10 degrees
  
  // how far an entity can see within their FOV in pixels
  static final float VIEW_DISTANCE = 150; 

  boolean isPredator;
  float birthTime = millis();
  float direction = random(TWO_PI);
  float speed = 1;
  float energy = random(250, 500); 
  float lastEatTime;
  PVector position;
  boolean isAlive = true;
  boolean isSplitting = false;
  int foodConsumed = 0;
  color col;
  Brain brain;
  
  
  Entity(boolean isPredator) {
    this(isPredator, random(width), random(height));
  }
  
  Entity(boolean isPredator, float x, float y) {
    this.isPredator = isPredator;
    brain = new Brain(isPredator ? 2*calcNumFOVRays() : 
          2*calcNumFOVRays());

    position = new PVector(x, y);
    
    if(isPredator) {
      col = color(255, 0, 0);
    } else {
      col = color(0, 255, 0);
    }
  }
  
  int calcNumFOVRays() {
    return isPredator ? round((2*PREDATOR_FOV) / FOV_STEP)+1 : 
          round((2*PREY_FOV) / FOV_STEP)+1;
  }
  
  void draw(boolean isSelected) {
    fill(col);
    circle(position.x, position.y, RAD);
    
    float fov = (isPredator ? PREDATOR_FOV : PREY_FOV);
    
    if (isSelected) {
      stroke(100, 100, 100);
      for(int i=0; i < calcNumFOVRays(); i++) {
        float angle = i * FOV_STEP;
        // 0 should be -fov
        angle = angle - fov;
        angle += direction;
        line(position.x, position.y, position.x + VIEW_DISTANCE*cos(angle), position.y+VIEW_DISTANCE*sin(angle));
      }
      stroke(255, 255, 0);
      line(position.x, position.y, position.x + (10+VIEW_DISTANCE)*cos(direction), position.y+(10+VIEW_DISTANCE)*sin(direction));
      
    }
  }
  
  void move(ArrayList<Entity> entities) {
    brain.calculateOutput();
    
    direction = 2 * PI * brain.outputs[0].val;
    speed = 2 * brain.outputs[1].val;
    
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
        if ((this.isPredator == other.isPredator) || 
            (this.isPredator && this.isDigesting()) || 
            (other.isPredator && other.isDigesting())) {
          // nothing for now
        } else {
          if (this.isPredator) {
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
    return (millis() - lastEatTime) < DIGESTION_TIME;
  }
  
  void updateBrain(ArrayList<Entity> entities) {
    brain.resetInputs();
    
    for(Entity test : entities) {
      if(test == this) continue;     
      
      float dist = position.dist(test.position);
        
      if(dist > VIEW_DISTANCE) continue;
      
      // calculate angle from center of entity to center of test entity
      float angle = normalizeAngle(atan2(test.position.y - this.position.y, test.position.x - this.position.x));
      
      // adjust for the direction the entity is facing
      angle -= direction;
      
      // normalize to 0 to 2 * FOV
      float fov = isPredator ? PREDATOR_FOV : PREY_FOV;
      angle += fov;
      
      // test is outside FOV
      if(angle < 0 || angle > 2 * fov) continue;
      
      // inside fov - snap to angle
      float findex = angle / FOV_STEP;
      
      int floorIndex = (int)findex;
      int ceilIndex = floorIndex+1;
      
      if(test.isPredator) {
        // prey will take the first inputs, and predator will come next
        int numRays = calcNumFOVRays();
        floorIndex += numRays;
        ceilIndex += numRays;
      }
      
      float normDist = (VIEW_DISTANCE - dist) / VIEW_DISTANCE;
      
      brain.inputs[floorIndex].val = max(brain.inputs[floorIndex].val, normDist);
      brain.inputs[ceilIndex].val = max(brain.inputs[ceilIndex].val, normDist);
    }
    
  }
  
  void update(ArrayList<Entity> entities) {
    updateBrain(entities);
    
    if(energy > 0) this.move(entities);
 
    if(isPredator) {
      if (energy <= 0) this.isAlive = false;
      if (foodConsumed >= 3) this.isSplitting = true;
    } else {
      // prey specific updates
      if (speed <= 0) energy++; // figure out units
      if ((millis() - birthTime) > REPRODUCTION_TIME) this.isSplitting = true;
    }
  }
  
  Entity split() {
    this.foodConsumed = 0;
    this.isSplitting = false;
    this.birthTime = millis();
    this.position.x -= RAD;
    Entity e = new Entity(isPredator, this.position.x+RAD, this.position.y);
    e.brain = new Brain(brain);
    return e;
  }
}

float normalizeAngle(float angle) {
  float  tp = 2.0*PI;
  angle = angle % tp;
  if(angle < 0) angle = tp + angle;
  return angle;
}
