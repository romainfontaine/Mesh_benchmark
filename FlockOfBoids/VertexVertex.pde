import java.util.*;
class VertexVertex extends MeshRepresentation {
  PVector[] vertexlist_pos;
  ArrayList<ArrayList<Integer>> vertexlist;

  public VertexVertex(int scale, RenderType rt, Boolean retained, PVector[] vertexlist_pos, ArrayList<ArrayList<Integer>> vertexlist) {
    super(scale, rt, retained);
    this.vertexlist_pos = vertexlist_pos;
    this.vertexlist = vertexlist;
    generateShapes();
  }

  protected void generateShapes() {
    RenderType save = render_type;
    for (RenderType r : RenderType.values()) {
      render_type = r;
      shapes[r.ordinal()] = createShape();
      HashSet<PVector> facelist = getFaceList();

      shapes[r.ordinal()].beginShape(getKind());
      applyStyle(shapes[r.ordinal()]);
      for (PVector v : facelist) {
        int[] i = new int[]{(int)v.x, (int)v.y, (int)v.z};
        for (int k : i)
          shapes[r.ordinal()].vertex(vertexlist_pos[k].x * scale, vertexlist_pos[k].y * scale, vertexlist_pos[k].z * scale);
      }

      shapes[r.ordinal()].endShape();
    }
    render_type = save;
  }

  private HashSet<PVector> getFaceList() {
    HashSet<PVector> facelist = new HashSet<PVector>();
    for (int i = 0; i<vertexlist_pos.length; i++) {
      for (int j = 0; j<vertexlist.get(i).size(); j++) {
        for (int k = 0; k<vertexlist.get(i).size(); k++) {
          if (i<vertexlist.get(i).get(j) && vertexlist.get(i).get(j)<vertexlist.get(i).get(k)) {
            facelist.add(new PVector(i, vertexlist.get(i).get(j), vertexlist.get(i).get(k)));
          }
        }
      }
    }
    return facelist;
  }

  public void render() {
    //print("VV"+retained+"\n");
    if (retained) {
      shape(shapes[render_type.ordinal()], 0, 0);
    } else {
      HashSet<PVector> facelist = getFaceList();
      beginShape(getKind());
      for (PVector v : facelist) {
        int[] i = new int[]{(int)v.x, (int)v.y, (int)v.z};
        for (int k : i)
          vertex(vertexlist_pos[k].x * scale, vertexlist_pos[k].y * scale, vertexlist_pos[k].z * scale);
      }
      endShape();
    }
  }
}