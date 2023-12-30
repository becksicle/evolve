ArrayList<Entity> entities = new ArrayList<Entity>();
ArrayList<Entity> nextEntities = new ArrayList<Entity>();
Entity selected;

void draw() {
  background(0);
  
  nextEntities = new ArrayList<Entity>();
  
  for (int i = 0; i < entities.size(); i++) {
    Entity entity = entities.get(i);
    if (!entity.isAlive) continue;
    
    entity.update(entities);
    entity.draw();
    
    if (entity.isAlive) nextEntities.add(entity);
    if (entity.isSplitting) nextEntities.add(entity.split());
  }
  
  entities = nextEntities;
}

void setup() {
  //Brain b = new Brain();
  size(700, 700);
  
  for (int i = 0; i < 100; i++) {
    entities.add(new Entity(true));
    entities.add(new Entity(false));
  }
  
  selected = entities.get(0);
}

void mousePressed() {
  float angle = atan2(mouseY - selected.position.y, mouseX - selected.position.x);
  selected.direction = angle;
}
