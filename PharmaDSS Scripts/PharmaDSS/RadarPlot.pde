boolean displayRadar = true;
RadarPlot kpi;

void setupRadar() {
  
  kpi = new RadarPlot(5);
  kpi.setName(0, "CAPEX");
  kpi.setName(0, "OPEX");
  kpi.setName(0, "COGs");
  kpi.setName(0, "ATMDEM");
  kpi.setName(0, "SECSUP");
  
  for (int i=0; i<kpi.nRadar; i++) {
    kpi.setScore(i, random(1.0));
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
      scores.set(index, value);
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
    
    fill(textColor);
    strokeWeight(1);
    
    if (nRadar > 2) {
      
      //Draw Score Axes
      for (int i=0; i<nRadar; i++) {
        //Draw Score Axes
        stroke(#999999);
        line(x, y, d*cos(rot+i*2*PI/nRadar) + x, d*sin(rot+i*2*PI/nRadar) + y);
       
      }
      
      //Draw Labels
      translate(x,y);
      rotate(rot);
      for (int i=0; i<nRadar; i++) {
        //Draw Labels
        if (hilite == i) {
          fill(#CCCCCC);
        } else {
          fill(#666666);
        }
        
        if (PI/2 < (2*PI*i/nRadar+rot) && (2*PI*i/nRadar+rot) < 3*PI/2) { //Flips text upside down
          rotate(PI);
          textAlign(RIGHT);
  
          text(names.get(i), - d - 48, 0.4*48);
          
          textAlign(LEFT);
          rotate(-PI);
        } else {
          text(names.get(i), d+48, 0.4*48);
        }
        rotate(2*PI/nRadar);
      }
      rotate(-rot);
      translate(-x,-y);
      
      //Draw Score Fills
      for (int i=0; i<nRadar; i++) {
        noStroke();
        //Draw Score Fills
        if (radarMode == 0) {
          fill(#00FFFF);

        } else if (radarMode == 1) {
          fill(255*(1- (scores.get(i)+scores.get((i+1)%nRadar))/2 ), 255*(scores.get(i)+scores.get((i+1)%nRadar))/2, 0);

        } else if (radarMode == 2) {
          fill(255*(1-avgScore), 255*avgScore, 0);

        }
        
        triangle(x, y, scores.get(i)*d*cos(rot+i*2*PI/nRadar) + x, scores.get(i)*d*sin(rot+i*2*PI/nRadar) + y, scores.get((i+1)%nRadar)*d*cos(rot+(i+1)%nRadar*2*PI/nRadar) + x, scores.get((i+1)%nRadar)*d*sin(rot+(i+1)%nRadar*2*PI/nRadar) + y);
      }


      for (int i=0; i<nRadar; i++) {
        //Draw Score Dots
//        strokeWeight(1);
        if (radarMode == 0) {
          fill(#238586);
        } else if (radarMode == 1) {
          fill(255*(1-scores.get(i)), 255*scores.get(i), 0);
        } else if (radarMode == 2) {
          fill(255*(1-scores.get(i)), 255*scores.get(i), 0);
        }
        
        //ellipse(scores.get(i)*d*cos(rot+i*2*PI/nRadar) + x, scores.get(i)*d*sin(rot+i*2*PI/nRadar) + y, 5, 5);
      }
      
      for (int i=0; i<nRadar; i++) {
        //Draw Score Numbers
        if (radarMode == 0) {
          fill(#CCCCCC);
        } else if (radarMode == 1) {
          fill(255*(1-scores.get(i)), 255*scores.get(i), 0);
        } else if (radarMode == 2) {
          fill(255*(1-scores.get(i)), 255*scores.get(i), 0);
        }
        textAlign(CENTER, CENTER);
         text(int(100*scores.get(i)), (d+12)*cos(rot+i*2*PI/nRadar) + x, (d+12)*sin(rot+i*2*PI/nRadar) + y);
      }
    }
  }
}
