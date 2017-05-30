PShape s;
color Launch = color(64, 100, 209);
color P3 = color(61, 164, 72);
void drawArrow(float w, float h, float inset, color col){
   s = createShape();
  s.beginShape();
  s.fill(col);
  s.noStroke();
  s.vertex(0, 0);
  s.vertex(inset, h/2);
  s.vertex(0, h);
  s.vertex(w, h);
  s.vertex(w + inset, h/2);
  s.vertex(w, 0);
  s.endShape(CLOSE);
}

void drawPhaseDiagram(){
  drawArrow((profilesW + 1.75*MARGIN)/6, (profilesW + 1.75*MARGIN)/12, (profilesW + 1.75*MARGIN)/20, color(100));
  
  s.setFill(color(100, 100, 100, 150));
  shape(s, 0.25*MARGIN + profilesX, MARGIN - 10);
  shape(s, 0.25*MARGIN + profilesX + (profilesW + 1.75*MARGIN)/5, MARGIN - 10);
  s.setFill(P3);
  shape(s, 0.25*MARGIN + profilesX + 2*(profilesW + 1.75*MARGIN)/5, MARGIN - 10);
  s.setFill(color(100, 100, 100, 150));
  shape(s,0.25*MARGIN + profilesX + 3*(profilesW + 1.75*MARGIN)/5, MARGIN - 10);
  s.setFill(Launch);
  shape(s,0.25*MARGIN + profilesX + 4*(profilesW + 1.75*MARGIN)/5, MARGIN - 10);  

  fill(255);
  textAlign(CENTER, CENTER);
  float arrowwidth = (profilesW + 1.75*MARGIN)/6;
  float ellx = 0.25*MARGIN + profilesX + (profilesW + 1.75*MARGIN)/12;

  float elly =  MARGIN - 10 +  (profilesW + 1.75*MARGIN)/24;
  textSize(textSize - 2);
    text("Candidate",ellx + textSize, elly - textSize/2);
    text("Selection",ellx + textSize, elly + textSize/2);
    textSize(textSize - 1);
     textAlign(LEFT, CENTER);
    text("PIIb", 0.25*MARGIN + profilesX + (profilesW + 1.75*MARGIN)/12 + (profilesW + 1.75*MARGIN)/5  , elly );
    text("PIII", 0.25*MARGIN + profilesX + (profilesW + 1.75*MARGIN)/12 + 2*(profilesW + 1.75*MARGIN)/5  , elly );
    text("File", 0.25*MARGIN + profilesX + (profilesW + 1.75*MARGIN)/12 + 3*(profilesW + 1.75*MARGIN)/5  , elly );
     textAlign(CENTER, CENTER);
    text("Launch", 0.25*MARGIN + profilesX + (profilesW + 1.75*MARGIN)/12 + 4*(profilesW + 1.75*MARGIN)/5  +textSize , elly );

}
