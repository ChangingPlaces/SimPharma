/*  GSK Orange:
 *  RGB 255 108 47 
 *  HEX/HTML FF6C2F 
 *  CMYK 0 45 86 0
 */

PImage phasing, sitePNG, sitePNG_BW, nce, nceMini, chip;

// Logos
PImage logo_GSK, logo_MIT;

int MARGIN = 50;

color HIGHLIGHT = color(174, 230, 230);
color THEME = color(255, 108,47);
color GSK_ORANGE = color(255, 108,47);
color CAPACITY_COLOR = color(200, 95, 224); 
color NOW = color(255, 220, 4);

// Upper Left Corners
int profilesX, profilesY, buildsX, buildsY, sitesX, sitesY, radarX, radarY, titlesY, lineX, lineY, infoX, infoY;

// Width and Height
int profilesW, profilesH, buildsW, buildsH, sitesW, sitesH, radarH, lineW, lineH, infoW, infoH;

LineGraph outputGraph;

boolean displayBuilds = true;
boolean infoOverlay = false;
boolean infoOverride = false;
  
//methods for drawing model onto a screen
void drawScreen() {
  
  textSize(textSize);
  
  //Profile
  profilesX = int(0.18*width);
  profilesY = int(0.21*height);
  profilesW = int(0.23*width);
  profilesH = int(0.02*height);
  
  //Sites
  sitesX    = int(profilesX + profilesW + 100);
  sitesY    = int(0.21*height);
  sitesW    = int(0.08*width);
  sitesH    = int(height) - 2*MARGIN - sitesY;
  
  //Radar
  radarH    = int(0.05*width);
  radarX    = int(sitesX + radarH + 70);
  radarY    = int(0.8*height + 15);
  
  //Builds
  buildsX   = sitesX + radarH*3;
  buildsY   = sitesY + sitesH/2;
  buildsW   = int(0.13*width);
  buildsH   = profilesH;
  
  infoX     = int(0.05*(width) / 2 + 4*MARGIN);
  infoY     = int((height - int(0.85*height) ) / 2);
  infoW     = int(0.95*(width -4*MARGIN));
  infoH     = int(0.85*height);
  
  float canH = height - 2.8*MARGIN;
  
  // Output Graph
  if (displayRadar || displayBuilds) {
    lineX     = int(MARGIN*1.5 + sitesX + (width - sitesX - 1.25*MARGIN)/3 + 20);
    lineY     = int(2.2*MARGIN + 65 + canH*.6);
    lineW     = int(2*(width - sitesX - 1.25*MARGIN)/3 - 100);
    lineH     = int(canH*.25);
  } else {
    lineX     = int(MARGIN*1.5 + sitesX);
    lineY     = int(2.2*MARGIN + 65 + canH*.6);
    lineW     = int(width - sitesX - 3.25*MARGIN);
    lineH     = int(canH*.25);
  }
      
  //Titles
  titlesY   = int(2.80*MARGIN);

  background(abs(background - 15));
  boolean selected;
  
  // Draw Background Canvases
      
      noStroke();
      
      // Shadows
      fill(abs(background - 50));
      rect(0.25*MARGIN + profilesX+5, 2.2*MARGIN+5, profilesW + 1.75*MARGIN, canH, 4);
      rect(0.5*MARGIN + sitesX+5, 2.2*MARGIN+5, width - sitesX - 1.25*MARGIN, canH*.6, 4);
      rect(0.5*MARGIN + sitesX+5, 2.2*MARGIN + 25 + canH*.6 , width - sitesX - 1.25*MARGIN, canH*.4 - 20 , 4);
      
      // Canvas
      fill(abs(background - 0));
      rect(0.25*MARGIN + profilesX, 2.2*MARGIN, profilesW + 1.75*MARGIN, canH, 3);
      rect(0.5*MARGIN + sitesX, 2.2*MARGIN, width - sitesX - 1.25*MARGIN, canH*.6, 3);
      rect(0.5*MARGIN + sitesX, 2.2*MARGIN + 20 + canH*.6 , width - sitesX - 1.25*MARGIN, canH*.4 - 20 , 3);
      
  // Draw Title
      fill(textColor);
      textAlign(RIGHT);
      textSize(textSize);
      text("PharmaDSS " + VERSION, width - MARGIN, MARGIN);
      text("Ira Winder, Nina Lutz, Kent Larson (MIT), Joana Gomes (IIM, GSK)\nGiovanni Giorgio, Mason Briner (Capital Strategy and Design, GSK)\nAndrew Rutter (AMT), John Dyson (CSD, GSK)", width - MARGIN, MARGIN + textSize + 3);
      
      //text("Ira Winder, Nina Lutz, Giovanni Giorgio, Mason Briner, Joana Gomes", width - MARGIN, MARGIN + textSize + textSize + 6);
  
  // Draw Profiles
      if (!gameMode) {
        drawProfiles(agileModel.PROFILES);
      } else {
        drawProfiles(agileModel.activeProfiles);
      }
 
  // Draw Sites
      fill(textColor);
      textAlign(LEFT);
      textSize(max(18, textSize));
      text("Site Characteristics", MARGIN + sitesX - 10, titlesY);
      if (NUM_OUTPUTS < 5) text("Performance", MARGIN + lineX  - 70, canH*.6 + titlesY + MARGIN/2.5 - 5);
      if (!displayRadar) {
        text("MfG Capacity 'Chip'", MARGIN + sitesX  - 10, canH*.6 + titlesY + MARGIN/2.5 - 5);
      } else {
        text("Performance", MARGIN + sitesX  - 10, canH*.6 + titlesY + MARGIN/2.5 - 5);
      }
      
      textSize(min(16, textSize));
      NCEClicks.clear();
      for (int i=0; i<NUM_SITES; i++) {
        selected = false;
        if (i == session.selectedSite) selected = true;
        agileModel.SITES.get(i).draw(MARGIN  + sitesX + i*((width-sitesX-MARGIN)/NUM_SITES), sitesY, ((width-sitesX-MARGIN)/NUM_SITES) - MARGIN*2, sitesH, agileModel.maxCap, selected);
      }
   
  // Line Graph and Outputs
      outputGraph = new LineGraph(outputs, lineX, lineY, lineW, lineH);
  
  // Draw Build Legend
      drawBuilds();
  
  //Draw Selected Profile in Large Format
  try {
  if (!gameMode) {
    drawLargeProfile(agileModel.PROFILES.get(session.selectedProfile));
  } else {
    drawLargeProfile(agileModel.activeProfiles.get(session.selectedProfile));
  }
  } catch (Exception e) {
    println("Could not execute drawLargeProfile() in drawScreen()");
  }
  
  // Draw Radar Plot
  if (displayRadar) {
    kpi.draw(radarX, radarY, radarH);
  }
  outputGraph.draw();

  // Draw Pork Chop
  image(logo_GSK, 1.0*MARGIN, height-MARGIN - 70); 
  image(logo_MIT, 2.9*MARGIN, height-MARGIN - 10, 1.4*MARGIN, 0.6*MARGIN); 
  
}

