PShape s;
void drawPhase(float w, float h, float inset, color col, String label){
   s = createShape();
  s.beginShape();
  s.fill(0, 0, 255);
  s.noStroke();
//  s.vertex(360-360, 43-43);
//  s.vertex(378-360, 64-43);
//  s.vertex(360-360, 82-43);
//  s.vertex(439-360, 82-43);
//  s.vertex(457-360, 64-43);
//  s.vertex(439-360, 43-43);

  s.vertex(0, 0);
  s.vertex(inset, h/2);
  s.vertex(0, h);
  s.vertex(w, h);
  s.vertex(w + inset, h/2);
  s.vertex(w, 0);
  
  s.endShape(CLOSE);
}
