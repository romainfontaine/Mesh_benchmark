enum RenderType {
  FACES_EDGES, ONLY_EDGES, ONLY_FACES, ONLY_POINTS
};

abstract class MeshRepresentation {
  protected RenderType render_type;
  protected PShape[] shapes;
  protected int scale;
  protected Boolean retained;
  protected abstract void generateShapes();
  abstract void render();

  protected MeshRepresentation(int scale, RenderType rt, Boolean retained) {
    this.scale = scale;
    this.retained = retained;
    this.shapes = new PShape[RenderType.values().length];
    render_type = rt;
  }

  protected void setRetained(Boolean r) {
    this.retained = r;
  }

  protected void setRenderType(RenderType rt) {
    render_type=rt;
  }
  
  protected void setRenderType(int rt) {
    setRenderType(RenderType.values()[rt]);
  }
  
  protected int getKind(){
    return render_type==RenderType.ONLY_POINTS?POINTS:TRIANGLES;
  }

  protected void applyStyle(PShape p) {
    p.strokeWeight(2);
    p.stroke(color(0, 255, 0));
    p.fill(color(255, 0, 0, 125));
    switch(render_type) {
    case FACES_EDGES:
      break;
    case ONLY_EDGES:
      p.noFill();
      break;
    case ONLY_FACES:
      p.noStroke();
      break;
    case ONLY_POINTS:
      p.strokeWeight(3);
      break;
    }
  }
}