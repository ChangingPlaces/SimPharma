// Site Characteristics for a given manufacturing site (i.e. Cork, Jurong)
class Site {
  
  // Name of Site
  String name;
  
  // Capacity at site, existing and Greenfield
  float capEx, capGn;
  
  // Limit to the amount of NCEs on site for RnD
  int limitRnD;
  
  // A List of Manufacturing Capacities (Build objects) assigned to the site
  ArrayList<Build> siteBuild;
  ArrayList<Build> siteRND;
  
//  // Salary Modifier for Site Conditions (i.e. 0.9 or 1.2 of Labour Cost)
//  float salaryMod;
  
  // Basic Constructor
  Site() {}
  
  // The Class Constructor
  Site(String name, float capEx, float capGn, int limitRnD) {
    this.name = name;
    this.capEx = capEx;
    this.capGn = capGn;
    this.limitRnD = limitRnD;
    
    siteBuild = new ArrayList<Build>();
    siteRND = new ArrayList<Build>();
  }
  
  // Update the state of all builds on site
  void updateBuilds() {
    for(int i=0; i<siteBuild.size(); i++) {
      siteBuild.get(i).updateBuild();
    }
  }
  
  void draw(int x, int y, boolean selected) {
    float scaler = 6; // 
    float sideEx = capEx;
    float sideGn = capEx + capGn; 
    float wScale = 30;
    float hScale = 0.12;
    
    // Draw Baseline Total External and Green Field Rectangle Capacities
    stroke(textColor, 100);
    strokeWeight(2);
    fill(205, 250, 150, 150);
    rect(x, y, wScale*scaler, hScale*scaler*sideGn + 10, 5);
    noStroke();
    fill(background);
    rect(x + 5, y + 5, wScale*scaler - 10, hScale*scaler*sideEx, 5);
    
    // Draw Label Text
    fill(textColor);
    textAlign(LEFT);
    text("Site " + name, x, y - 10);
    fill(105, 150, 050);
    textAlign(RIGHT);
    text("Greenfield " + capGn + " " + agileModel.WEIGHT_UNITS, x + wScale*scaler - 10, y + hScale*scaler*sideGn - 10);
    textAlign(CENTER);
    text("Existing", x + 5 + wScale*scaler*sideEx/2, y + 5 + hScale*scaler*sideEx/2 + 0);
    text(capEx + " " + agileModel.WEIGHT_UNITS, x + 5 + wScale*scaler/2, y + 10 + hScale*scaler*sideEx/2);
    
    // Draw RND Capacity
    int RnD_W = 50;
    int RnD_gap = 15;
    for (int i=0; i<limitRnD; i++) {
      noFill();
      stroke(textColor, 100);
      strokeWeight(2);
      rect(x + wScale*scaler + RnD_gap, y + i*(RnD_W + RnD_gap), RnD_W, RnD_W, 5);
      textAlign(CENTER);
      fill(textColor, 150);
      text("R&D", x + wScale*scaler + RnD_gap + 0.5*RnD_W, y + i*(RnD_W + RnD_gap) + 0.5*RnD_W + 5);
    }
    noStroke();
    fill(textColor);
    
    // Draw Build Allocations within Site Square
    if (gameMode) {
      float offset = 0;
      float size;
      for (int i=0; i<siteBuild.size(); i++) {
        
        if (siteBuild.get(i).built == false) {
          // Color Under Construction
          fill(abs(100-textColor), 150);
        } else if ( agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).timeEnd < session.current.TURN) {
          // Color NCE Not Viable
          fill(#CC0000, 150);
        } else {
          // Color NCE Active Production
          fill(#0000CC, 150);
        }
        stroke(255, 200);
        strokeWeight(2);
        size = hScale*scaler*siteBuild.get(i).capacity;
        rect(x + 7, y + 5 + 3 + offset, wScale*scaler - 14, size - 6, 5);
        offset += size;
        noStroke();
        fill(textColor);
        textAlign(CENTER);
        text(agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).name, x + 0.5*wScale*scaler, y + offset + 10 - size/2);
      }
    }
    
      
    // Draw Site Selection
    if (selected) {
      noFill();
      stroke(#CCCC00, 100);
      strokeWeight(4);
      rect(x - 10, y - 30, wScale*scaler + RnD_W + 2*RnD_gap + 10, hScale*scaler*sideGn + 50, 5);
      noStroke();
    }
  }
  
}
