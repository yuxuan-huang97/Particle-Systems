// Created for CSCI 5611
// Modified into a fountain simulation by Yuxuan Huang

// If you are new to processing, you can find an excellent tutorial that will quickly
// introduce the key features here: https://processing.org/tutorials/p3d/

import java.lang.Math;

String projectTitle = "Fountain";

float floor = 600;

ArrayList<PVector> POS = new ArrayList<PVector>();
ArrayList<PVector> VEL = new ArrayList<PVector>();
//ArrayList<PVector> ACC = new ArrayList<PVector>();
ArrayList<Float> LIFE = new ArrayList<Float>();

float gen_rate = 900; // particle generation rate
float lifespan = 25; // the lifespan of a particle

float radius = 180;

PShape s;

// Creates a 600x600 window for 3D graphics 
void setup() {
 size(600, 600, P3D);
 noStroke(); //Question: What does this do? Answer: It hides the outline of the primitives
 s = loadShape("fountain.obj");
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
  PVector p = GenPos(300, 250, -300, 5);
  PVector v = GenVel(0, -50, 0, 10);
  //PVector a = new PVector(0, 9.8, 0);
  float life = GenLife(lifespan, 0.5);
  POS.add(p);
  VEL.add(v);
  //ACC.add(a);
  LIFE.add(life);
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
    //ACC.remove(DelList.get(i));
    LIFE.remove(tmp);
  }
  //println("Removed: ", DelList.size());
}

//Animation Principle: Separate Physical Update 
void computePhysics(float dt){
  float acceleration = 9.8;
  
  spawnParticles(dt);
  DelParticles();
  for (int i = 0; i < POS.size(); i++) {
    // Update positions
    POS.get(i).x += VEL.get(i).x * dt;
    POS.get(i).y += VEL.get(i).y * dt;
    POS.get(i).z += VEL.get(i).z * dt;
    // Update velocity
    VEL.get(i).y += acceleration * dt;
    if (POS.get(i).y > floor) {
      POS.get(i).y = floor; //Robust collision check
      VEL.get(i).y *= -.3; //Coefficient of restitution (don't bounce back all the way)
    }
    /*if (POS.get(i).y > floor - 100){
      println(POS.get(i).x - 300);
      println(POS.get(i).z + 300);
    }*/
    if (POS.get(i).y > floor - 60 && 
    (POS.get(i).x - 300) * (POS.get(i).x - 300) + (POS.get(i).z + 300) * (POS.get(i).z + 300) < radius * radius) {
      POS.get(i).y = floor - 60;
      VEL.get(i).y *= -.3;
      //println("1");
    }
    LIFE.set(i, LIFE.get(i) - dt);
    //println(LIFE.get(i));
  }
}

//Animation Principle: Separate Draw Code
void drawScene(){
  background(0,0,0);
  fill(255, 255, 255); 
  lights();
  camera(300, 300, 350, 300, 400, -300, 0, 1, 0);
  for (int i = 0; i < POS.size(); i++) {
    stroke(255, 255, 255);
    point(POS.get(i).x, POS.get(i).y, POS.get(i).z);
  }
  pushMatrix();
  translate(300, floor, -300);
  rotateX(0.5 * PI);
  scale(2);
  shape(s);
  popMatrix();
  //for (int i = 0; i < POS.size(); i++) popMatrix();
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
  
  String runtimeReport = 
        " FPS: "+ str(round(frameRate)) + "," +
        " Particles: " + str(POS.size()) + "\n";
  surface.setTitle(projectTitle+ "  -  " +runtimeReport);
  print(runtimeReport);
  //println(POS.size());
}

/*void keyPressed() {
  int i = 1;
  if (key == 119) i++;
  println(i);
}*/
