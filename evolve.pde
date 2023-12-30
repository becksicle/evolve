ArrayList<Entity> entities = new ArrayList<Entity>();
ArrayList<Entity> nextEntities = new ArrayList<Entity>();
Entity selected;

void draw() {
  background(0);
  
  nextEntities = new ArrayList<Entity>();
  
  for (int i = 0; i < entities.size(); i++) {
    Entity entity = entities.get(i);
    
    entity.update(entities);
    entity.draw();
    
    if (entity.isAlive) nextEntities.add(entity);
  }
  
  entities = nextEntities;
}

void setup() {
  //Brain b = new Brain();
  size(700, 700);
  
  entities.add(new Predator(500, 500));
  entities.add(new Prey(100, 100));
  
  selected = entities.get(0);
}

void mousePressed() {
  float angle = atan2(mouseY - selected.position.y, mouseX - selected.position.x);
  selected.direction = angle;
}