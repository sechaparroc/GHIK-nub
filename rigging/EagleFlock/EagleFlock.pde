/**
 * Flock of birds 
 * by Sebastian Chaparro Cuevas.
 * 
 * This example is an Adaptation of Flock of Boids, replacing each Boid by an Eagle
 * with a simple IK Structure (see Fish and Flock of Boids examples). 
 *
 * Press ' ' to switch between the different eye modes.
 * Press 'a' to toggle (start/stop) animation.
 * Press '+' to speed up the boids animation.
 * Press '-' to speed down the boids animation.
 * Press 'e' to enable concurrence of the flock animation.
 * Press 'd' to disable concurrence of the flock animation.
 * Press 'p' to print the current node rate.
 * Press 'm' to change the boid visual mode.
 * Press 'v' to toggle boids' wall skipping.
 * Press 's' to call scene.fit(1).
 */

import nub.primitives.*;
import nub.core.*;
import nub.core.constraint.*;
import nub.processing.*;
import nub.ik.solver.*;
import nub.ik.skinning.*;
import java.util.List;

Scene scene;
//flock bounding box
int flockWidth = 1280;
int flockHeight = 720;
int flockDepth = 600;
boolean avoidWalls = true;

int initBoidNum = 20 ,numFlocks = 10; // amount of boids to start the program with
ArrayList< ArrayList<Boid> > flocks = new ArrayList< ArrayList<Boid> >();
Node avatar;
boolean animate = true;

ArrayList<Skinning> skinning = new ArrayList<Skinning>();

void setup() {
  size(1000, 800, P3D);
  scene = new Scene(this);
  scene.setBounds(new Vector(flockWidth / 2, flockWidth / 3), flockWidth / 2);
  scene.fit();
  // create and fill the list of boids
  for(int k = 0; k < numFlocks; k++){
      ArrayList<Boid> flock = new ArrayList();
      Node objShape = generateEagle();
      for (int i = 0; i < initBoidNum; i++)
          flock.add(new Boid(objShape, skinning.get(k), new Vector(flockWidth / 2 + random(-flockWidth / 4, flockWidth / 4  ),
                                                                          flockHeight / 2 + random(-flockHeight / 4, flockHeight / 4  ),
                                                                          flockDepth / 2  + random(-flockDepth / 4, flockDepth / 4  )), flock));
      flocks.add(flock);
  }
}

void draw() {
  background(0);
  ambientLight(128, 128, 128);
  directionalLight(255, 255, 255, 0, 1, -100);
  walls();
  scene.render();
  // uncomment to asynchronously update boid avatar. See mouseClicked()
  // updateAvatar(scene.trackedNode("mouseClicked"));
}

void walls() {
  pushStyle();
  noFill();
  stroke(255, 255, 0);

  line(0, 0, 0, 0, flockHeight, 0);
  line(0, 0, flockDepth, 0, flockHeight, flockDepth);
  line(0, 0, 0, flockWidth, 0, 0);
  line(0, 0, flockDepth, flockWidth, 0, flockDepth);

  line(flockWidth, 0, 0, flockWidth, flockHeight, 0);
  line(flockWidth, 0, flockDepth, flockWidth, flockHeight, flockDepth);
  line(0, flockHeight, 0, flockWidth, flockHeight, 0);
  line(0, flockHeight, flockDepth, flockWidth, flockHeight, flockDepth);

  line(0, 0, 0, 0, 0, flockDepth);
  line(0, flockHeight, 0, 0, flockHeight, flockDepth);
  line(flockWidth, 0, 0, flockWidth, 0, flockDepth);
  line(flockWidth, flockHeight, 0, flockWidth, flockHeight, flockDepth);
  popStyle();
}

void updateAvatar(Node node) {
  if (node != avatar) {
    avatar = node;
    if (avatar != null)
      thirdPerson();
    else if (scene.eye().reference() != null)
      resetEye();
  }
}

// Sets current avatar as the eye reference and interpolate the eye to it
void thirdPerson() {
  scene.eye().setReference(avatar);
  scene.fit(avatar, 1);
}

// Resets the eye
void resetEye() {
  // same as: scene.eye().setReference(null);
  scene.eye().resetReference();
  scene.lookAt(scene.center());
  scene.fit(1);
}

