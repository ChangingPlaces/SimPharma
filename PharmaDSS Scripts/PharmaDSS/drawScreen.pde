/*  GSK Orange:
 *  RGB 255 108 47 
 *  HEX/HTML FF6C2F 
 *  CMYK 0 45 86 0
 */

PImage phasing, sitePNG, sitePNG_BW, logo, nce;

int MARGIN = 50;

color HIGHLIGHT = color(174, 240, 240);
color THEME = color(255, 108,47);
color GSK_ORANGE = color(255, 108,47);

// Upper Left Corners
int profilesX, profilesY, buildsX, buildsY, sitesX, sitesY, radarX, radarY, titlesY;

// Width and Height
int profilesW, profilesH, buildsW, buildsH, sitesW, sitesH, radarH;

LineGraph outputGraph;
  
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
  radarY    = int(0.8*height + 30);
  
  //Builds
  buildsX = sitesX + radarH*3;
  buildsY = sitesY + sitesH/2;
  buildsW   = int(0.13*width);
  buildsH   = profilesH;
  
  //Titles
  titlesY   = int(2.80*MARGIN);

  background(abs(background - 15));
  boolean selected;
  
  // Draw Background Canvases
      
      float canH = height - 2.8*MARGIN;
      
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
      
      //Line Graph and Outputs
      float lineY = 2.2*MARGIN + 70 + canH*.6;
      float lineX = MARGIN*1.5 + sitesX + (width - sitesX - 1.25*MARGIN)/3 + 20;
      outputGraph = new LineGraph(outputs, lineX, lineY, 2*(width - sitesX - 1.25*MARGIN)/3 - 100, canH*.25);
      
  // Draw Title
      fill(textColor);
      textAlign(RIGHT);
      textSize(textSize);
      text("PharmaDSS" + VERSION, width - MARGIN, MARGIN);
      text("MIT Media Lab + GlaxoSmithKline", width - MARGIN, MARGIN + textSize + 3);
      text("Ira Winder, Nina Lutz, Giovonni Giorgio, Mason Briner, Joana Gomes", width - MARGIN, MARGIN + textSize + textSize + 6);
  
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
      text("Site Characteristics:", MARGIN + sitesX, titlesY);
      text("Outputs:", MARGIN + sitesX , canH*.6 + titlesY + MARGIN/2.5);
      
      textSize(min(16, textSize));
      for (int i=0; i<NUM_SITES; i++) {
        selected = false;
        if (i == session.selectedSite) selected = true;
        agileModel.SITES.get(i).draw(MARGIN + sitesX + i*((width-sitesX-MARGIN)/NUM_SITES), sitesY, sitesW, sitesH, agileModel.maxCap, selected);
      }
  
//  // Draw Build/Repurpose Units
//      
//      // Build Var
//      fill(textColor);
//      textAlign(LEFT);
//      text("Pre-Engineered Production Units:", buildsX, titlesY);
//      float spread = 3.0;
//      
//      // Draw GMS Build Options
//      fill(textColor);
//      textAlign(LEFT);
//      text("GMS", buildsX, buildsY + 1.4*MARGIN);
////      text("Build", MARGIN + buildsX, buildsY - 10);
////      text("Repurpose", MARGIN + buildsX + 80, buildsY - 10);
//      for (int i=0; i<agileModel.GMS_BUILDS.size(); i++) {
//        selected = false;
//        if (i == session.selectedBuild) selected = true;
//        agileModel.GMS_BUILDS.get(i).draw(buildsX, 2*MARGIN + buildsY + int(spread*buildsH*i), buildsW, buildsH, "GMS", selected);
//      }
//      
//      // Draw R&D Build Options
//      fill(textColor);
//      textAlign(LEFT);
//      float vOffset = buildsY + spread*buildsH*(agileModel.GMS_BUILDS.size()+1);
//      text("R&D", buildsX, vOffset + 1.4*MARGIN);
//      for (int i=0; i<agileModel.RND_BUILDS.size(); i++) {
//        selected = false;
//        // if (...) selected = true;
//        agileModel.RND_BUILDS.get(i).draw(buildsX, 2*MARGIN + int(vOffset + spread*buildsH*i ), buildsW, buildsH, "R&D", selected);
//      }
//      
//      // Draw Personnel Legend
//      int vOff = -50;
//      fill(textColor);
//      textAlign(LEFT);
////      text("Personnel:", titlesY, MARGIN);
//      for (int i=0; i<NUM_LABOR; i++) {
//        if (i==0) {
//          fill(#CC0000);
//        } else if (i==1) {
//          fill(#00CC00);
//        } else if (i==2) {
//          fill(#0000CC);
//        } else if (i==3) {
//          fill(#CCCC00);
//        } else if (i==4) {
//          fill(#CC00CC);
//        } else {
//          fill(#00CCCC);
//        }
//        
//        int xOff = 0;
//        if (i > 2) {
//          xOff = 100;
//        }
//        
//        ellipse(buildsX + xOff, 15*(i%3) - 4 + profilesY, 3, 10);
//        fill(textColor);
//        text(agileModel.LABOR_TYPES.getString(i,0), buildsX + 10 + xOff, 15*(i%3) + profilesY);
//      }
  
  //Draw Selected Profile in Large Format
  if (!gameMode) {
    drawLargeProfile(agileModel.PROFILES.get(session.selectedProfile));
  } else {
    drawLargeProfile(agileModel.activeProfiles.get(session.selectedProfile));
  }
  
  // Draw Radar Plot
  if (displayRadar) {
    kpi.draw(radarX, radarY, radarH);
    outputGraph.draw();
  }

  image(logo, MARGIN, height-MARGIN - 70); 
  
}

