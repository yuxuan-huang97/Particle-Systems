// Created for CSCI 5611


// If you are new to processing, you can find an excellent tutorial that will quickly
// introduce the key features here: https://processing.org/tutorials/p3d/

import java.lang.Math;

String projectTitle = "Firework";

float floor = 600;

ArrayList<PVector> POS = new ArrayList<PVector>();
ArrayList<PVector> VEL = new ArrayList<PVector>();
ArrayList<Float> LIFE = new ArrayList<Float>();
ArrayList<PVector> COL = new ArrayList<PVector>();

float radius = 5;
float gen_rate = 100; // particle generation rate
float lifespan = 5; // the lifespan of a particle

PVector pos1 = new PVector(150, 600, -300); // Firework Position 1
PVector pos2 = new PVector(450, 600, -300);
PVector vel1 = GenVel(0, -50, 0, 5); // Firework Velocity 1
PVector vel2 = GenVel(0, -50, 0, 5);
boolean exploded1 = false;
boolean exploded2 = false;

float time1 = millis(); // launch time
float time2 = millis();

// Creates a 600x600 window for 3D graphics 
void setup() {
 size(600, 600, P3D);
 noStroke(); //Question: What does this do? Answer: It hides the outline of the primitives
}

// Generate particles for a timestep
void spawnParticles(float dt, PVector pos) {
  // calculate the num of particles to gen in a timestep
  float numParticles = dt * gen_rate;
  float fracPart = numParticles - int(numParticles);
  numParticles = int(numParticles);
  if (Math.random() < fracPart) {
    numParticles += 1;
  }
  for (int i = 0; i < numParticles; i++){
    //generate particles
    ParticleGen(pos);
  }
  //println("Spawned: ", numParticles);
}

// Generate a single particle
void ParticleGen(PVector pos) {
  PVector p = GenPos(pos.x, pos.y, pos.z, 5);
  PVector v = GenVel(0, 2.5, 0, 1);
  PVector c = new PVector(255, 255, 255);
  float life = GenLife(lifespan, 2.5);
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
  r = r0 * (float)Math.random();
  x = r * (float)Math.cos(theta) + x0;
  y = y0;
  z = -1 * r * (float)Math.sin(theta) + z0;
  PVector ini_pos = new PVector(x, y, z);
  return ini_pos;
}

// Generate initial velocity
PVector GenVel(float x0, float y0, float z0, float ptb) {
  float xptb = (float)Math.random() - 0.5;
  float yptb = (float)Math.random() - 0.5;
  float zptb = (float)Math.random() - 0.5;
  float len = (float)Math.sqrt(xptb * xptb + yptb * yptb + zptb * zptb);
  PVector ini_vel = new PVector(x0 + ptb * xptb / len, y0 + ptb * yptb / len, z0 + ptb * zptb / len);
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
    COL.remove(tmp);
    LIFE.remove(tmp);
  }
  //println("Removed: ", DelList.size());
}

void explode(PVector pos) {
  int num = 200;
  int type;
  if (Math.random() < 0.5) type = 0;
  else type = 1;
  for (int i = 0; i < num; i++) {
    PVector p = GenPos(pos.x, pos.y, pos.z, 5);
    POS.add(p);
    PVector v = GenVel(0, 0, 0, 50);
    VEL.add(v);
    float life = GenLife(10, 2);
    LIFE.add(life);
    PVector c = new PVector();
    if (type == 0) {
      if (Math.random() < 0.5) c = new PVector(255, 100, 100); // red
      else c = new PVector(100, 100, 255); // blue
    }
    else {
      if (Math.random() < 0.5) c = new PVector(100, 255, 100); // green
      else c = new PVector(255, 255, 100); // yellow
    } //<>//
    COL.add(c);
  }
}




