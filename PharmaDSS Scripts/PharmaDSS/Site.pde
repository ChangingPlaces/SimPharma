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
    for(int i=siteBuild.size()-1; i>=0; i--) {
      if (siteBuild.get(i).demolish) {
        siteBuild.remove(i);
        if (session.selectedSiteBuild >= i && i != 0) session.selectedSiteBuild--; // moves index back to avoid crash
      } else {
        siteBuild.get(i).updateBuild();
      }
    }
  }
  
  void draw(int x, int y, int w, int h, float max, boolean selected) {
    int infoGap = 3; // number of MARGIN widths
    float sideEx = (h - infoGap*MARGIN)*(capEx)/max;
    float sideGn = (h - infoGap*MARGIN)*(capEx + capGn)/max;
    int RnD_W = 35;
    int RnD_gap = 10;
    
    // Draw Site Selection
    if (selected) {
      fill(HIGHLIGHT, 40);
      stroke(HIGHLIGHT, 80);
      strokeWeight(1);
      rect(x - 10, y - 30, w + RnD_W + 2*RnD_gap + 10, height - MARGIN - y + 15, 5);
      noStroke();
    }
    
    // Draw Site/Factory PNG
    int picW = w + RnD_gap + RnD_W;
    int picH = infoGap*MARGIN - RnD_gap;
    PImage pic;
    //rect(x, y, picW, picH, 5);
    if (textColor == 0) {
      pic = sitePNG_BW;
    } else {
      pic = sitePNG;
    }
    tint(255, 75);
    image(pic, x, y, picW, picH);
    tint(255, 255);
    
    // Draw Baseline Total External and Green Field Rectangle Capacities
    stroke(textColor, 100);
    strokeWeight(2);
    fill(textColor, 50);
    rect(x, infoGap*MARGIN + y, w, sideGn + 10, 5);
    noStroke();
    fill(background);
    rect(x + 5, infoGap*MARGIN + y + 5, w - 10, sideEx, 5);
    
    // Draw Label Text
    fill(textColor);
    textAlign(LEFT);
    text("Site " + name, x, y - 15);
    fill(textColor);
    textAlign(CENTER);
    //text(capEx + agileModel.WEIGHT_UNITS, x + w/2, infoGap*MARGIN + y + 10 + sideEx/2);
    text("( " + (capGn+capEx) + agileModel.WEIGHT_UNITS + " )", x + w/2, infoGap*MARGIN + y + sideGn + 0.5*MARGIN);
    
    // Draw RND Capacity Slots
    for (int i=0; i<limitRnD; i++) {
      fill(background);
      stroke(textColor, 100);
      strokeWeight(2);
      rect(x + w + RnD_gap, infoGap*MARGIN + y + i*(RnD_W + RnD_gap), RnD_W, RnD_W, 5);
      textAlign(CENTER);
      fill(textColor, 150);
      text("R&D", x + w + RnD_gap + 0.5*RnD_W, infoGap*MARGIN + y + i*(RnD_W + RnD_gap) + 0.5*RnD_W + 5);
    }
    noStroke();
    fill(textColor);
    
    // Draw Build Allocations within Site Square
    float offset = 0;
    float size;
    for (int i=0; i<siteBuild.size(); i++) {
      
      if ( agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).timeEnd < session.current.TURN || siteBuild.get(i).demolish == true) {
        // Color NCE Not Viable or build flagged for demolition
        fill(#CC0000, 150);
      } else if (siteBuild.get(i).built == false) {
        // Color Under Construction
        fill(abs(100-textColor), 150);
      } else {
        // Color NCE Active Production
        fill(#0000CC, 150);
      }
      if (session.selectedSiteBuild == i && selected) {
        stroke(HIGHLIGHT);
        strokeWeight(3);
      } else {
        stroke(255, 200);
        strokeWeight(1);
      }
      size = (h - infoGap*MARGIN) * siteBuild.get(i).capacity / max;
      rect(x + 7, y + 5 + 1 + offset + infoGap*MARGIN, w - 14, size - 2, 5);
      offset += size;
      noStroke();
      fill(textColor);
      textAlign(CENTER);
      text(agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).name + " - " + siteBuild.get(i).capacity + "t", x + 0.5*w, y + offset + 10 - size/2 + infoGap*MARGIN);
    }
  }
  
}
