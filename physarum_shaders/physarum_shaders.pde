//original code and project by Morusque !
//https://github.com/Morusque/physarum

PShader updateParticlesPosShader;
PShader updateParticlesAngShader;
PShader updatePheromonesShader;
PShader addParticlesShader;
PShader seeParticlesShader;
PShader seePheromonesShader;

PGraphics dataX;
PGraphics dataY;
PGraphics dataAng;
PGraphics pheromones;

PImage bufferImg;

PShape particles;

// variables

int dataSize = 100; //dataSize*dataSize = number of particules

float speed = 2.0;
float rotAngle = 0.2;
float foresee = 4.0;
float particleFov = 0.1; //a new variable !

float pheroDecay   = 0.99;
float pheroDropped = 0.05;
float particleSize = 2.0;

void setup() {
  fullScreen(P2D);
  //size(1000, 500, P2D);
  noSmooth();

  // pheromones
  pheromones = createGraphics(width, height, P2D);
  pheromones.noSmooth();
  
  // particules, in a PShape object 
  particles = createShape();
  particles.beginShape(QUADS);
  particles.noStroke();
  for (int n = 0; n < dataSize*dataSize; n ++) {
    particles.vertex(-0.5,-0.5, n);
    particles.vertex(-0.5, 0.5, n);
    particles.vertex( 0.5, 0.5, n);
    particles.vertex( 0.5,-0.5, n);
  }
  particles.endShape();
  
  // shaders
  addParticlesShader = loadShader("addParticlesF.glsl", "addParticlesV.glsl");
  addParticlesShader.set("dataSize", float(dataSize));
  addParticlesShader.set("pheroDropped", pheroDropped);
  addParticlesShader.set("particleSize", particleSize);

  seeParticlesShader = loadShader("seeParticlesF.glsl", "seeParticlesV.glsl");
  seeParticlesShader.set("dataSize", float(dataSize));
  seeParticlesShader.set("particleSize", particleSize);

  updateParticlesPosShader = loadShader("updateParticlesPosF.glsl");
  updateParticlesPosShader.set("pheroRes", float(width), float(height));
  updateParticlesPosShader.set("speed", speed);

  updateParticlesAngShader = loadShader("updateParticlesAngF.glsl");
  updateParticlesAngShader.set("pheroRes", float(width), float(height));
  updateParticlesAngShader.set("foresee",     foresee);
  updateParticlesAngShader.set("particleFov", particleFov);
  updateParticlesAngShader.set("rotAngle",    rotAngle);

  updatePheromonesShader = loadShader("updatePheromonesF.glsl");
  updatePheromonesShader.set("pheroDecay", pheroDecay);

  seePheromonesShader = loadShader("seePheromonesF.glsl");

  initData();
}

void initData() {
  // coords + angles in 3 PGraphics objects
  bufferImg = createImage(dataSize, dataSize, RGB);
  bufferImg.loadPixels();
  
  for (int i = 0; i < bufferImg.pixels.length; i++) {
    bufferImg.pixels[i] = color(random(255), random(255), random(255)); 
  }
  bufferImg.updatePixels();
  
  dataX = createGraphics(dataSize, dataSize, P2D);
  dataX.noSmooth();
  dataX.beginDraw();
  dataX.endDraw();
  dataX.beginDraw();
    dataX.image(bufferImg,0,0);
  dataX.endDraw();

  for (int i = 0; i < bufferImg.pixels.length; i++) {
    bufferImg.pixels[i] = color(random(255), random(255), random(255)); 
  }
  bufferImg.updatePixels();
  
  dataY = createGraphics(dataSize, dataSize, P2D);
  dataY.noSmooth();
  dataY.beginDraw();
  dataY.endDraw();
  dataY.beginDraw();
    dataY.image(bufferImg,0,0);
  dataY.endDraw();
  
  for (int i = 0; i < bufferImg.pixels.length; i++) {
    bufferImg.pixels[i] = color(random(255), random(255), random(255)); 
  }
  
  bufferImg.updatePixels();
  dataAng = createGraphics(dataSize, dataSize, P2D);
  dataAng.noSmooth();
  dataAng.beginDraw();
  dataAng.endDraw();
  dataAng.beginDraw();
    dataAng.image(bufferImg,0,0);
  dataAng.endDraw();
}

void randomizeParameters() {
  foresee = random(random(random(0, 100)));
  rotAngle = random(random(0.0, 1.0));
  speed = random(0.0, 5.0);
  particleFov = random(-0.25, 0.25);
  
  updateParticlesAngShader.set("foresee",     foresee);
  updateParticlesAngShader.set("rotAngle",    rotAngle);
  updateParticlesPosShader.set("speed", speed);
  updateParticlesAngShader.set("particleFov", particleFov);

}

void draw() {
  
  // auto-randomize
  if (frameCount%100==0) randomizeParameters();
  
  //update angles
  dataAng.beginDraw();
    updateParticlesAngShader.set("dataX", dataX);
    updateParticlesAngShader.set("dataY", dataY);
    updateParticlesAngShader.set("pheromones", pheromones);
    dataAng.shader(updateParticlesAngShader);
    dataAng.noStroke();
    dataAng.rect(0, 0, dataSize, dataSize);
  dataAng.endDraw();
  
  //move particules
  updateParticlesPosShader.set("dataAng", dataAng);
  dataX.beginDraw();
    updateParticlesPosShader.set("mode", float(0));
    dataX.shader(updateParticlesPosShader);
    dataX.noStroke();
    dataX.rect(0, 0, dataSize, dataSize);
  dataX.endDraw();
  dataY.beginDraw();
    updateParticlesPosShader.set("mode", float(1));
    dataY.shader(updateParticlesPosShader);
    dataY.noStroke();
    dataY.rect(0, 0, dataSize, dataSize);
  dataY.endDraw();
  
  //draw cursor if clicked
  if (mousePressed) {
    if (mouseButton == LEFT) {
      pheromones.fill(255);
    } else {
      pheromones.fill(0);
    }
    pheromones.beginDraw();
      pheromones.resetShader();
      pheromones.noStroke();
      pheromones.circle(mouseX, mouseY, 50); 
    pheromones.endDraw();
  }

  //write particules in the pheromones image
  addParticlesShader.set("dataX", dataX);
  addParticlesShader.set("dataY", dataY);
  pheromones.beginDraw();
    pheromones.shader(addParticlesShader);
    pheromones.noStroke();
    pheromones.shape(particles, 0, 0);
    //pheromones.rect(-25, -25, 50, 50);
  pheromones.endDraw();

  //diffuse pheromones
  pheromones.beginDraw();
    //pheromones.background(0);
     
    pheromones.shader(updatePheromonesShader);
    pheromones.noStroke();
    pheromones.rect(0, 0, width, height);    
  pheromones.endDraw();

  shader(seePheromonesShader);
  image(pheromones, 0, 0, width, height);

  seeParticlesShader.set("dataX", dataX);
  seeParticlesShader.set("dataY", dataY);
  noStroke();
  shader(seeParticlesShader);
  shape(particles, 0, 0);

  resetShader();

  //image(dataAng, 0, 0, dataSize, dataSize);
  println(frameRate);
}