// picks up a boid avatar, may be null
void mouseClicked() {
  updateAvatar(scene.updateMouseTag("mouseClicked"));
}

// 'first-person' interaction
void mouseDragged() {
  if (scene.eye().reference() == null)
    if (mouseButton == LEFT)
      // same as: scene.spin(scene.eye());
      scene.mouseSpin();
    else if (mouseButton == RIGHT)
      // same as: scene.translate(scene.eye());
      scene.mouseTranslate();
    else
      scene.moveForward(mouseX - pmouseX);
}

// highlighting and 'third-person' interaction
void mouseMoved(MouseEvent event) {
  // 1. highlighting
  scene.mouseTag("mouseMoved");
  // 2. third-person interaction
  if (scene.eye().reference() != null)
    // press shift to move the mouse without looking around
    if (!event.isShiftDown())
      scene.mouseLookAround();
}

void mouseWheel(MouseEvent event) {
  // same as: scene.scale(event.getCount() * 20, scene.eye());
  scene.scale(event.getCount() * 20);
}

void keyPressed() {
  switch (key) {
  case 'a':
    for(ArrayList<Boid> flock : flocks)
      for (Boid boid : flock)
        boid.task.toggle();
    break;
  case '+':
    for(ArrayList<Boid> flock : flocks)
      for (Boid boid : flock)
        boid.task.increasePeriod(-2);
    break;
  case '-':
    for(ArrayList<Boid> flock : flocks)
      for (Boid boid : flock)
        boid.task.increasePeriod(2);
    break;
  case 'e':
    for(ArrayList<Boid> flock : flocks)
      for (Boid boid : flock)
        boid.task.enableConcurrence(true);
    break;
  case 'd':
    for(ArrayList<Boid> flock : flocks)
      for (Boid boid : flock)
        boid.task.enableConcurrence(false);
    break;
  case 's':
    if (scene.eye().reference() == null)
      scene.fit(1);
    break;
  case 'p':
    println("Frame rate: " + frameRate);
    break;
  case 'v':
    avoidWalls = !avoidWalls;
    break;
  case ' ':
    if (scene.eye().reference() != null)
      resetEye();
    else if (avatar != null)
      thirdPerson();
    break;
  }
}  
//Generate an Eagle
Node generateEagle(){
  String shapeFile = "EAGLE_2.OBJ";
  String textureFile = "EAGLE2.jpg";
  //Invert Y Axis and set Fill
  Node objShape = new Node();
  objShape.rotate(new Quaternion(new Vector(0, 0, 1), PI));

  List<Node> skeleton = loadSkeleton(null);
  skeleton.get(0).cull = true;
  setConstraints(skeleton);
  objShape.rotate(new Quaternion(new Vector(0, 1, 0), -PI/2.f));
  objShape.scale(1);

  skinning.add(new GPULinearBlendSkinning(skeleton, shapeFile, textureFile, 100, false));
  
  //Adding IK behavior
  //Identify root and end effector(s)
  Node root = skeleton.get(0); //root is the fist joint of the structure
  List<Node> endEffectors = new ArrayList<Node>(); //End Effectors are leaf nodes (with no children)
  for(Node node : skeleton) {
      if (node.children().size() == 0) {
          endEffectors.add(node);
      }
  }
  
  Solver solver = scene.registerTreeSolver(skeleton.get(0));
  //Update params
  solver.setMaxError(1f);
  solver.setMaxIterations(5);
  for(Node endEffector : endEffectors){
      //4.3 Create target(s) to relate with End Effector(s)
      Node target = new Node();
      target.setPosition(endEffector.position().get());
      //4.4 Relate target(s) with end effector(s)
      scene.addIKTarget(endEffector, target);
      //disable enf effector tracking
      endEffector.tagging = false;

      //If desired generates a default Path that target must follow
      if(endEffector == skeleton.get(14)){
        setupTargetInterpolator(target, new Vector[]{
          new Vector(-36,3,0), 
          new Vector(-34,-16,0), 
          new Vector(-36,3,0) , 
          new Vector(-34,20,0), 
          new Vector(-36,3,0)});
      }

      if(endEffector == skeleton.get(18)){
        setupTargetInterpolator(target, new Vector[]{
          new Vector(33,3,0), 
          new Vector(31,-16,0), 
          new Vector(33,3,0) , 
          new Vector(31,20,0), 
          new Vector(33,3,0)});
      } 
  }
  return objShape;
}

