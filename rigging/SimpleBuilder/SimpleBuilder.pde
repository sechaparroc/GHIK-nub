/**
 * Simple Builder
 * by Sebastian Chaparro Cuevas.
 *
 * In this example a mesh is loaded from an .obj file (specified by shapePath) and the idea is to
 * generate a Skeleton Structure over the .obj shape to use later in other sketches.
 *
 * To do so, it is possible to interact with a Joint (InteractiveJoint) in different ways:
 * Using the mouse:
 *    Drag with RIGTH button to translate the Joint.
 *    Drag with LEFT button to rotate the Joint.
 *    Drag with RIGTH button while pressing CTRL to extrude a Joint from the selected one. Release to create a Joint.
 *    Double click with LEFT button while pressing SHIFT key to remove the Branch from the selected Joint.
 * Using the keyboard:
 *    Press 'P' to save the skeleton on a JSON file (you could require this info in other Sketch).
 *    Press 'E' when the mouse is over a Joint to set its translation to (0,0,0). It is useful to mantain Chains of a Structure independent.
 */
 
import nub.primitives.*;
import nub.core.*;
import nub.processing.*;
import nub.core.constraint.*;

//this packages are required for ik behavior
import nub.ik.animation.*;
import nub.ik.solver.*;

 
 //Build easily a Skeleton to relate to a Mesh
Scene scene;
Skeleton skeleton;

String lastCommand = "None";
//Shape variables
PShape model;

//Set this path to load your objs
String shapePath = "Kangaroo/Kangaroo.obj";
String texturePath = "Kangaroo/Kangaroo_diff.jpg";

//This is the path in which the skeleton will be saved
String jsonPath = "data/Kangaroo/Kangaroo.json"; 

float radius = 0;
int w = 1000, h = 700;

/*Create different skeletons to interact with*/
String renderer = P3D;

public void settings(){
  size(w, h, renderer);
}

public void setup(){
  // Create a scene
  scene = new Scene(this);
  scene.setType(Graph.Type.ORTHOGRAPHIC);
  model = loadShape(shapePath);
  model.setTexture(loadImage(texturePath));
  //Scale scene
  float size = max(model.getHeight(), model.getWidth());
  scene.leftHanded = false;
  scene.setBounds(size);
  scene.fit();
  scene.enableHint(Graph.BACKGROUND | Graph.AXES);
  scene.enableHint(Graph.SHAPE);
  //Create the Skeleton and add an Interactive Joint at the center of the scene
  skeleton = new Skeleton();
  //Create the interactive joint
  radius = scene.radius() * 0.01f;
  InteractiveJoint initial = new InteractiveJoint(true, color(random(255),random(255),random(255)), radius, false);
  //Add the joint to the skeleton
  skeleton.addJoint("J0", initial);
  scene.enableHint(Scene.BACKGROUND, 0);
  scene.enableHint(Scene.AXES);
  scene.setShape(model);
  textSize(18);
  textAlign(CENTER, CENTER);
}

public void draw() {
  ambientLight(102, 102, 102);
  lightSpecular(204, 204, 204);
  directionalLight(102, 102, 102, 0, 0, -1);
  specular(255, 255, 255);
  shininess(10);
  stroke(255);
  stroke(255,0,0);
  scene.drawAxes();
  //shape(model);
  scene.render();
  noLights();
  scene.beginHUD();
  text("Last action: " + lastCommand, width/2, 50);
  scene.endHUD();
}

//mouse events
public void mouseMoved() {
  scene.mouseTag();
}

public void mouseDragged(MouseEvent event) {
  if (mouseButton == RIGHT && event.isControlDown()) {
    Vector vector = new Vector(scene.mouseX(), scene.mouseY());
    if(scene.node() != null){
      if(scene.node() instanceof  InteractiveJoint){
        scene.interact(scene.node(),"OnAdding", scene, vector);
        lastCommand = "Extruding from a Joint";
      } else{
        scene.interact(scene.node(),"OnAdding", vector);
      }
    }
  } else if (mouseButton == LEFT) {
    scene.mouseSpin();
  } else if (mouseButton == RIGHT) {
    scene.mouseTranslate();
  } else if (mouseButton == CENTER){
    scene.scale(scene.mouseDX());
  }
}

