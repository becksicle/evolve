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
  static final float ENERGY_ON_EAT = 175;

  // time required to digest prey in milliseconds
  static final float DIGESTION_TIME = 75;

  // how long prey need to stay alive to split
  static final float REPRODUCTION_TIME = 8000;

  // predators will die after this amount of time
  static final float PREDATOR_LIFETIME = 30000;

  // above and below their direction of travel
  static final float PREDATOR_FOV = 0.785398; // 45 degrees
  static final float PREY_FOV = 2.79253; // 160 degrees

  // discretize field of view into 10 degree steps
  static final float FOV_STEP = 0.174533; // 10 degrees

  // how far prey can see within their FOV in pixels
  static final float PREY_VIEW_DISTANCE = 150;

  // how far prey can see within their FOV in pixels
  static final float PREDATOR_VIEW_DISTANCE = 300;

  boolean isPredator;
  float birthTime = millis();
  float direction = random(TWO_PI);
  float speed = 1;
  float energy = 500;
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

    //fudgeBrain();
    position = new PVector(x, y);

    if (isPredator) {
      col = color(225, 50, 50);
    } else {
      col = color(50, 225, 50);
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
      float vd = isPredator ? PREDATOR_VIEW_DISTANCE : PREY_VIEW_DISTANCE;
      stroke(100, 100, 100);
      for (int i=0; i < calcNumFOVRays(); i++) {
        float angle = i * FOV_STEP;
        // 0 should be -fov
        angle = angle - fov;
        angle += direction;
        line(position.x, position.y, position.x + vd*cos(angle), position.y+vd*sin(angle));
      }
      stroke(255, 255, 0);
      line(position.x, position.y, position.x + (10+vd)*cos(direction), position.y+(10+vd)*sin(direction));
    }
  }

  void move(ArrayList<Entity> entities) {
    brain.calculateOutput();
    //println("o1: "+brain.outputs[0].val+ " o2: "+brain.outputs[1].val);

    float inc =  0.1 * brain.outputs[0].val;
    direction += inc;
    direction = normalizeAngle(direction);
    speed = brain.outputs[1].val;

    if (speed <= 0) return;

    float vx = speed * cos(direction);
    float vy = speed * sin(direction);

    position.add(new PVector(vx, vy));

    if (position.x < 0) position.x = width;
    if (position.x > width) position.x = 0;
    if (position.y < 0) position.y = height;
    if (position.y > height) position.y = 0;

    energy -= speed;

    for (Entity other : entities) {
      if (other == this) continue;

      float dist = PVector.sub(this.position, other.position).mag();

      if (dist < RAD) {
        if ((this.isPredator == other.isPredator) ||
          (this.isPredator && this.isDigesting()) ||
          (other.isPredator && other.isDigesting())) {
          // choose a random direction and make the 2 entities go in opposites
          other.direction = normalizeAngle(-direction);
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

    for (Entity test : entities) {
      if (test == this) continue;

      float dist = position.dist(test.position);

      float vd = isPredator ? PREDATOR_VIEW_DISTANCE : PREY_VIEW_DISTANCE;
      if (dist > vd) continue;

      // calculate angle from center of entity to center of test entity
      float angle = normalizeAngle(atan2(test.position.y - this.position.y, test.position.x - this.position.x));

      // adjust for the direction the entity is facing
      angle -= direction;

      // normalize to 0 to 2 * FOV
      float fov = isPredator ? PREDATOR_FOV : PREY_FOV;
      angle += fov;

      // test is outside FOV
      if (angle < 0 || angle > 2 * fov) continue;

      // inside fov - snap to angle
      float findex = angle / FOV_STEP;

      int floorIndex = (int)findex;
      int ceilIndex = floorIndex+1;

      if (test.isPredator) {
        // prey will take the first inputs, and predator will come next
        int numRays = calcNumFOVRays();
        floorIndex += numRays;
        ceilIndex += numRays;
      }

      float normDist = (vd - dist) / vd;
      //normDist = 1.0;

      if (floorIndex < brain.inputs.length) {
        brain.inputs[floorIndex].val = max(brain.inputs[floorIndex].val, normDist);
      }

      if (ceilIndex < brain.inputs.length) {
        brain.inputs[ceilIndex].val = max(brain.inputs[ceilIndex].val, normDist);
      }
    }
  }

  void fudgeBrain() {
    if (!isPredator) {
      return;
    }

    for (int i=0; i < brain.outputs[0].weights.length; i++) {
      brain.outputs[0].weights[i] = 1;
      brain.outputs[1].weights[i] = 0;
    }

    // 0:  FOV
    // calcNumOfRays /2 : 0
    // len: -FOV
    for (int i=0; i < calcNumFOVRays(); i++) {
      brain.outputs[0].weights[i] = PREDATOR_FOV - (calcNumFOVRays()-i)*FOV_STEP;
      brain.outputs[1].weights[i] = 1;
    }

    brain.outputs[0].bias = 0.1;
    brain.outputs[1].bias = 0.5;
  }

  void update(ArrayList<Entity> entities) {
    updateBrain(entities);
    if (energy <= 0) {
      speed = 0;
    } else {
      this.move(entities);
    }

    if (isPredator) {
      if (energy <= 0 || (millis() - birthTime) > PREDATOR_LIFETIME) this.isAlive = false;
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
    e.brain.mutate();
    return e;
  }
}

float normalizeAngle(float angle) {
  float  tp = 2.0*PI;
  angle = angle % tp;
  if (angle < 0) angle = tp + angle;
  return angle;
}
