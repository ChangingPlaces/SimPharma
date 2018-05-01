boolean displayRadar = false;
RadarPlot radar;

void setupRadar() {
  radar = new RadarPlot(performance.numScores);
  for (int i=0; i<performance.numScores; i++) {
    radar.setName(i, performance.name[i]);
    radar.setScore(i, random(1.0));
  }
  
}

// A class to hold information related to a radar plot
class RadarPlot {
  
  int radarMode = 1; // 0=teal(static);  1 = average score fill; 2 = score cluster fill
  int hilite = -1;
  
  int nRadar; // Number of dimensions in Radar Plot
  ArrayList<Float> scores;
  ArrayList<String> names;
  float avgScore;

  RadarPlot(int num) {
    nRadar = num;
    scores = new ArrayList<Float>();
    names = new ArrayList<String>();
    avgScore = 0;
    
    for (int i=0; i<nRadar; i++) {
      names.add("");
      scores.add(0.5);
    }
  }
  
  void setName (int index, String name) {
    if (index < nRadar) {
      names.set(index, name);
    }
  }
  
  void setScore(int index, float value) {
    if (index < nRadar) {
      scores.set(index, min(value, 1.0));
    }
  }
  
  void updateAvg() {
    avgScore = 0;
    for (int i=0; i<nRadar; i++) {
      avgScore += scores.get(i);
    }
    avgScore /= nRadar;
  }
  
  float rot = 0.25*PI;
  void draw(int x, int y, int d) {  

    strokeWeight(2);   
    if (nRadar > 2) {
      
      //Draws radar plot
      for (int i=0; i<nRadar; i++) {
        
        //Draws axes
        stroke(#999999);
        line(x, y, d*cos(rot+i*2*PI/nRadar) + x, d*sin(rot+i*2*PI/nRadar) + y);
        
        //Determine color
        color RG = color(0);
//        if (radarMode == 0) {
//          fill(#00FFFF); }      
//        else if (radarMode == 1) {
//          //Does a nice red --> yellow --> green gradient instead of showing browns
//          if((scores.get(i)+scores.get((i+1)%nRadar))/2 <= .5){
//            RG = lerpColor(color(250, 0, 0),color(255, 255, 0), (scores.get(i)+scores.get((i+1)%nRadar))/2);}
//          else{
//            RG = lerpColor(color(255, 255, 0),color(0, 200, 0), (scores.get(i)+scores.get((i+1)%nRadar))/2);}
//          fill(RG);} 
//        else if (radarMode == 2) {
//          fill(255*(1-avgScore), 255*avgScore, 0);}
          
          
        //draw fills
        noStroke();
        fill(textColor, 100);
        triangle(x, y, scores.get(i)*d*cos(rot+i*2*PI/nRadar) + x, 
                       scores.get(i)*d*sin(rot+i*2*PI/nRadar) + y, 
                       scores.get((i+1)%nRadar)*d*cos(rot+(i+1)%nRadar*2*PI/nRadar) + x, 
                       scores.get((i+1)%nRadar)*d*sin(rot+(i+1)%nRadar*2*PI/nRadar) + y);
        
        
        //draw end dots
        //ellipse(scores.get(i)*d*cos(rot+i*2*PI/nRadar) + x, scores.get(i)*d*sin(rot+i*2*PI/nRadar) + y, 5, 5);
             
                
        //scores
         textAlign(CENTER, CENTER);
         //recolor for the scores
          if(scores.get(i) <= .5){
            RG = lerpColor(color(250, 0, 0),color(255, 255, 0), scores.get(i));}
          else{
            RG = lerpColor(color(255, 255, 0),color(0, 200, 0), scores.get(i));}
         
         fill(RG); 
         if((d+12)*sin(rot+i*2*PI/nRadar) + y < y){
           text(int(100*scores.get(i)) + "%", (d+12)*cos(rot+i*2*PI/nRadar) + x, (d+12)*sin(rot+i*2*PI/nRadar) + y + 15);
         }
         else{
           text(int(100*scores.get(i)) + "%", (d+12)*cos(rot+i*2*PI/nRadar) + x, (d+12)*sin(rot+i*2*PI/nRadar) + y + 13 + 15);
         }
         
         //names
         fill(textColor);
         textAlign(CENTER);
         if((d+12)*sin(rot+i*2*PI/nRadar) + y - 7 < y){
         text(names.get(i), (d+12)*cos(rot+i*2*PI/nRadar) + x, (d+12)*sin(rot+i*2*PI/nRadar) + y - 7);
         }
         else{
         text(names.get(i), (d+12)*cos(rot+i*2*PI/nRadar) + x, (d+12)*sin(rot+i*2*PI/nRadar) + y + 5);
         }
      }

    }
  }
}