public void mouseReleased(MouseEvent event){
  Vector vector = new Vector(scene.mouseX(), scene.mouseY());
  if(scene.node() != null)
    if(scene.node() instanceof  InteractiveJoint){
      if(((InteractiveJoint) scene.node()).desiredTranslation() != null) lastCommand = "Adding Joint";
        scene.interact(scene.node(), "Add", scene, vector, skeleton);
    }
}

public void mouseWheel(MouseEvent event) {
  scene.scale(event.getCount() * 20);
}

public void mouseClicked(MouseEvent event) {
  if (event.getCount() == 2) {
    if (event.getButton() == LEFT) {
      if (event.isShiftDown())
        if(scene.node() != null){
          lastCommand = "Removing Joint and its children";
          scene.interact(scene.node(),"Remove");
        }
        else
          scene.focus();
    }
    else {
      scene.align();
    }
  }
}

public void keyPressed() {
  if (key == 'J' || key == 'j') {
    lastCommand = "Adding Joint on the middle of the scene";
    InteractiveJoint initial = new InteractiveJoint(true, color(random(255),random(255),random(255)), radius, false);
  } else if (key == 'P' || key == 'p') {
    lastCommand = "Skeleton information saved on : " + sketchPath() + jsonPath;
    skeleton.save(sketchPath() + jsonPath);
  } else if (key == 'E' || key == 'e') {
    if (scene.node() != null) {
      lastCommand = "Setting Joint translation to (0,0,0)";
      scene.node().setTranslation(new Vector());
      scene.node().tagging = false;
    }
  }
}


//Adapted from http://www.cutsquash.com/2015/04/better-obj-model-loading-in-processing/
public  PShape createShapeTri(PShape r, String texture, float size) {
  float scaleFactor = size / max(r.getWidth(), r.getHeight());
  PImage tex = loadImage(texture);
  PShape s = createShape();
  s.beginShape(TRIANGLES);
  s.noStroke();
  s.texture(tex);
  s.textureMode(NORMAL);
  for (int i=100; i<r.getChildCount (); i++) {
    if (r.getChild(i).getVertexCount() ==3) {
      for (int j=0; j<r.getChild (i).getVertexCount(); j++) {
        PVector p = r.getChild(i).getVertex(j).mult(scaleFactor);
        PVector n = r.getChild(i).getNormal(j);
        float u = r.getChild(i).getTextureU(j);
        float v = r.getChild(i).getTextureV(j);
        s.normal(n.x, n.y, n.z);
        s.vertex(p.x, p.y, p.z, u, v);
      }
    }
  }
  s.endShape();
  return s;
}

public PShape createShapeQuad(PShape r, String texture, float size) {
  float scaleFactor = size / max(r.getWidth(), r.getHeight());
  PImage tex = loadImage(texture);
  PShape s = createShape();
  s.beginShape(QUADS);
  s.noStroke();
  s.texture(tex);
  s.textureMode(NORMAL);
  for (int i=100; i<r.getChildCount (); i++) {
    if (r.getChild(i).getVertexCount() ==4) {
      for (int j=0; j<r.getChild (i).getVertexCount(); j++) {
        PVector p = r.getChild(i).getVertex(j).mult(scaleFactor);
        PVector n = r.getChild(i).getNormal(j);
        float u = r.getChild(i).getTextureU(j);
        float v = r.getChild(i).getTextureV(j);
        s.normal(n.x, n.y, n.z);
        s.vertex(p.x, p.y, p.z, u, v);
      }
    }
  }
  s.endShape();
  return s;
}
