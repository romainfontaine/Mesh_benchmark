/**
 * Flock of Boids
 * by Jean Pierre Charalambos.
 * 
 * This example displays the 2D famous artificial life program "Boids", developed by
 * Craig Reynolds in 1986 and then adapted to Processing in 3D by Matt Wetmore in
 * 2010 (https://www.openprocessing.org/sketch/6910#), in 'third person' eye mode.
 * Boids under the mouse will be colored blue. If you click on a boid it will be
 * selected as the scene avatar for the eye to follow it.
 *
 * Press ' ' to switch between the different eye modes.
 * Press 'a' to toggle (start/stop) animation.
 * Press 'p' to print the current frame rate.
 * Press 'm' to change the boid visual mode.
 * Press 'v' to toggle boids' wall skipping.
 * Press 's' to call scene.fitBallInterpolation().
 */

import frames.input.*;
import frames.input.event.*;
import frames.primitives.*;
import frames.core.*;
import frames.processing.*;

Scene scene;
int flockWidth = 1280;
int flockHeight = 720;
int flockDepth = 600;
boolean avoidWalls = true;

// visual modes
// 0. Faces and edges
// 1. Wireframe (only edges)
// 2. Only faces
// 3. Only points
int mode;


// Mesh Representation
// 0. Vertex Vertex
// 1. Face Vertex
int repr = 0;

MeshRepresentation[] mrs;
String[] txt_mrs = new String[]{"Vertex Vertex", "Face Vertex"};

int initBoidNum = 900; // amount of boids to start the program with
ArrayList<Boid> flock;
Node avatar;
boolean animate = true;

boolean retained = false;
FaceVertex fv;
VertexVertex vv;
int scale = 3;
int n_visible_birds = 0;
void setup() {
  int[][] facelist = new int[][]{
    {0, 1, 2}, 
    {0, 1, 3}, 
    {0, 3, 2}, 
    {3, 1, 2}, 
  };
  PVector[] vertexlist_pos = new PVector[]{
    new PVector(3, 0, 0), 
    new PVector(-3, 2, 0), 
    new PVector(-3, -2, 0), 
    new PVector(-3, 0, 2), 
  };
  fv = new FaceVertex(scale, RenderType.FACES_EDGES, retained, facelist, vertexlist_pos);
  ArrayList<ArrayList<Integer>> vertexlist = new ArrayList<ArrayList<Integer>>();
  vertexlist.add(0, new ArrayList<Integer>() {
    {
      add(1);
      add(2);
      add(3);
    }
  }
  );
  vertexlist.add(1, new ArrayList<Integer>() {
    {
      add(0);
      add(2);
      add(3);
    }
  }
  );
  vertexlist.add(2, new ArrayList<Integer>() {
    {
      add(0);
      add(1);
      add(3);
    }
  }
  );
  vertexlist.add(3, new ArrayList<Integer>() {
    {
      add(0);
      add(1);
      add(2);
    }
  }
  );
  vv = new VertexVertex(scale, RenderType.FACES_EDGES, retained, vertexlist_pos, vertexlist);

  mrs = new MeshRepresentation[]{vv, fv};

  size(1000, 800, P3D);
  scene = new Scene(this);
  scene.setBoundingBox(new Vector(0, 0, 0), new Vector(flockWidth, flockHeight, flockDepth));
  scene.enableBoundaryEquations();
  scene.setAnchor(scene.center());
  Eye eye = new Eye(scene);
  scene.setEye(eye);
  scene.setFieldOfView(PI / 3);
  //interactivity defaults to the eye
  scene.setDefaultGrabber(eye);
  scene.fitBall();
  // create and fill the list of boids
  flock = new ArrayList();
  for (int i = 0; i < initBoidNum; i++)
    flock.add(new Boid(new Vector(flockWidth / 2, flockHeight / 2, flockDepth / 2), vv));
}

class FPSStats {
  int fps_count = 0;

  int fps_curr_idx = 0;
  int[] fps;
  int fps_max;
  public FPSStats()
  { 
    this(1000); //10 secs @ 100fps
  }
  public FPSStats(int fps_max) { 
    this.fps_max = fps_max;
    this.fps = new int[this.fps_max];
  }
  public void add(int fps) {
    this.fps[this.fps_curr_idx]=fps;
    this.fps_curr_idx++;
    this.fps_curr_idx%=this.fps_max;

    this.fps_count++;
    this.fps_count = this.fps_count>fps_max?fps_max:this.fps_count;
    render();
  }
  public void render() {

    pushStyle();
    stroke(#FFFFFF);
    line(100, 100, 0, 100, 600, 0);
    line(100, 600, 0, 1100, 600, 0);
    stroke(#FFA400);

    int step = 5;
    int prevx = 0, prevy=0;
    float avg = 0;
    float global_avg = 0;
    for (int i = 0; i<fps_count; i+=step) {
      int count = 0;
      int sum = 0;
      for (int j = i; j<i+step && j<fps_count; j++) {
        sum+=fps[j];
        global_avg+=fps[j];
        count++;
      }
      avg = sum/count;
      int y = 600 - (int)(500*(avg/100));
      int x = 100+i;
      if (i == 0) {
        line(x, y, 0, x, y, 0);
      } else {
        line(prevx, prevy, 0, x, y, 0);
      }
      prevx = x;
      prevy = y;
    }
    global_avg/=fps_count;

    textSize(32);
    textAlign(RIGHT);
    text("100", 90, 100, 0);
    text(str((int)avg), 90, 600-avg/100*500);
    text("0", 90, 600, 0);
    textAlign(LEFT);
    text(str(global_avg), 90, 700);

    popStyle();
  }
}

FPSStats s = new FPSStats();

void draw() {
  background(color(10, 50, 25));
  ambientLight(128, 128, 128);
  directionalLight(255, 255, 255, 0, 1, -100);
  walls();
  n_visible_birds=0;
  // Calls Node.visit() on all scene nodes.
  scene.traverse();
  s.add((int)frameRate);
  text(txt_mrs[repr], 300, 700);
  text(retained?"Retained":"Immediate", 600, 700);
  text(RenderType.values()[mode].name(), 900, 700);
  text(n_visible_birds, 1200, 700);
}

void walls() {
  pushStyle();
  noFill();
  stroke(255);

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

void keyPressed() {
  switch (key) {
  case 'a':
    animate = !animate;
    break;
  case 's':
    if (scene.eye().reference() == null)
      scene.fitBallInterpolation();
    break;
  case 'p':
    println("Frame rate: " + frameRate);
    break;
  case 'v':
    avoidWalls = !avoidWalls;
    break;
  case 'm':
    mode = mode < 3 ? mode+1 : 0;
    for (MeshRepresentation mr : mrs) 
      mr.setRenderType(mode);
    break;
  case 'r':
    retained = !retained;
    for (MeshRepresentation mr : mrs) 
      mr.setRetained(retained);
    break;
  case 't':
    repr++;
    repr%=mrs.length;
    for (int i = 0; i < initBoidNum; i++)
      flock.get(i).setRepresentation(mrs[repr]);
    break;
  case ' ':
    if (scene.eye().reference() != null) {
      scene.lookAt(scene.center());
      scene.fitBallInterpolation();
      scene.eye().setReference(null);
    } else if (avatar != null) {
      scene.eye().setReference(avatar);
      scene.interpolateTo(avatar);
    }
    break;
  }
}