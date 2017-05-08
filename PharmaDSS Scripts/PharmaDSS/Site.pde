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
  
  void draw(int x, int y) {
    float scaler = 6; // 
    float sideEx = sqrt(capEx);
    float sideGn = sqrt(capEx + capGn); 
    float wScale = 1.25;
    float hScale = 1.5;
    
//    fill(#CDDB90);
    fill(205, 250, 150);
    rect(x, y, wScale*scaler*sideGn, hScale*scaler*sideGn, 5);
    fill(255, 200);
    rect(x + 5, y + 5, wScale*scaler*sideEx, hScale*scaler*sideEx, 5);
    noStroke();
    
    fill(textColor);
    textAlign(LEFT);
    text("Site " + name, x, y - 10);
    fill(0);
    textAlign(RIGHT);
    text("Greenfield " + capGn + " " + agileModel.WEIGHT_UNITS, x + wScale*scaler*sideGn - 10, y + hScale*scaler*sideGn - 10);
    textAlign(CENTER);
    text("Existing", x + 5 + wScale*scaler*sideEx/2, y + 5 + hScale*scaler*sideEx/2 + 0);
    text(capEx + " " + agileModel.WEIGHT_UNITS, x + 5 + wScale*scaler*sideEx/2, y + 5 + hScale*scaler*sideEx/2 + 15);

  }
  
}
