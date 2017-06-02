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
      if (siteBuild.get(i).demolish) {
        siteBuild.remove(i);
        if (session.selectedSiteBuild >= i && i != 0) session.selectedSiteBuild--; // moves index back to avoid crash
      } else {
        siteBuild.get(i).updateBuild();
      }
    }
  }

  void draw(int x, int y, int w, int h, float max, boolean selected) {
    
      //Display constants for whole card
      int infoGap = 3; // number of MARGIN widths
      float highlightH = (height - 2.8*MARGIN)*.6 -(sitesY-titlesY) - 25; //height of highlighted region
      
      //icon/picture constants
      int RnD_W = 35;
      int RnD_gap = 10;
      int picW = w + RnD_gap + RnD_W;
      int picH = infoGap*MARGIN - RnD_gap;
      PImage pic;  
      
      //Site constants
      float maxCapSites = agileModel.maxCapacity();
      float siteBound = map(capGn+capEx,0, maxCapSites, 0, sitesH/3);
      float siteStart = picH + sitesY;;      
      
      fill(255);
      
      // Draw Site Selection
      if (selected) {
          fill(HIGHLIGHT, 40);
          noStroke(); 
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
      text("Existing Facility", x+15, y + 4.5*textSize);
      fill(textColor, 225);
      text("Greenfield Site", x+15, y + 6.0*textSize);
      noFill();
      
      // Draw Baseline Total External and Green Field Rectangle Capacities
      stroke(textColor, 150);
      strokeWeight(3);
      fill(background, 50);
      rect(x+1, siteStart - 3, w-2, siteBound + 6, 5);
      rect(x, y + 5.25*textSize, 10, 10, 1);
      
      //Draws Existing Line and fill
      float existLine = map(capEx, 0, maxCapSites, 0, sitesH/3);
      strokeWeight(1);
      stroke(GSK_ORANGE, 200);
      fill(GSK_ORANGE, 50);
      rect(x+5, siteStart, w-10, siteBound - existLine, 5);
      rect(x, y + 3.75*textSize, 10, 10, 1);
      
      // Draw Label Text
      fill(textColor);
      textAlign(LEFT);
      textSize(textSize);
      text("Site " + name, x, y - 5);
      textAlign(LEFT);
      fill(GSK_ORANGE);
      text(int(capEx) + agileModel.WEIGHT_UNITS, x,  siteStart - 15);
      fill(textColor);
      text(" / " + int(capEx + capGn) + agileModel.WEIGHT_UNITS, x + 25,  siteStart - 15);
             
      // Draw RND Capacity Slots
      for (int i=0; i<limitRnD; i++) {
        fill(background);
        stroke(textColor, 100);
        strokeWeight(2);
        rect(x + w + RnD_gap, infoGap*MARGIN + y + i*(RnD_W), RnD_W, RnD_W-5, 5);
        textAlign(CENTER);
        fill(textColor);
        text("R&D", x + w + RnD_gap + 0.5*RnD_W, infoGap*MARGIN + y + i*(RnD_W) + 0.5*RnD_W);
      }
      noStroke();
      fill(textColor);
      
      // Draw Build Allocations within Site Square
      float offset = 0;
      float BLD_X = x + 10;
      float BLD_Y = siteStart + 5;
      float BLD_W = w - 20;
      float BLD_H; 
     
      for (int i=0; i<siteBuild.size(); i++) {
        
        BLD_H = (h - infoGap*MARGIN) * siteBuild.get(i).capacity / max;
        
        if ( agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).timeEnd < session.current.TURN || siteBuild.get(i).demolish == true) {
          // Color NCE Not Viable or build flagged for demolition
          fill(#CC0000, 150);
        } else {
          fill(agileModel.profileColor[siteBuild.get(i).PROFILE_INDEX], 180);
        }
        
        if(BLD_H > 30){
          BLD_H  = 30;
        }
        
        float[] props = {BLD_X, BLD_Y + offset,  BLD_W, BLD_H - 2, i, agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).ABSOLUTE_INDEX}; //property array for clicking
        NCEClicks.add(props);
        
        // Draw Site Builds on Sites
        if(!gameMode){
          
          // Draws Solid NCE colors before game starts
          fill(agileModel.profileColor[siteBuild.get(i).PROFILE_INDEX], 180);
          rect(BLD_X, BLD_Y + offset,  BLD_W, BLD_H - 2, 5);
          fill(background, 100);
          rect(BLD_X, BLD_Y + offset,  BLD_W, BLD_H - 2, 5);
          
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
            
            // Translate percent to pixel dimension
            float capWidth = map(meetPercent, 0, 1.0, 0, w - 14);
            if(capWidth > BLD_W){ // Check that is not greater than 1
              capWidth = BLD_W;
            }
            
            noStroke();
            
            // Draw Background Rectangle
            fill(abs(background - 50));
            rect(BLD_X, BLD_Y + offset,  BLD_W, BLD_H - 2, 5);
            
            // Draw colored rectangle
            fill(agileModel.profileColor[siteBuild.get(i).PROFILE_INDEX], 180);
            rect(BLD_X, BLD_Y + offset, capWidth, BLD_H - 2, 5);
            
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
        
        // Draw Build Outline
        noFill();
        rect(BLD_X, BLD_Y + offset, BLD_W, BLD_H - 2, 5);
        
        // Draw Build Label
        offset += BLD_H;
        noStroke();
        fill(textColor);
        textAlign(CENTER, CENTER);
        //text(agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).name + " - " + siteBuild.get(i).capacity + "t", x + 0.5*w, BLD_Y + offset - 10);
        text(agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).name, x + w/2, BLD_Y + offset - 10);
        
      }
    }
    

}


