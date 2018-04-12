class FaceVertex extends MeshRepresentation {
  int[][] facelist;

  PVector[] vertexlist_pos;
  ArrayList<ArrayList<Integer>> vertexlist_faces;

  public FaceVertex(int scale, RenderType rt, Boolean retained, int[][] facelist, PVector[] vertexlist_pos) {
    super(scale, rt, retained);
    this.facelist=facelist;
    this.vertexlist_pos=vertexlist_pos;
    this.vertexlist_faces = new ArrayList<ArrayList<Integer>>();
    for (int i = 0; i<vertexlist_pos.length; i++) {
      ArrayList<Integer> a = new ArrayList<Integer>();
      for (int j = 0; j<facelist.length; j++) {
        if (facelist[j][0] == i || facelist[j][1] == i || facelist[j][2] == i) {
          a.add(i);
        }
      }
      vertexlist_faces.add(a);
    }
    generateShapes();
  }

  protected void generateShapes() {
    RenderType save = render_type;
    for (RenderType r : RenderType.values()) {
      render_type = r;
      shapes[r.ordinal()] = createShape();
      shapes[r.ordinal()].beginShape(getKind());
      applyStyle(shapes[r.ordinal()]);
      for (int j = 0; j<facelist.length; j++) 
        for (int k = 0; k<3; k++)
          shapes[r.ordinal()].vertex(vertexlist_pos[facelist[j][k]].x * scale, vertexlist_pos[facelist[j][k]].y * scale, vertexlist_pos[facelist[j][k]].z * scale);
      shapes[r.ordinal()].endShape();
    }
    render_type = save;
  }

  public void render() {
    //print("FV"+retained+"\n");
    if (retained) {
      shape(shapes[render_type.ordinal()], 0, 0);
    } else {
      beginShape(getKind());
      for (int j = 0; j<facelist.length; j++) 
        for (int k = 0; k<3; k++)
          vertex(vertexlist_pos[facelist[j][k]].x * scale, vertexlist_pos[facelist[j][k]].y * scale, vertexlist_pos[facelist[j][k]].z * scale);
      endShape();
    }
  }
}