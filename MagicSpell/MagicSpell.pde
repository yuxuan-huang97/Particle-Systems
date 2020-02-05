// Created for CSCI 5611


// If you are new to processing, you can find an excellent tutorial that will quickly
// introduce the key features here: https://processing.org/tutorials/p3d/

import java.lang.Math;

String projectTitle = "Fire";

float floor = 600;

//PVector position = new PVector(mouseX, mouseY, 0);

ArrayList<PVector> POS = new ArrayList<PVector>();
ArrayList<PVector> VEL = new ArrayList<PVector>();
ArrayList<PVector> COL = new ArrayList<PVector>();
ArrayList<Float> LIFE = new ArrayList<Float>();

float gen_rate = 100; // particle generation rate
float lifespan = 10; // the lifespan of a particle

PShape s;

boolean mm = false; // mouse moved

float delta_x;
float delta_y;

// Creates a 600x600 window for 3D graphics 
void setup() {
 size(600, 600, P3D);
 noStroke(); //Question: What does this do? Answer: It hides the outline of the primitives
 noCursor();
 s = loadShape("wand.obj");
}

// Generate particles for a timestep
void spawnParticles(float dt) {
  // calculate the num of particles to gen in a timestep
  float numParticles = dt * gen_rate;
  float fracPart = numParticles - int(numParticles);
  numParticles = int(numParticles);
  if (Math.random() < fracPart) {
    numParticles += 1;
  }
  for (int i = 0; i < numParticles; i++){
    //generate particles
    ParticleGen();
  }
  //println("Spawned: ", numParticles);
}

// Generate a single particle
void ParticleGen() {
  PVector p = GenPos(mouseX, mouseY, 0, 1);
  PVector v = GenVel(10);
  PVector c = new PVector(255, 255, 255);
  if (mousePressed) {
    if (v.x > 0) v.x *= -1;
    if (v.y > 0) v.y *= -1;
    v.x *= 3;
    v.y *= 3;
    v.z *= 3;
    c.z = 0;
  }
  float life = GenLife(lifespan, 1);
  POS.add(p);
  VEL.add(v);
  COL.add(c);
  LIFE.add(life);
}

// Generate initial position (sampled from a disk)
PVector GenPos(float x0, float y0, float z0, float r0) {
  float x, y, z;
  float theta, r;
  theta = (float)Math.random() * 2 * PI;
  r = r0 * (float)Math.sqrt(Math.random());
  x = r * (float)Math.cos(theta) + x0;
  y = r * (float)Math.cos(theta) + y0;
  z = z0;
  PVector ini_pos = new PVector(x, y, z);
  return ini_pos;
}

// Generate initial velocity
PVector GenVel(float ptb) {
  float xptb = (float)Math.random() - 0.5;
  float yptb = (float)Math.random() - 0.5;
  float zptb = (float)Math.random() - 0.5;
  float len = (float)Math.sqrt(xptb * xptb + yptb * yptb + zptb * zptb);
  ptb *= (float)Math.random();
  PVector ini_vel = new PVector(ptb * xptb / len, ptb * yptb / len, ptb * zptb / len);
  return ini_vel;
}
// Generate initial acceleration

// Generate lifespan
float GenLife(float std, float ptb) {
  float life = std + (float)Math.random() * ptb;
  return life;
}

// Delete particles
void DelParticles() {
  ArrayList<Integer> DelList = new ArrayList<Integer>();
  for (int i = 0; i < LIFE.size(); i++) {
    if (LIFE.get(i) < 0) {
      DelList.add(i);
    }
  }
  for (int i = DelList.size() - 1; i >= 0; i--) {
    int tmp = DelList.get(i);
    //println(tmp);
    POS.remove(tmp);
    VEL.remove(tmp);
    COL.remove(tmp);
    LIFE.remove(tmp);
  }
  //println("Removed: ", DelList.size());
}

//Animation Principle: Separate Physical Update 
void computePhysics(float dt){
  
  spawnParticles(dt);
  DelParticles();
  for (int i = 0; i < POS.size(); i++) {
    // Update positions
    POS.get(i).x += VEL.get(i).x * dt;
    POS.get(i).y += VEL.get(i).y * dt;
    POS.get(i).z += VEL.get(i).z * dt;
    // Update velocity
    VEL.get(i).x += 0.2;
    VEL.get(i).y += 0.2;
    VEL.get(i).z += 0.2;
    COL.get(i).y = ((1 - LIFE.get(i) / lifespan) * 255);
    //println(LIFE.get(i));
    LIFE.set(i, LIFE.get(i) - dt);
  }
}

//Animation Principle: Separate Draw Code
void drawScene(){
  background(255, 255, 255);
  fill(255, 255, 255); 
  lights();
  for (int i = 0; i < POS.size(); i++) {
    strokeWeight(4);
    stroke(COL.get(i).x, COL.get(i).y, COL.get(i).z);
    point(POS.get(i).x, POS.get(i).y, POS.get(i).z);
  }
  pushMatrix();
  translate(mouseX, mouseY);
  rotateZ(-1 * PI / 4);
  scale(5);
  shape(s);
  popMatrix();
}



//Main function which is called every timestep. Here we compute the new physics and draw the scene.
//Additionally, we also compute some timing performance numbers.
void draw() {
  float startFrame = millis(); //Time how long various components are taking
  //Compute the physics update
  //computePhysics(timer/1000.0); //Question: Should this be a fixed number?
  computePhysics(0.2);
  float endPhysics = millis();
  //Draw the scene
  drawScene();
  float endFrame = millis();
  
  String runtimeReport = "Frame: "+str(endFrame-startFrame)+"ms,"+
        " Physics: "+ str(endPhysics-startFrame)+"ms,"+
        " FPS: "+ str(round(frameRate)) +"\n";
  surface.setTitle(projectTitle+ "  -  " +runtimeReport);
  //print(runtimeReport);
  //println(COL.size());
}


void mouseDragged() {
  mm = true;
  delta_x = mouseX - pmouseX;
  delta_y = mouseY - pmouseY;
}

PVector rotatey(PVector v, float theta) {
  PVector result = new PVector();
  float c = (float)Math.cos(theta);
  float s = (float)Math.sin(theta);
  result.x = c * v.x - s * v.z;
  result.y = v.y;
  result.z = s * v.x + c * v.z;
  return result;
}
