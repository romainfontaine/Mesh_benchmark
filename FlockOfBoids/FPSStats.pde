
class FPSStats {
  int fps_count = 0;

  int fps_curr_idx = 0;
  int[] fps;
  int fps_max;
  public FPSStats()
  { 
    this(500); //5 secs @ 100fps
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
  }
  public void render(int ox, int oy, int w, int h) {
    pushStyle();
    stroke(#FFFFFF);
    line(ox, oy, 0, ox, oy+h, 0);
    line(ox, oy+h, 0, ox+w, oy+h, 0);
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
      int y = (h+oy) - (int)(h*(avg/100));
      int x = ox+(int)((((float)i)/fps_max)*w);
      if (i == 0) {
        line(x, y, 0, x, y, 0);
      } else {
        line(prevx, prevy, 0, x, y, 0);
      }
      prevx = x;
      prevy = y;
    }
    global_avg/=fps_count;

    textSize(h/10);
    textAlign(RIGHT);
    text("100", ox, oy, 0);
    text(str((int)avg), ox, (oy+h)-avg/100*h);
    text("0", ox, oy+h, 0);
    textAlign(CENTER);
    text("Average FPS: "+nf(global_avg, 2, 2), ox+w/2, oy);

    popStyle();
  }
}