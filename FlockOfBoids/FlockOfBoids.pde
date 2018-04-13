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

float[][]path={{640.0, 360.0, 1886.4425, 0.0, 0.0, 0.0, 1.0}, 
  {640.0, 360.0, 869.2525, 0.0, 0.0, 0.0, 1.0}, 
  {640.0, 360.0, 418.4834, 0.0, 0.0, 0.0, 1.0}, 
  {468.41962, 320.15305, 424.23468, 0.12102556, -0.44434473, -0.033873517, 0.88699675}, 
  {203.92859, 268.38782, 222.9343, 0.1787218, -0.7437343, -0.018492391, 0.6438757}, 
  {394.8198, 262.49805, -67.24667, 0.22092962, -0.92582506, 0.04403913, 0.3034776}, 
  {682.9353, 283.46027, -143.60818, 0.22967799, -0.9683609, 0.093807235, -0.026934996}, 
  {921.96533, 245.15018, -34.35785, 0.19770028, -0.91131204, 0.20371269, -0.29820484}, 
  {1066.9586, 211.62221, 286.56213, 0.12176818, -0.7069967, 0.33661538, -0.609933}, 
  {1892.4865, -74.58904, 260.9125, 0.12176818, -0.7069967, 0.33661538, -0.609933}, 
  {2148.1897, -163.24153, 252.9677, 0.12176818, -0.7069967, 0.33661538, -0.609933}, 
  {583.9621, 300.7055, 1894.9838, -0.023416907, 0.010086668, 0.3470658, -0.93749416}, 
  {-877.09973, 314.99332, 797.00757, -0.15797931, 0.56527406, 0.19487377, -0.7858321}, 
};

boolean benchmark = true;
boolean viewFrustumCulling = true;
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
boolean retained = false;

ArrayList<BenchmarkInstance> benches = new ArrayList<BenchmarkInstance>();

Interpolator eyeInterpolator;
MeshRepresentation[] mrs;
String[] txt_mrs = new String[]{"Vertex Vertex", "Face Vertex"};

int initBoidNum = 900; // amount of boids to start the program with
ArrayList<Boid> flock = new ArrayList();
Node avatar;
boolean animate = true;

FaceVertex fv;
VertexVertex vv;
int scale = 3;
int n_visible_birds = 0;
FPSStats fps;

void initBoids() {
  // create and fill the list of boids
  for (int i = 0; i < initBoidNum; i++)
    flock.get(i).init(new Vector(flockWidth / 2, flockHeight / 2, flockDepth / 2));
}

int bench_it = 0;
void setup() {
  for (int repr = 0; repr<2; repr++) {
    for (int rend = 0; rend<4; rend++) {
      benches.add(new BenchmarkInstance(repr, true, rend, true));
      benches.add(new BenchmarkInstance(repr, true, rend, false));
      benches.add(new BenchmarkInstance(repr, false, rend, true));
      benches.add(new BenchmarkInstance(repr, false, rend, false));
    }
  }

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

  eyeInterpolator = new Interpolator(eye);

  //interactivity defaults to the eye
  scene.setDefaultGrabber(eye);
  scene.fitBall();

  for (int i = 0; i < initBoidNum; i++)
    flock.add(new Boid(new Vector(flockWidth / 2, flockHeight / 2, flockDepth / 2), vv));

  if (benchmark) {
    for (float[] d : path) {
      eyeInterpolator.addKeyFrame(new Frame(new Vector(d[0], d[1], d[2]), new Quaternion(d[3], d[4], d[5], d[6])));
    }
    eyeInterpolator.start();
    benches.get(0).apply();
    print("MeshRepresentation\tRenderMode\tRetained\tViewFrustumCulling\tAverageFPS\n");
  }
  fps = new FPSStats();
}


void draw() {
  background(color(10, 50, 25));
  ambientLight(128, 128, 128);
  directionalLight(255, 255, 255, 0, 1, -100);
  walls();
  n_visible_birds=0;
  // Calls Node.visit() on all scene nodes.
  scene.traverse();

  fps.add((int)frameRate);

  scene.beginScreenCoordinates();
  fps.render(50, 50, 300, 150);
  textSize(15);
  text(txt_mrs[repr], 50, 25);
  text(retained?"Retained":"Immediate", 300, 25);
  text(RenderType.values()[mode].name(), 500, 25);
  text("Visible birds: "+n_visible_birds, 800, 25);

  scene.endScreenCoordinates();
  if (benchmark) {
    benches.get(bench_it).add(frameRate);
    if (!eyeInterpolator.started()) {
      print(benches.get(bench_it)+"\n");
      bench_it++;
      if (bench_it>=benches.size()) {
        benchmark = false;
      } else {
        benches.get(bench_it).apply();
        initBoids();
        eyeInterpolator.start();
      }
    }
  }
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
  if (benchmark)
    return;
  switch (key) {
  case '1':
    //print(a.position(),a.orientation().x(), a.orientation().y(), a.orientation().z(), a.orientation().w(), "\n");
    eyeInterpolator.addKeyFrame(scene.eye().get());
    break;
  case 'b':
    eyeInterpolator.toggle();
    break;
  case 'n':
    eyeInterpolator.clear();
    break;
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