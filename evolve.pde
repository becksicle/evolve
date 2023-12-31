ArrayList<Entity> entities = new ArrayList<Entity>();
ArrayList<Entity> nextEntities = new ArrayList<Entity>();
Entity selected;

int MAX_PREDATORS = 100;
int MAX_PREY = 100;

int numPredators = 0;
int numPrey = 0;

void setup_() {
   size(700, 700);
   entities.add(new Entity(false, 120, 100));
   entities.add(new Entity(true, 100, 100));
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
  text("direction: "+degrees(selected.direction)+" speed: "+selected.speed+" brain 0: "+selected.brain.outputs[0].val, 10, 50);
  
  drawBrain();
}

void drawBrain() {
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
    entity.draw(entity == selected);
    
    if (entity.isSplitting) {
      if(entity.isPredator && numPredators < MAX_PREDATORS) {
        nextEntities.add(entity.split());
        numPredators++;
      } else if (!entity.isPredator && numPrey < MAX_PREY) {
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
  text("direction: "+degrees(selected.direction)+" speed: "+selected.speed+" brain 0: "+selected.brain.outputs[0].val, 10, 50);
  
  drawBrain();
}

void mousePressed() {
  
  if(keyPressed) {
    selected.position.x = mouseX;
    selected.position.y = mouseY;
  } else {
    float angle = normalizeAngle(atan2(mouseY - selected.position.y, mouseX - selected.position.x));
    //float angle = atan2(mouseY - selected.position.y, mouseX - selected.position.x);
    selected.direction = angle;
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
}