int nceW = 15;

void drawLargeProfile(Profile selected) {
  selected.draw(MARGIN + profilesX - nceW, int(height - 1.75*MARGIN), profilesW, int(0.10*height),true, false, true);
}

void drawInfoProfile(Profile selected) {
  selected.draw(infoX + 80, height - 160, infoW - 160, infoH - 300,true, false, true);
}

void drawProfiles(ArrayList<Profile> list) {
  fill(textColor);
  textAlign(LEFT);
  textSize(max(18, textSize));
  text("NCE Demand Profiles", MARGIN + profilesX - 25, titlesY);
  
  // Current Year
  textAlign(RIGHT);
  fill(textColor, 200);
  text(agileModel.YEAR_0 + session.current.TURN, profilesX + profilesW + 1.15*MARGIN, titlesY);
  
  boolean axis;
  boolean selected;
  int numProf = agileModel.PROFILES.size();
  for (int i=1; i<=list.size(); i++) {
    selected = false;
    axis = false;
    if (!gameMode || list.get(i-1).timeLead <= session.current.TURN ) {
      if (i == numProf) axis = true;
      if (i == session.selectedProfile+1) selected = true;
         if(!gameMode){
            list.get(i-1).draw(MARGIN + profilesX - nceW, MARGIN + profilesY + int(0.57*height*(i-1)/float(numProf+1)), 
            profilesW, profilesH,
            axis, selected, false);
         }
         else{
             list.get(i-1).draw(MARGIN + profilesX - nceW, MARGIN + profilesY + int(0.57*height*(i-1)/float(numProf+1)), 
             profilesW, profilesH,
             axis, selected, false);
         }
    }

  }
  
  // Draw Profile Legend
  noStroke();
  
  // Draw Rainbow Icon
  colorMode(HSB);
  float ht = 10;
  float fraction = ht / agileModel.profileColor.length;
  for (int i=0; i<agileModel.profileColor.length; i++) {
    fill(agileModel.profileColor[i], 200);
    rect(MARGIN + profilesX, titlesY + textSize*1.5 + i*fraction, 15, fraction);
  }
  colorMode(RGB); 
  // Always set back to RGB!!!
  
  fill(textColor, 150);
  rect(MARGIN + profilesX, titlesY + textSize*2.7 + 2, 15, 10);
  fill(P3);
  rect(MARGIN + profilesX+80 +textSize*2, titlesY + textSize*1.5 , 3, textSize-2);
  fill(Launch);
  rect(MARGIN + profilesX+210 +textSize*4, titlesY + textSize*1.5, 3, textSize-2);
  fill(END);
  rect(MARGIN + profilesX+80 +textSize*2, titlesY + textSize*2.7 + 2, 3, textSize-2);
  fill(textColor);
  fill(CAPACITY_COLOR);
  rect(MARGIN + profilesX+210  +textSize*3, titlesY + textSize*2.7 + 5, 15, 3);
  
  fill(textColor);
  textAlign(LEFT);
  text("Actual", MARGIN + profilesX+20, titlesY + textSize*1.5 + 10);
  text("Forecast", MARGIN + profilesX+20, titlesY + textSize*2.7 + 12);
  text("Capacity", MARGIN + profilesX+220  +textSize*4, titlesY + textSize*2.7 + 12);
  text("Launch", MARGIN + profilesX+220  +textSize*4, titlesY + textSize*1.5 + 10);
  text("Lead (Ph.III)", MARGIN + profilesX+90  +textSize*2, titlesY + textSize*1.5 + 10);
  text("End", MARGIN + profilesX+90  +textSize*2, titlesY + textSize*2.7 + 12);

  if(gameMode) {
    fill(NOW);
    rect(MARGIN + profilesX+140 +textSize*3, titlesY + textSize*2.7 + 2, 3, textSize-2);
    fill(textColor);
    text("Now", MARGIN + profilesX+150  +textSize*3, titlesY + textSize*2.7 + 12);
  }

}

