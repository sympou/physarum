
float globalForesee = 1;
float globalAngleLerp = 0.2;
float globalSpeed = 0.3;

int xS = 100;
int yS = 100;

Spot[][] spots = new Spot[xS][yS];
ArrayList<Spot> spotsArray = new ArrayList<Spot>();

PVector spotSize;

ArrayList<Particle> particles = new ArrayList<Particle>();

void setup() {
  size(700, 700);
  spotSize = new PVector((float)width/xS, (float)height/yS);
  for (int x = 0; x<xS; x++) {
    for (int y = 0; y<yS; y++) {
      Spot thisSpot = new Spot(x, y);
      spots[x][y] = thisSpot;
      spotsArray.add(thisSpot);
    }
  }
  for (int x = 0; x<xS; x++) {
    for (int y = 0; y<yS; y++) {
      for (int x2 = -1; x2<2; x2++) {
        for (int y2 = -1; y2<2; y2++) {
          if (x2!=0||y2!=0) spots[x][y].neighbors.add(spots[(x+x2+xS)%xS][(y+y2+yS)%yS]);
          //if (x2==0^y2==0)
        }
      }
    }
  }
  for (int i=0; i<5000; i++) {
    //particles.add(new Particle(random(xS), random(yS), random(0, TWO_PI)));
    particles.add(new Particle(i%xS, (i*10)%yS, i));
  }
}

void draw() {
  background(0);
  // auto-randomize
  if (frameCount%50==0) randomizeParameters();
  // update
  for (Spot spot : spotsArray) spot.spread();
  for (Spot spot : spotsArray) spot.spreadUpdate();
  for (Spot spot : spotsArray) spot.decay();
  for (Particle particle : particles) particle.update();
  // draw
  for (Spot spot : spotsArray) spot.draw();
  for (Particle particle : particles) particle.draw();
  // saveFrame("results/00_result####.png");
}

class Spot {
  int x, y;
  PVector pos;
  float pheromonal = 0;
  float pheromonalUpdate = 0;
  ArrayList<Spot> neighbors = new ArrayList<Spot>();
  Spot(int x, int y) {
    this.x = x;
    this.y = y;
    pos = new PVector(x*spotSize.x, y*spotSize.y);
  }
  void spread() {
    float part = (pheromonal*0.6f)/neighbors.size();
    for (Spot spot : neighbors) {
      spot.pheromonalUpdate+=part;
      pheromonalUpdate-=part;
    }
  }
  void spreadUpdate() {
    pheromonal += pheromonalUpdate;
    pheromonalUpdate = 0;
  }
  void decay() {
    pheromonal = max(pheromonal*0.99, 0);
    pheromonal = (float)Math.tanh(pheromonal);
  }
  void draw() {
    noStroke();
    fill(0, 0, constrain(pheromonal*0x80, 0, 0xFF));
    rect(pos.x, pos.y, spotSize.x, spotSize.y);
  }
}

class Particle {
  PVector position;
  float angle;
  float speed = 0.3f;
  float foresee = 1;
  float angleLerp = 0.2f;
  Particle (float x, float y, float angle) {
    position = new PVector(x, y);
    this.angle = angle;
  }
  void update() {
    // update variables
    foresee = globalForesee;
    angleLerp = globalAngleLerp;
    speed = globalSpeed;
    // direct
    float newAngle = angle;
    float bestSpot = -1;
    float range = 1.0f;
    int nbProbes = 5;
    for (int i=0; i<nbProbes; i++) {
      float aD = -range + (float)i*(range*2)/(nbProbes-1);
      PVector projectedPos = new PVector(position.x+cos(angle+aD)*foresee, position.y+sin(angle+aD)*foresee);
      float thisPheromonal = spots[round(projectedPos.x+xS)%xS][round(projectedPos.y+yS)%yS].pheromonal;
      if (thisPheromonal>bestSpot) {
        bestSpot = thisPheromonal;
        newAngle = angle + aD;
      }
    }
    angle = lerp(angle, newAngle, angleLerp);
    // move
    position.x+=cos(angle)*speed;
    position.y+=sin(angle)*speed;
    position.x=(position.x+xS)%xS;
    position.y=(position.y+yS)%yS;
    // deposit
    spots[round(position.x)%xS][round(position.y)%yS].pheromonal += 0.05;
  }  
  void draw() {
    noStroke();
    fill(0xFF, 0, 0, 0x20);
    ellipse((position.x+0.5f)*spotSize.x, (position.y+0.5f)*spotSize.y, spotSize.x/2, spotSize.y/2);
  }
}

void mousePressed() {
  randomizeParameters();
}

void randomizeParameters() {
  globalForesee = random(0, 5);
  globalAngleLerp = random(0, HALF_PI);
  globalSpeed = random(0.2, 1.2);
}
