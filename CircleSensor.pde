float tolerance = .08;

abstract class Sensor {
  abstract void render();
  abstract void sense(int[] img);
  abstract void calibrate(int[] img);
}


class CircleSensor extends Sensor {
  int[] inside, boundary;
  color insideColor, boundaryColor;
  color defaultInsideColor, defaultBoundaryColor;
  boolean active = false;
  int note;
  float x, y, r, b;
  void setPosition(float x, float y) {
    this.x = x;
    this.y = y;
  }
  void setSize(float r, float b) {
    this.r = r;
    this.b = b;
  }
  void setNote(int note) {
    this.note = note;
  }
  void initialize(int w, int h) {
    inside = new int[0];
    boundary = new int[0];
    float ir = w * r, or = ir + (w * b);
    int basex = (int) (w * x), basey = (int) (h * y);
    for(int i = (int) -or; i <= or; i++) {
      for(int j = (int) -or; j <= or; j++) {
        float distance = sqrt(sq(i) + sq(j));
        int cx = basex + i, cy = basey + j;
        if(cx > 0 && cx < width && cy > 0 && cy < height) {
          int p = (cy * w) + cx;
          if(distance < ir) {
            inside = append(inside, p);
          } else if (distance < or) {
            boundary = append(boundary, p);
          }
        }
      }
    }
  }
  void render() {
    pushMatrix();
    translate(x * width, y * height);
    
      fill(1);   
      stroke(1);
      strokeWeight(b * width);
      float mid = (r + b) * width;
      ellipse(0, 0, mid, mid);
      
      strokeWeight(0);
      stroke(0);
      float len = r * width * .5;
      line(0, -len, 0, len);
      line(-len, 0, len, 0);
      
      noFill();
      strokeWeight(2);
      if(active)
        stroke(0, 1, 0);
      else
        stroke(1, 0, 0);
      mid = (r + b + b) * width;
      ellipse(0, 0, mid, mid);
      
    popMatrix();
  }
  void sense(int[] img) {
    insideColor = average(img, inside);
    boundaryColor = average(img, boundary);
    
    boolean sameInside = sameColor(insideColor, defaultInsideColor, tolerance);
    boolean sameBoundary = sameColor(boundaryColor, defaultBoundaryColor, tolerance);
    if(sameBoundary) // as long as the boundary is maintained
      active = !sameInside; // update the contents
  }
  void sound(float lastt, float curt) {
    if(active && lastt <= x && curt > x)
      trigger(note);
  }
  void calibrate(int[] img) {
    sense(img);
    defaultInsideColor = insideColor;
    defaultBoundaryColor = boundaryColor;
  }
}
