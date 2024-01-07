ArrayList<Entity> entities = new ArrayList<Entity>();
ArrayList<Entity> nextEntities = new ArrayList<Entity>();
Entity selected;

int MAX_PREDATORS = 40;
int MAX_PREY = 100;

int numPredators = 0;
int numPrey = 0;

boolean drawBrain = true;
boolean drawSelected = true;

void setup_() {
   size(700, 700);
   //entities.add(new Entity(false, 120, 100));
   //entities.add(new Entity(true, 100, 100));
   entities.add(new Entity(true, 150, 120));
   entities.add(new Entity(false, 80, 80));

   selected = entities.get(0);
}

void draw_() {
  background(0);
  for(Entity e : entities) {
    e.draw(e == selected);
  }
  
  fill(255);
  textSize(20);
  text("direction: "+nf(degrees(selected.direction), 0, 2)+" speed: "+nf(selected.speed, 0, 2), 10, 50);
  
  drawBrain();
}

void drawBrain() {
  if(!drawBrain) return;
  stroke(255, 255, 255);
  int mid = selected.brain.inputs.length/2;
  for (int i=0; i < mid; i++) {
    fill(0, 255 * selected.brain.inputs[i].val, 0);
    rect(10, 60 + i*12, 10, 10);
    fill(255 * selected.brain.inputs[i+mid].val, 0, 0);
    rect(30, 60 + i*12, 10, 10);
    } 
}

void setup() {
  size(700, 700);
  
  for (int i = 0; i < MAX_PREDATORS; i++) {
    entities.add(new Entity(true));
    numPredators++;
  }
  
  for (int i=0; i < MAX_PREY; i++) {
    entities.add(new Entity(false));
    numPrey++;
  }
  
   selectRandom();
}

void draw() {
  background(0);
  
  nextEntities = new ArrayList<Entity>();
  
  if(numPredators > MAX_PREDATORS || numPrey > MAX_PREY) {
      Entity oldestPrey = null;
      Entity oldestPredator = null;
      for(Entity e : entities) {
        if(e.isPredator && (oldestPredator == null || oldestPredator.birthTime > e.birthTime)) {
          oldestPredator = e;
        } else if (!e.isPredator && (oldestPrey == null || oldestPrey.birthTime > e.birthTime)) {
          oldestPrey = e;
        }
      }
      if(numPredators > MAX_PREDATORS) oldestPredator.isAlive = false;
      if(numPrey > MAX_PREY) oldestPrey.isAlive = false;
  }
  
  for (int i = 0; i < entities.size(); i++) {
    Entity entity = entities.get(i);
    if (entity.isAlive) {
      nextEntities.add(entity);
    } else {      
      if(entity.isPredator) {
        numPredators--;
      } else {
        numPrey--;
      }
      continue;
    }
    
    entity.update(entities);
    noStroke();
    entity.draw(drawSelected && (entity == selected));
    
    if (entity.isSplitting) {
      if(entity.isPredator) { 
        nextEntities.add(entity.split());
        numPredators++;
      } else if (!entity.isPredator) {
        nextEntities.add(entity.split());
        numPrey++;
      }
    }    
  }
  
  entities = nextEntities;
  
  if(!selected.isAlive) {
    selectRandom();
  }
  
  fill(255);
  textSize(20);
  text("prey: "+numPrey+" predators: "+numPredators, 10, 20);
  
  if(drawSelected) {
    text("direction: "+int(degrees(selected.direction))+" speed: "+nf(selected.speed, 0, 2)+" energy: "+selected.energy, 10, 50);
  }
  
  drawBrain();
}

void mousePressed() {
  
  if(keyPressed) {
    if(keyCode == SHIFT) {
      selected.position.x = mouseX;
      selected.position.y = mouseY;
    } else {
      float angle = normalizeAngle(atan2(mouseY - selected.position.y, mouseX - selected.position.x));
      selected.direction = angle;
    }
  } else {
    
    PVector m = new PVector(mouseX, mouseY);
    for(Entity entity : entities) {
      if(entity.position.dist(m) < entity.RAD) {
        selected = entity;
        break;
      }
    }
  }
  selected.updateBrain(entities);
}

void selectRandom() {
  selected = entities.get(int(random(entities.size())));
}

void keyPressed() {
  if (keyCode == UP) {
    selectRandom();
  }
  
  if (key == 'b') {
     drawBrain = !drawBrain;
  }
  
  if (key == 's') {
    drawSelected = !drawSelected;
  }
  
  if(key == 'u') {
    selected.update(entities);
  }
}