//Nina's site code (very rough n stuff) 
//   int[][] grid = new int[100][100];
//  void draw(int x, int y, int w, int h, float max, boolean selected) {
//    int infoGap = 3; // number of MARGIN widths
//    float sideEx = (h - infoGap*MARGIN)*(capEx)/max;
//    float sideGn = (h - infoGap*MARGIN)*(capEx + capGn)/max;
//    int RnD_W = 35;
//    int RnD_gap = 10;
//    
//    fill(255);     
//    float canH = height - 2.8*MARGIN;
//    float boxLimit =  canH*.6 - 2.2*MARGIN;
//    float newbound = map(sideGn + 10, infoGap*MARGIN + y, height, y - 30, boxLimit- infoGap*MARGIN);
//    
//    // Draw Site Selection
//    if (selected) {
//      fill(HIGHLIGHT, 40);
//
//      noStroke(); 
// 
//      rect(x - 10,  y - 20, w + RnD_W + 2*RnD_gap + 10,  canH*.6 -(sitesY-titlesY) - 25, 5);
//      
//      noStroke();
//    }
//    
//    // Draw Site/Factory PNG
//    int picW = w - RnD_gap;
//    int picH = int(infoGap*MARGIN*.75);
//    //int picW = picH;
//    PImage pic;
//    if (textColor == 50) {
//      pic = sitePNG_BW;
//    } else {
//      pic = sitePNG;
//    }
//    tint(255, 75);
//    image(pic, x, y, picW, picH);
//    tint(255, 255);
//    
//    // Draw Baseline Total External and Green Field Rectangle Capacities
//    stroke(textColor, 100);
//    strokeWeight(2);
//    fill(textColor, 50);
//    float startY = y + picH + infoGap*3;
//    float maxHeight = picH*1.5;
//    float maxCapSites = agileModel.maxCapacity();
//    float siteCap = capGn+capEx;
//    
//    int BoxesPerRow = 15;
//    int BoxesPerCol  = int(map(siteCap, 0, maxCapSites, 0, (picH*2 - 50)/BoxesPerRow));
//    
//    int TonsPerSquare = int(siteCap/(BoxesPerRow*BoxesPerCol));
//    
//    //Below we need to set grid[i][j] as appropriate to 0, 1, 2, 3
//        for (int k=0; k<siteBuild.size(); k++) {
//          grid[3][1] = 3;
//          grid[5][10] = 2;
//           grid[6][10] = 2;
//            grid[5][9] = 2;
//            if ( agileModel.PROFILES.get(siteBuild.get(k).PROFILE_INDEX).timeEnd < session.current.TURN || siteBuild.get(k).demolish == true) {
//              // Color NCE Not Viable or build flagged for demolition
//              fill(#CC0000, 150);
//            } else if (siteBuild.get(k).built == false) {
//              // Color Under Construction
//              fill(abs(100-textColor), 150);
//            } else {
//              // Color NCE Active Production
//              fill(#0000CC, 150);
//            }
//            if (session.selectedSiteBuild == k && selected) {
//              stroke(HIGHLIGHT);
//              strokeWeight(3);
//            } else {
//              stroke(255, 200);
//              strokeWeight(1);
//            }
//        }
//    
//    
//    //Use grid to color the squares
//    for(int i = 0; i < BoxesPerRow; i++){
//      for(int j = 0; j < BoxesPerCol; j++){
//         strokeWeight(1);
//         stroke(textColor);
//         if(grid[i][j] == 0){
//           fill(0, 200, 0, 150); // Color Under Construction
//         }
//         else if (grid[i][j] == 1){
//         fill(255, 0, 0, 150); // Color NCE Not Viable or build flagged for demolition
//         }
//         else if (grid[i][j] == 2){
//           fill(0, 0, 255, 150); // Color NCE Active Production
//         }
//         else{
//          fill(textColor, 150);  //open
//         }
//         rect(i*(picW/BoxesPerRow) + x, j*(picW/BoxesPerRow) + startY, (picW/BoxesPerRow), (picW/BoxesPerRow), 0);
//         
//      }
//    }
//    
//
//
//    // Draw Label Text
//    fill(textColor);
//    textAlign(LEFT);
//    textSize(textSize);
//    text("Site " + name, x, y - 5);
//    fill(textColor);
//    textAlign(CENTER);
//    text("( " + (capGn+capEx) + agileModel.WEIGHT_UNITS + " )", x + picW/2, BoxesPerCol*(picW/BoxesPerRow)+ 20 + startY);
//    
//    // Draw RND Capacity Slots
//    for (int i=0; i<limitRnD; i++) {
//      fill(background);
//      stroke(textColor, 100);
//      strokeWeight(2);
//      rect(x + w + RnD_gap, infoGap*MARGIN + y + i*(RnD_W), RnD_W, RnD_W-10, 5);
//      textAlign(CENTER);
//      fill(textColor);
//      text("R&D", x + w + RnD_gap + 0.5*RnD_W, infoGap*MARGIN + y + i*(RnD_W) + 0.5*RnD_W);
//    }
//    noStroke();
//    fill(textColor);
//    
//    // Draw Build Allocations within Site Square
////    float offset = 0;
////    float size;
////    int indexX, indexY = 0;
////    for (int i=0; i<siteBuild.size(); i++) {
////      color status_color;
////      if ( agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).timeEnd < session.current.TURN || siteBuild.get(i).demolish == true) {
////        // Color NCE Not Viable or build flagged for demolition
////        fill(#CC0000, 150);
////      } else if (siteBuild.get(i).built == false) {
////        // Color Under Construction
////        fill(abs(100-textColor), 150);
////      } else {
////        // Color NCE Active Production
////        fill(#0000CC, 150);
////      }
////      if (session.selectedSiteBuild == i && selected) {
////        stroke(HIGHLIGHT);
////        strokeWeight(3);
////      } else {
////        stroke(255, 200);
////        strokeWeight(1);
////      }
////      size = (h - infoGap*MARGIN) * siteBuild.get(i).capacity / max;
////      
////      if(size > 30){
////        size  = 30;
////      }
////      //rect(x + 7, y + 5 + 1 + offset + infoGap*MARGIN, w - 14, size - 2, 5);
////      void drawNCE(int amount, color NCEfill){
////    int numSqaures = amount*TonsPerSquare;
////    for(int i = 0; i < numSquares; i++){
////      for(int j = 0; j < numSquares-BoxesPerRow; j++){
////         stroke(i*5);
////         strokeWeight(1);
////         fill(NCEfill);
////         rect(i*(picW/BoxesPerRow) + x, j*(picW/BoxesPerRow) + startY, (picW/BoxesPerRow), (picW/BoxesPerRow), 0);
////      }
////    }
////   }
////     // drawNCE(siteBuild.get(i).capacity, status_color);
////      offset += size;
////      noStroke();
////      fill(255);
////      textAlign(CENTER);
////      text(agileModel.PROFILES.get(siteBuild.get(i).PROFILE_INDEX).name + " - " + siteBuild.get(i).capacity + "t", x + 0.5*w, y + offset + 10 - size/2 + infoGap*MARGIN);
////    }
//
//
//   }
