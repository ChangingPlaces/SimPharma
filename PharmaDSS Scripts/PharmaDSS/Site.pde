// Site Characteristics for a given manufacturing site (i.e. Cork, Jurong)
class Site {
  
  // Name of Site
  String name;
  
  // Capacity at site, existing and Greenfield
  float capEx, capGn;
  
  // Limit to the amount of NCEs on site for RnD
  int limitRnD;
  
  ArrayList<Build> siteBuild;
  
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
  }
  
  void addBuild(Build newBuild, int PROFILE_INDEX) {
    newBuild.assignProfile(PROFILE_INDEX);
    siteBuild.add(newBuild);
  }
  
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
    float hScale = 0.08;
    
//    fill(#CDDB90);
    fill(205, 250, 150);
    rect(x, y, wScale*scaler, hScale*scaler*sideGn + 10, 5);
    fill(255, 200);
    rect(x + 5, y + 5, wScale*scaler - 10, hScale*scaler*sideEx, 5);
    noStroke();
    
    fill(textColor);
    textAlign(LEFT);
    text("Site " + name, x, y - 10);
    fill(105, 150, 050);
    textAlign(RIGHT);
    text("Greenfield " + capGn + " " + agileModel.WEIGHT_UNITS, x + wScale*scaler - 10, y + hScale*scaler*sideGn - 10);
    textAlign(CENTER);
    text("Existing", x + 5 + wScale*scaler*sideEx/2, y + 5 + hScale*scaler*sideEx/2 + 0);
    text(capEx + " " + agileModel.WEIGHT_UNITS, x + 5 + wScale*scaler/2, y + 10 + hScale*scaler*sideEx/2);
    
    // Draw Allocations
    if (gameMode) {
      float offset = 0;
      float size;
      for (int i=0; i<siteBuild.size(); i++) {
        if (siteBuild.get(i).built == false) {
          fill(abs(100-textColor), 150);
        } else if ( agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).timeEnd < session.current.TURN) {
          fill(#CC0000, 150);
        } else {
          fill(#0000CC, 150);
        }
        //stroke(255, 200);
        //strokeWeight(2);
        size = hScale*scaler*siteBuild.get(i).capacity;
        rect(x + 5, y + 5 + offset, wScale*scaler - 10, size, 5);
        offset += size;
        noStroke();
        fill(textColor);
        textAlign(LEFT);
        text(agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).name, x + wScale*scaler + 10, y + offset - 0.1*size);
      }
    }
      
    // Draw Site Selection
    if (selected) {
      noFill();
      stroke(#CCCC00, 100);
      strokeWeight(4);
      rect(x - 10, y - 30, wScale*scaler + 20, hScale*scaler*sideGn + 50, 5);
      noStroke();
    }
  }
  
}