void drawLargeProfile(Profile selected) {
  textAlign(LEFT);
  text("Selected Profile: " + selected.name, MARGIN + profilesX, height - MARGIN );
//  selected.initGraph( MARGIN + profilesX, int(height - 1.75*MARGIN), profilesW, int(0.10*height),true, false, true);
//  selected.graph.drawProfileGraph();
  selected.draw(MARGIN + profilesX, int(height - 1.75*MARGIN), profilesW, int(0.10*height),true, false, true);
}

void drawProfiles(ArrayList<Profile> list) {
  fill(textColor);
  textAlign(LEFT);
  textSize(max(18, textSize));
  text("NCE Demand Profiles:", MARGIN + profilesX, titlesY);
  
  // Current Year
  fill(textColor, 80);
//  rect(profilesX + profilesW + 0.5*MARGIN+3, titlesY - 15+3, 40, 20, 5);
  fill(THEME);
//  rect(profilesX + profilesW + 0.5*MARGIN, titlesY - 15, 40, 20, 5);
  textAlign(RIGHT);
  fill(textColor);
  text(agileModel.YEAR_0 + session.current.TURN, profilesX + profilesW + 1.15*MARGIN, titlesY);
  
  boolean axis;
  boolean selected;
  int numProf = list.size();
//  int numProf = 10;
  for (int i=1; i<=list.size(); i++) {
    selected = false;
    axis = false;
    if (!gameMode || list.get(i-1).timeLead <= session.current.TURN ) {
      if (i == numProf) axis = true;
      if (i == session.selectedProfile+1) selected = true;
//      list.get(i-1).initGraph(MARGIN + profilesX, 
//        2*MARGIN + profilesY + int(0.45*height*(i-1)/float(numProf+1)), 
//        profilesW, profilesH,
//        axis, selected, false);
//      list.get(i-1).graph.drawProfileGraph();
        list.get(i-1).draw(MARGIN + profilesX, MARGIN + profilesY + int(0.57*height*(i-1)/float(numProf+1)), 
        profilesW, profilesH,
        axis, selected, false);
    }
  }
  

  
  // Draw Profile Legend
 
  noStroke();
  fill(THEME, 200);
  rect(MARGIN + profilesX, titlesY + textSize*1.5, 15, 10);
  fill(textColor, 150);
  rect(MARGIN + profilesX, titlesY + textSize*2.7, 15, 10);
  fill(P3);
  rect(MARGIN + profilesX+100 +textSize*2, titlesY + textSize*1.5 , 3, textSize-2);
  fill(Launch);
  rect(MARGIN + profilesX+210 +textSize*4, titlesY + textSize*1.5, 3, textSize-2);
  
  fill(textColor);
  textAlign(LEFT);
  text("Actual", MARGIN + profilesX+20, titlesY + textSize*1.5 + 10);
  text("Forecast", MARGIN + profilesX+20, titlesY + textSize*2.7 + 10);
  rect(MARGIN + profilesX+210  +textSize*3, titlesY + textSize*2.7 + 5, 15, 1.5);
  text("Capacity", MARGIN + profilesX+220  +textSize*4, titlesY + textSize*2.7 + 10);
  text("Launch", MARGIN + profilesX+220  +textSize*4, titlesY + textSize*1.5 + 10);
  text("Lead (Ph.III)", MARGIN + profilesX+110  +textSize*2, titlesY + textSize*1.5 + 10);
  
  
  
  if(!gameMode){
    text("End", MARGIN + profilesX+110  +textSize*2, titlesY + textSize*2.7 + 12);
    fill(END);
    rect(MARGIN + profilesX+100 +textSize*2, titlesY + textSize*2.7 , 3, textSize-2);
  }

  else{
    fill(END);
    rect(MARGIN + profilesX+80 +textSize*2, titlesY + textSize*2.7 , 3, textSize-2);
    fill(FISCAL);
    rect(MARGIN + profilesX+140 +textSize*3, titlesY + textSize*2.7 , 3, textSize-2);
    fill(textColor);
    text("End", MARGIN + profilesX+90  +textSize*2, titlesY + textSize*2.7 + 12);
    text("Now", MARGIN + profilesX+150  +textSize*3, titlesY + textSize*2.7 + 12);
  }
  
}