List<Node> loadSkeleton(Node reference){
  JSONArray skeleton_data = loadJSONArray("skeleton.json");
  HashMap<String, Node> dict = new HashMap<String, Node>();
  List<Node> skeleton = new ArrayList<Node>();
  for(int i = 0; i < skeleton_data.size(); i++){
    JSONObject joint_data = skeleton_data.getJSONObject(i);
    Node joint = new Node();
    if(i != 0){
      joint.enableHint(Node.BONE, joint_data.getFloat("radius"));
      joint.setReference(dict.get(joint_data.getString("reference")));      
    }
    else{
      PShape shape = createShape(SPHERE, joint_data.getFloat("radius"));
      shape.setFill(color(255));
      shape.setStroke(false);
      joint.setShape(shape);
      joint.setReference(reference);
    }
    joint.setTranslation(joint_data.getFloat("x"), joint_data.getFloat("y"), joint_data.getFloat("z"));
    joint.setRotation(joint_data.getFloat("q_x"), joint_data.getFloat("q_y"), joint_data.getFloat("q_z"), joint_data.getFloat("q_w"));
    skeleton.add(joint);
    dict.put(joint_data.getString("name"), joint);
  }  
  return skeleton;
}

void setConstraints(List<Node> skeleton){
    Node j11 = skeleton.get(11);
    Vector up11 = j11.children().get(0).translation();//Same as child translation 
    Vector twist11 = Vector.cross(up11, new Vector(0,1,0), null);//Same as child translation 
    Hinge h11 = new Hinge(radians(40), radians(40), j11.rotation(), up11, twist11);
    j11.setConstraint(h11);
    
    
    Node j12 = skeleton.get(12);
    Vector up12 = j12.children().get(0).translation();//Same as child translation 
    Vector twist12 = Vector.cross(up12, new Vector(0,1,0), null);//Same as child translation 
    Hinge h12 = new Hinge(radians(40), radians(40), j12.rotation(), up12, twist12);
    j12.setConstraint(h12);
    
    Node j13 = skeleton.get(13);
    Vector up13 = j13.children().get(0).translation();//Same as child translation 
    Vector twist13 = Vector.cross(up13, new Vector(0,1,0), null);//Same as child translation 
    Hinge h13 = new Hinge(radians(45), radians(5), skeleton.get(13).rotation(), up13, twist13);
    j13.setConstraint(h13);

    
    Node j15 = skeleton.get(15);
    Vector up15 = j15.children().get(0).translation();//Same as child translation 
    Vector twist15 = Vector.cross(up15, new Vector(0,1,0), null);//Same as child translation 
    Hinge h15 = new Hinge(radians(40), radians(40), j15.rotation(), up15, twist15);
    j15.setConstraint(h15);
    
    
    Node j16 = skeleton.get(16);
    Vector up16 = j16.children().get(0).translation();//Same as child translation 
    Vector twist16 = Vector.cross(up16, new Vector(0,1,0), null);//Same as child translation 
    Hinge h16 = new Hinge(radians(40), radians(40), j16.rotation(), up16, twist16);
    j16.setConstraint(h16);
    
    Node j17 = skeleton.get(17);
    Vector up17 = j17.children().get(0).translation();//Same as child translation 
    Vector twist17 = Vector.cross(up17, new Vector(0,1,0), null);//Same as child translation 
    Hinge h17 = new Hinge(radians(45), radians(5), skeleton.get(17).rotation(), up17, twist17);
    j17.setConstraint(h17);
}


Interpolator setupTargetInterpolator(Node target, Vector[] positions) {
    Interpolator targetInterpolator = new Interpolator(target);
    targetInterpolator.enableRecurrence();
    targetInterpolator.setSpeed(1f);
    // Create a path
    for(int i = 0; i < positions.length; i++){
        Node node = new Node();
        node.setReference(target.reference());
        node.setTranslation(positions[i]);
        targetInterpolator.addKeyFrame(node);
    }
    targetInterpolator.run();
    return targetInterpolator;
}
