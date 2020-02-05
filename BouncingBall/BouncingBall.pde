// Created for CSCI 5611

// Here is a simple processing program that demonstrates the central math used in the check-in
// to create a bouncing ball. The ball is integrated with basic Eulerian integration.
// The ball is subject to a simple PDE of constant downward acceleration  (by default, 
// down is the positive y direction).

// If you are new to processing, you can find an excellent tutorial that will quickly
// introduce the key features here: https://processing.org/tutorials/p3d/

String projectTitle = "Bouncing Ball";

//Animation Principle: Store object & world state in external variables that are used by both
//                     the drawing code and simulation code.
float x = 200;
float y = 200;
float z = -300;
float h_velocity = -35; // horizontal velocity
float v_velocity = 0; // vertical velocity
float z_velocity = 35; // velocity in z-direction
float radius = 40; 
float floor = 600;
float left_wall = 0;
float right_wall = 600;
float front_wall = -600;
float back_wall = 0;
float r = 0;
float g = 255;
float b = 0;

// the two boolean variables are used to prevent the ball from being stuck in the walls
boolean rightwards = true; // the sphere is moving rightwards
boolean backwards = true; // the sphere is moving backwards (towards us)

//Creates a 600x600 window for 3D graphics 
void setup() {
 size(600, 600, P3D);
 noStroke(); //Question: What does this do? Answer: It hides the outline of the primitives
}

//Animation Principle: Separate Physical Update 
void computePhysics(float dt){
  float acceleration = 9.8;
  
  //Eulerian Numerical Integration
  y = y + v_velocity * dt;  //Question: Why update y before v_velocity? Does it matter?
  v_velocity = v_velocity + acceleration * dt; 
  x = x + h_velocity * dt;
  z = z + z_velocity * dt;
  //Collision Code (update v_velocity if we hit the floor and update h_velocity if we hit the wall)
  if (y + radius > floor){
    y = floor - radius; //Robust collision check
    v_velocity *= -.85; //Coefficient of restitution (don't bounce back all the way)
    r = 0;
    g = 255;
    b = 0;
  }
  
  if ((x - radius < left_wall && rightwards) || (x + radius > right_wall && !rightwards)){
    h_velocity *= -.95;
    r = 255;
    g = 0;
    b = 0;
    rightwards = !rightwards;
  }
   if ((z + radius > back_wall && backwards) || (z - radius < front_wall && !backwards)){
    z_velocity *= -.95;
    r = 0;
    g = 0;
    b = 255;
    backwards = !backwards;
  }
  println(h_velocity);
}

//Animation Principle: Separate Draw Code
void drawScene(){
  background(255,255,255);
  fill(r, g, b); 
  lights();
  translate(x,y,z); 
  noStroke();
  sphere(radius);
  stroke(0);
  translate(300-x, 300-y, -300-z);
  noFill();
  box(600);
}

//Main function which is called every timestep. Here we compute the new physics and draw the scene.
//Additionally, we also compute some timing performance numbers.
void draw() {
  float startFrame = millis(); //Time how long various components are taking
  
  //Compute the physics update
  computePhysics(0.15); //Question: Should this be a fixed number?
  float endPhysics = millis();
  
  //Draw the scene
  drawScene();
  float endFrame = millis();
  
  String runtimeReport = "Frame: "+str(endFrame-startFrame)+"ms,"+
        " Physics: "+ str(endPhysics-startFrame)+"ms,"+
        " FPS: "+ str(round(frameRate)) +"\n";
  surface.setTitle(projectTitle+ "  -  " +runtimeReport);
  //print(runtimeReport);
}
