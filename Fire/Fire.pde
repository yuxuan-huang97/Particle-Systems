// Created for CSCI 5611
// Modified by Yuxuan Huang into a Fire Simulation using particle systems

// If you are new to processing, you can find an excellent tutorial that will quickly
// introduce the key features here: https://processing.org/tutorials/p3d/

import java.lang.Math;

String projectTitle = "Fire";

float floor = 600;

ArrayList<PVector> POS = new ArrayList<PVector>();
ArrayList<PVector> VEL = new ArrayList<PVector>();
ArrayList<PVector> COL = new ArrayList<PVector>();
ArrayList<Float> LIFE = new ArrayList<Float>();

float gen_rate = 500; // particle generation rate
float lifespan = 6; // the lifespan of a particle
float lifespan2 = 60;

float center_x = 300;
float center_z = -300;

PShape s;

boolean fw = false;
boolean bw = false;
boolean lw = false;
boolean rw = false;
boolean mm = false; // mouse moved

PVector campos = new PVector(500, 300, 500);
PVector camfoc = new PVector(300, 400, -300);
PVector up = new PVector(0, -1, 0);

float delta_x;
float delta_y;

float startTime;

// Creates a 600x600 window for 3D graphics 
void setup() {
 size(600, 600, P3D);
 noStroke(); //Question: What does this do? Answer: It hides the outline of the primitives
 s = loadShape("Candle.obj");
 startTime = millis();
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
  PVector p = GenPos(300, 410, -300, 2);
  PVector v = GenVel(0, -30, 0, 20);
  PVector c = new PVector(255, 255, 0);
  float life = GenLife(lifespan, 1);
  POS.add(p);
  VEL.add(v);
  COL.add(c);
  LIFE.add(life);
  /*
  if (POS.size() > 3000 && Math.random() < 0.05) {
    p = GenPos(300, 200, -300, 5);
    v = GenVel(0, -2, 0, 2);
    float smkclr = ((float)Math.random() + 1) * 100;
    c = new PVector(smkclr, smkclr, smkclr);
    life = GenLife(lifespan2, 10);
    POS.add(p);
    VEL.add(v);
    COL.add(c);
    LIFE.add(life);
    
  }*/
}

// Generate initial position (sampled from a disk)
PVector GenPos(float x0, float y0, float z0, float r0) {
  float x, y, z;
  float theta, r;
  theta = (float)Math.random() * 2 * PI;
  r = r0 * (float)Math.sqrt(Math.random());
  x = r * (float)Math.cos(theta) + x0;
  y = y0;
  z = -1 * r * (float)Math.sin(theta) + z0;
  PVector ini_pos = new PVector(x, y, z);
  return ini_pos;
}

// Generate initial velocity
PVector GenVel(float x0, float y0, float z0, float ptb) {
  float xptb = (float)Math.random() - 0.5;
  float zptb = (float)Math.random() - 0.5;
  float len = (float)Math.sqrt(xptb * xptb + zptb * zptb);
  PVector ini_vel = new PVector(x0 + ptb * xptb / len, y0 + ptb * ((float)Math.random()-0.5), z0 + ptb * zptb / len);
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
    if (COL.get(i).z == 0) {
      // Update velocity
      VEL.get(i).x += 0.2 * (center_x - POS.get(i).x + (0.5 - Math.random()) * 5) * dt;
      VEL.get(i).z += 0.2 * (center_z - POS.get(i).z + (0.5 - Math.random()) * 5) * dt;
      COL.get(i).y = ((1 - LIFE.get(i) / lifespan) * 255);
      //println(LIFE.get(i));
    }
    LIFE.set(i, LIFE.get(i) - dt);
  }
}

//Animation Principle: Separate Draw Code
void drawScene(){
  background(0,0,0);
  fill(255, 255, 255); 
  lights();
  updateCam();
  camera(campos.x, campos.y, campos.z, camfoc.x, camfoc.y, camfoc.z , 0, 1, 0);
  for (int i = 0; i < POS.size(); i++) {
    if (COL.get(i).z == 0) strokeWeight(10);
    else strokeWeight(4 + 0.2 * (lifespan2 - LIFE.get(i)));
    stroke(COL.get(i).x, COL.get(i).y, COL.get(i).z, 80);
    point(POS.get(i).x, POS.get(i).y, POS.get(i).z);
  }
  pushMatrix();
  translate(300, floor + 200, -300);
  rotateX(PI);
  scale(60);
  shape(s);
  popMatrix();
}

void updateCam() {
  PVector v = PVector.sub(camfoc, campos);
  
  if (mm) {
    v = rotatey(v, delta_x * PI/600);
    v.y += 0.01 * delta_y;
    mm = false;
  }
  v.normalize();
  
  PVector l = v.cross(up);
  if (fw) campos.add(PVector.mult(v, 10)); 
  if (bw) campos.sub(PVector.mult(v, 10));
  if (lw) campos.add(PVector.mult(l, 10));
  if (rw) campos.sub(PVector.mult(l, 10));
  camfoc = PVector.add(campos, v);
  
  //println(campos.x, " ", campos.y, " ", campos.z);
}

//Main function which is called every timestep. Here we compute the new physics and draw the scene.
//Additionally, we also compute some timing performance numbers.
void draw() {
  float elapsedTime = millis() - startTime;
  startTime = millis();
  float startFrame = millis(); //Time how long various components are taking
  //Compute the physics update
  //computePhysics(timer/1000.0); //Question: Should this be a fixed number?
  computePhysics(0.2);
  //computePhysics(elapsedTime/1000.0);
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

void keyPressed() {
  if (key == 119) fw = true;
  if (key == 115) bw = true;
  if (key == 97) lw = true;
  if (key == 100) rw = true;
}
void keyReleased() {
  if (key == 119) fw = false;
  if (key == 115) bw = false;
  if (key == 97) lw = false;
  if (key == 100) rw = false;
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
