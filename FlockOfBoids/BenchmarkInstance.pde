class BenchmarkInstance {
  int representation;
  boolean isretained;
  boolean frustumCulling;
  int render_type;
  ArrayList<Double> fps;
  public BenchmarkInstance(int representation, boolean isretained, int render_type, boolean frustumCulling) {
    this.representation = representation;
    this.isretained = isretained;
    this.render_type = render_type;
    this.frustumCulling = frustumCulling;
    fps = new ArrayList<Double>();
  }
  public double computeAvgFPS() {
    double s = 0;
    for (double d : fps) {
      s+=d;
    }
    return s/fps.size();
  }

  public void apply() {
    mode = this.render_type;
    repr = this.representation;
    retained = this.isretained;
    viewFrustumCulling = frustumCulling;

    for (MeshRepresentation mr : mrs) 
      mr.setRenderType(mode);
    for (MeshRepresentation mr : mrs) 
      mr.setRetained(retained);
    for (int i = 0; i < initBoidNum; i++)
      flock.get(i).setRepresentation(mrs[repr]);
  }

  public void add(double fps) {
    this.fps.add(fps);
  }

  @Override
    public String toString() {
    return String.format("%s\t%s\t%b\t%b\t%f", representation==0?"VV":"FV", RenderType.values()[render_type].name(), isretained, frustumCulling, computeAvgFPS());
  }
}