void drawBuilds() {
  
  // Draw Build/Repurpose Units
  boolean selected;
  
  // Build Var
  float spread = 3.0;
  
  // Draw GMS Build Options
  for (int i=0; i<agileModel.GMS_BUILDS.size(); i++) {
    selected = false;
    if (i == session.selectedBuild) selected = true;
    if (!displayRadar) agileModel.GMS_BUILDS.get(i).draw(sitesX + MARGIN - 5, lineY + lineH - 20, buildsW, buildsH, "GMS", selected);
  }
  
//  // Draw R&D Build Options
//  for (int i=0; i<agileModel.RND_BUILDS.size(); i++) {
//    selected = false;
//    // if (...) selected = true;
//    agileModel.RND_BUILDS.get(i).draw(sitesX + MARGIN - 5, lineY + lineH - 20, buildsW, buildsH, "GMS", selected);
//  }
  
  // Draw Personnel Legend
  int vOff = -50;
  fill(textColor);
  textAlign(LEFT);
  //      text("Personnel:", titlesY, MARGIN);
  for (int i=0; i<NUM_LABOR; i++) {
    if (i==0) {
      fill(#CC0000);
    } else if (i==1) {
      fill(#00CC00);
    } else if (i==2) {
      fill(#0000CC);
    } else if (i==3) {
      fill(#CCCC00);
    } else if (i==4) {
      fill(#CC00CC);
    } else {
      fill(#00CCCC);
    }
    
    int xOff = 0;
    if (i > 2) {
      xOff = 100;
    }
    
    ellipse(sitesX + xOff + 1.0*MARGIN - 5, 15*(i%3) - 4 + MARGIN, 3, 10);
    fill(textColor);
    text(agileModel.LABOR_TYPES.getString(i,0), sitesX + 10 + xOff + 1.0*MARGIN - 5, 15*(i%3) + MARGIN);
  }
}

void drawInfoOverlay() {
  stroke(background);
  strokeWeight(1);
  fill(textColor, 100);
  
  rect(infoX, infoY, infoW, infoH, 10);
  fill(background);
  rect(infoX + 20, infoY + 20, infoW - 40, infoH - 40, 10);
  
  try {
    
    //Draw Selected Profile in Large Format
    if (!gameMode) {
      drawInfoProfile(agileModel.PROFILES.get(session.selectedProfile));
    } else {
      drawInfoProfile(agileModel.activeProfiles.get(session.selectedProfile));
    }
    
  } catch(Exception e) {
    println("Could not execute drawInfoOverlay() in drawScreen()");
  }
  
  fill(textColor);
  for (int i=0; i<NUM_SITES; i++) {
    try {
      text("Site " + i + ", Cost of Goods: " + agileModel.activeProfiles.get(session.selectedProfile).productionCost.get(i), 
        infoX + 180 + MARGIN, infoY + 80 + 30*i);
    } catch(RuntimeException e) {
      
    }
  }
}
