// Site Characteristics for a given manufacturing site (i.e. Cork, Jurong)
    ArrayList<float[]> NCEClicks = new ArrayList<float[]>();
    
class Site {
  
  //Array of coords for NCE stuff

    //gives x, y, width, height, id
  
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
      siteBuild.get(i).editing = false;
      if (siteBuild.get(i).demolish) {
        siteBuild.remove(i);
        if (session.selectedSiteBuild >= i && i != 0) session.selectedSiteBuild--; // moves index back to avoid crash
      } else {
        siteBuild.get(i).updateBuild();
      }
    }
  }

  void draw(int x, int y, int w, int h, float max, boolean selected, boolean hover) {
    
    //Display constants for whole card
    int infoGap = 3; // number of MARGIN widths
    float highlightH = (height - 2.8*MARGIN)*.6 -(sitesY-titlesY) - 15; //height of highlighted region
    
    //icon/picture constants
    int RnD_W = 35;
    int RnD_gap = 10;
    int picW = w + RnD_gap + RnD_W;
    int picH = infoGap*MARGIN - RnD_gap;
    PImage pic;  
    
    //Site constants
    float maxCapSites = agileModel.maxCapacity();
    float siteBound = map(capGn+capEx,0, maxCapSites, 0, sitesH/3);
    float siteStart = picH + sitesY;
    
    fill(255);
    
    // Draw Site Selection
    if (selected) {
        fill(HIGHLIGHT, 40);
        noStroke(); 
        rect(x - 10,  y - 20, w + RnD_W + 2*RnD_gap + 10,  highlightH, 5);
        noStroke();
    }
    
    // Draw Site Hover
    if (hover && !(tableTest && mfg.mouseInGrid())) {
        noFill();
        stroke(HIGHLIGHT); 
        strokeWeight(1);
        rect(x - 10,  y - 20, w + RnD_W + 2*RnD_gap + 10,  highlightH, 5);
        noStroke();
    }
    
    // Draw Site/Factory PNG
    if (textColor == 50) {
      pic = sitePNG_BW;
    } else {
      pic = sitePNG;
    }
    tint(255, 75);
    image(pic, x, y, picW*.75, picH*.75);
    tint(255, 255);

    // Legend for Site Areas
    textAlign(LEFT);
    fill(GSK_ORANGE);
    text("Built Capacity", x+15, y + 4.5*textSize);
    fill(textColor, 225);
    text("Available Site", x+15, y + 6.0*textSize);
    noFill();
    
    // Draw Total Available Site
    stroke(textColor, 150);
    strokeWeight(3);
    fill(background, 50);
    rect(x+1, siteStart - 3, w-2, siteBound + 10);
    rect(x, y + 5.25*textSize, 10, 10);
    
    //Draws Existing Infrastructure on Site
    float existLine = map(capEx, 0, maxCapSites, 0, sitesH/3);
    strokeWeight(3);
    stroke(GSK_ORANGE, 200);
    fill(GSK_ORANGE, 50);
    rect(x+5, siteStart, w-10, existLine + 4);
    rect(x, y + 3.75*textSize, 10, 10);
    
    // Draw Label Text
    fill(textColor);
    textAlign(LEFT);
    textSize(textSize);
    text("Site " + name, x, y - 5);
    textAlign(LEFT);
    fill(GSK_ORANGE);
    text(int(capEx) + agileModel.WEIGHT_UNITS, x,  siteStart - 15);
    fill(textColor);
    text(" / " + int(capGn+capEx) + agileModel.WEIGHT_UNITS, x + 25,  siteStart - 15);
           
    // Draw RND Capacity Slots
    for (int i=0; i<limitRnD; i++) {
      fill(background);
      stroke(textColor, 100);
      strokeWeight(2);
      rect(x + w + RnD_gap, siteStart - 3 + i*(RnD_W), RnD_W, RnD_W-5);
      textAlign(CENTER);
      fill(textColor);
      text("R&D", x + w + RnD_gap + 0.5*RnD_W, siteStart - 3 + i*(RnD_W) + 0.5*RnD_W);
    }
    noStroke();
    fill(textColor);
    
    // Draw Build Allocations within Site Square
    
    float offset = 0;
    float BLD_X = x + 10;
    float BLD_Y = siteStart + 5;
    float BLD_W = (w - 20)/3;
    float BLD_H; 
   
    for (int i=0; i<siteBuild.size(); i++) {
      
      // Height of a build Unit
      BLD_H = map(3*siteBuild.get(i).capacity, 0, maxCapSites, 0, h/3);
      
      //property array for clicking
      float[] props = {BLD_X +  BLD_W*(i%3), BLD_Y + offset,  BLD_W, BLD_H - 2, i, agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).ABSOLUTE_INDEX};
      NCEClicks.add(props);
      
      // Draw Site Builds on Sites
      if(!gameMode){
        
        // Draws Solid NCE colors before game starts
        fill(agileModel.profileColor[siteBuild.get(i).PROFILE_INDEX], 180);
        rect(BLD_X + BLD_W*(i%3), BLD_Y + offset,  BLD_W, BLD_H - 2, 5);
        fill(background, 100);
        rect(BLD_X + BLD_W*(i%3), BLD_Y + offset,  BLD_W, BLD_H - 2, 5);
        
      } else if (gameMode) {
        
        if (session.current.TURN > 0 && siteBuild.get(i).built) {
          
          // Calculate percent of build module being utilized to meet demand
          float demand = agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).demandProfile.getFloat(2, session.current.TURN-1);
          float cap = agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).globalProductionLimit;
          float meetPercent;
          if (cap == 0) {
            meetPercent = 0.0;
          } else {
            meetPercent = min(1.0, demand/cap);
          }
          
          // Assign Value to Build Class for Later Use
          // (Should move this calculation outside of draw eventually)
          siteBuild.get(i).production = meetPercent;
          
          // Translate percent to pixel dimension
          float capWidth = map(meetPercent, 0, 1.0, 0, BLD_W);
          if(capWidth > BLD_W){ // Check that is not greater than 1
            capWidth = BLD_W;
          }
          
          noStroke();
          
          // Draw Background Rectangle to Demonstrate "Built" Status
          fill(abs(background - 10));
          rect(BLD_X + BLD_W*(i%3), BLD_Y + offset,  BLD_W, BLD_H - 2, 5);
          
          // Draw colored rectangle
          fill(agileModel.profileColor[siteBuild.get(i).PROFILE_INDEX], 180);
          rect(BLD_X + BLD_W*(i%3), BLD_Y + offset, capWidth, BLD_H - 2, 5);
          
        } 
        
      }
      
      // Highlight Build if Selected
      if (session.selectedSiteBuild == i && selected) {
        stroke(HIGHLIGHT);
        strokeWeight(3);
      } else {
        stroke(textColor, 200);
        strokeWeight(1);
      }
      
      // Highlight Build if Hovering
      if (hoverElement.equals("BUILD") && session.hoverSiteBuild == i && !(tableTest && mfg.mouseInGrid())) {
        noFill();
        stroke(HIGHLIGHT);
        strokeWeight(2);
      }
      
      // Draw Building Outline
      noFill();
      rect(BLD_X + BLD_W*(i%3), BLD_Y + offset, BLD_W, BLD_H - 2, 5);
      
      // Draw Build Label
      noStroke();
      fill(textColor);
      textAlign(CENTER, CENTER);
      //text(agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).name + " - " + siteBuild.get(i).capacity + "t", x + BLD_W/2  + BLD_W*(i%2) + 10, BLD_Y + offset + textSize/2);
      text(siteBuild.get(i).PROFILE_INDEX+1, x + BLD_W/2  + BLD_W*(i%3) + 10, BLD_Y + offset + textSize/2);
      
      if (i%3 == 2) {
        offset += BLD_H;
      }
    }
  }
}