//Animation Principle: Separate Physical Update 
void computePhysics(float dt){
  
  if (millis() - time1 > 4000) {
    time1 = millis();
    exploded1 = false;
    vel1 = GenVel(0, -50, 0, 5);
    pos1 = new PVector(150, 600, -300);
  }
   if (millis() - time2 > 5000) {
    time2 = millis();
    exploded2 = false;
    vel2 = GenVel(0, -50, 0, 5);
    pos2 = new PVector(450, 600, -300);
  }
  
  float accfw = 4;
  float accsp = 0;
  if (vel1.y < -1) spawnParticles(dt, pos1);
  else if (!exploded1) {
    explode(pos1);
    exploded1 = true;
  }
  if (vel2.y < -1) spawnParticles(dt, pos2);
   else if (!exploded2) {
    explode(pos2);
    exploded2 = true;
  }
  DelParticles();
  for (int i = 0; i < POS.size(); i++) {
    // Update positions
    POS.get(i).x += VEL.get(i).x * dt;
    POS.get(i).y += VEL.get(i).y * dt;
    POS.get(i).z += VEL.get(i).z * dt;
    // Update velocity
    if (COL.get(i).x == 255 && COL.get(i).y == 255 && COL.get(i).z == 255) VEL.get(i).y += accsp * dt;
    else {
      VEL.get(i).x *= 0.95;
      VEL.get(i).y = 0.95 * (VEL.get(i).y + 0.5);
      VEL.get(i).z *= 0.95;
    }
    
    LIFE.set(i, LIFE.get(i) - dt);
    //println(LIFE.get(i));
  }
  pos1.x += vel1.x * dt;
  pos1.y += vel1.y * dt;
  pos1.z += vel1.z * dt;
  vel1.y += accfw * dt;
  pos2.x += vel2.x * dt;
  pos2.y += vel2.y * dt;
  pos2.z += vel2.z * dt;
  vel2.y += accfw * dt;
}

//Animation Principle: Separate Draw Code
void drawScene(){
  background(0,0,0);
  fill(255, 255, 255); 
  lights();
  for (int i = 0; i < POS.size(); i++) {
    if (i > 200) {
      println(" ");
    }
    float tmp = LIFE.get(i) / 10.0;
    stroke(255 + (COL.get(i).x - 255) * tmp, 255 + (COL.get(i).z - 255) * tmp, 255 + (COL.get(i).z - 255) * tmp);
    //println(COL.get(i).x, " ", COL.get(i).y, " ", COL.get(i).z);
    strokeWeight(1);
    if (COL.get(i).x != 255 || COL.get(i).y != 255 || COL.get(i).z != 255) {
      strokeWeight(4);
    }
    point(POS.get(i).x, POS.get(i).y, POS.get(i).z);
  }
  pushMatrix();
  //fill(255, 255, 255);
  if (vel1.y < -1) {
    translate(pos1.x, pos1.y, pos1.z);
    sphere(5);
  }
  popMatrix();
  pushMatrix();
  if (vel2.y < -1) {
    translate(pos2.x, pos2.y, pos2.z);
    sphere(5);
  }
  popMatrix();
  //for (int i = 0; i < POS.size(); i++) popMatrix();
}

//Main function which is called every timestep. Here we compute the new physics and draw the scene.
//Additionally, we also compute some timing performance numbers.
void draw() {
  float startFrame = millis(); //Time how long various components are taking
  //Compute the physics update
  //computePhysics(timer/1000.0); //Question: Should this be a fixed number?
  computePhysics(0.15);
  float endPhysics = millis();
  
  //Draw the scene
  drawScene();
  float endFrame = millis();
  
  String runtimeReport = "Frame: "+str(endFrame-startFrame)+"ms,"+
        " Physics: "+ str(endPhysics-startFrame)+"ms,"+
        " FPS: "+ str(round(frameRate)) +"\n";
  surface.setTitle(projectTitle+ "  -  " +runtimeReport);
  //print(runtimeReport);
  //println(timer);
}
