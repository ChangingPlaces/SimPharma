PImage phasing;

int MARGIN = 50;

// Upper Left Corners
int profilesX, profilesY, buildsX, buildsY, sitesX, sitesY;

// Width and Height
int profilesW, profilesH, buildsW, buildsH, sitesW, sitesH;
  
//Here are some functions to test drawing the visualization
void drawFramework() {
  // 1800, 1100
  
  textSize(10);
  
  // Upper Left Corners
  profilesX = int(0.33*width);
  profilesY = int(0.22*height);
  buildsX = int(0.66*width);
  buildsY = int(0.5*height);
  sitesX = 0;
  sitesY = int(0.22*height);
  
  // Width and Height
  profilesW = int(0.25*width);
  profilesH = int(0.2*height);
  buildsW =   0;
  buildsH =   int(0.05*height);
  sitesW =    int(0.08*width);
  sitesH =    height - 2*MARGIN - sitesY;
  
  background(abs(background));
  boolean selected;
  
  // Draw Title
  
      fill(textColor);
      textAlign(LEFT);
      text("PharmaDSS " + VERSION, profilesX + MARGIN, MARGIN);
      text("MIT Media Lab + GlaxoSmithKline", profilesX + MARGIN, MARGIN + 15);
      text("Ira Winder, Giovonni Giorgio, Mason Briner, Joana Gomes", profilesX + MARGIN, MARGIN + 30);
  
  // Draw Phasing Diagram
  
      image(phasing, MARGIN, MARGIN - 10, 0.25*width, 0.06*height);
  
  // Draw Profiles

      if (!gameMode) {
        drawProfiles(agileModel.PROFILES);
      } else {
        drawProfiles(agileModel.activeProfiles);
      }
 
  // Draw Sites
  
      float maxSite, current;
      maxSite = 0;
      for (int i=0; i<NUM_SITES; i++) { // Calculate maximum site capacity value
        current = agileModel.SITES.get(i).capEx + agileModel.SITES.get(i).capGn;
        if ( current > maxSite ) maxSite = current;
      }
      fill(textColor);
      textAlign(LEFT);
      text("Site Characteristics:", MARGIN + sitesX, sitesY - 60);
      for (int i=0; i<NUM_SITES; i++) {
        selected = false;
        if (i == session.selectedSite) selected = true;
        agileModel.SITES.get(i).draw(MARGIN + sitesX + i*(2*MARGIN+sitesW), sitesY, sitesW, sitesH, maxSite, selected);
      }
  
  // Draw Build/Repurpose Units
      
      // Build Var
      fill(textColor);
      textAlign(LEFT);
      text("Pre-Engineered Production Units:", MARGIN + buildsX - 60, buildsY - 60);
      
      // Draw GMS Build Options
      fill(textColor);
      textAlign(LEFT);
      text("GMS:", MARGIN + buildsX - 60, buildsY - 10);
      text("Build", MARGIN + buildsX, buildsY - 10);
      text("Repurpose", MARGIN + buildsX + 80, buildsY - 10);
      for (int i=0; i<agileModel.GMS_BUILDS.size(); i++) {
        selected = false;
        if (i == session.selectedBuild) selected = true;
        agileModel.GMS_BUILDS.get(i).draw(MARGIN + buildsX, buildsY + 10 + 15 +buildsH*i, "GMS", selected);
      }
      
      // Draw R&D Build Options
      fill(textColor);
      textAlign(LEFT);
      float vOffset = buildsY - 10 + 15 + buildsH*(agileModel.GMS_BUILDS.size()+1);
      text("R&D:", MARGIN + buildsX - 60, vOffset);
      text("Repurpose", MARGIN + buildsX + 80, vOffset);
      for (int i=0; i<agileModel.RND_BUILDS.size(); i++) {
        selected = false;
        // if (...) selected = true;
        agileModel.RND_BUILDS.get(i).draw(MARGIN + buildsX,  + int(vOffset + 15 + buildsH*i ), "R&D", selected);
      }
      
      // Draw Personnel Legend
      int vOff = -50;
      fill(textColor);
      textAlign(LEFT);
      text("Personnel:", MARGIN + buildsX - 60, MARGIN);
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
        ellipse(MARGIN + buildsX - 60, MARGIN + 15*i +20, 3, 10);
        fill(textColor);
        text(agileModel.LABOR_TYPES.getString(i,0), MARGIN + buildsX - 60 + 10, MARGIN + 15*i +25);
      }
  
  //Draw Selected Profile in Large Format
  if (!gameMode) {
    drawLargeProfile(agileModel.PROFILES.get(session.selectedProfile));
  } else {
    drawLargeProfile(agileModel.activeProfiles.get(session.selectedProfile));
  }
}

void drawLargeProfile(Profile selected) {
  textAlign(LEFT);
  text("Selected Profile: " + selected.name, MARGIN + profilesX, height - MARGIN );
  selected.draw(
    MARGIN + profilesX,
    int(height - 2*MARGIN), 
    300, 
    int(0.10*height),
    true, false, true
  );
}

void drawProfiles(ArrayList<Profile> list) {
  fill(textColor);
  textAlign(LEFT);
  text("NCE Demand Profiles:", MARGIN + profilesX, profilesY - 60);
  boolean axis;
  boolean selected;
  //int numProf = list.size();
  int numProf = 10;
  for (int i=1; i<=list.size(); i++) {
    selected = false;
    axis = false;
    if (!gameMode || list.get(i-1).timeLead <= session.current.TURN ) {
      if (i == numProf) axis = true;
      if (i == session.selectedProfile+1) selected = true;
      list.get(i-1).draw(
        MARGIN + profilesX, 
        20 + profilesY + int(0.5*i/float(numProf+1)*800), 
        300, 
        int(0.25*800/float(numProf+1)),
        axis, selected, false
      );
    }
  }
  
  // Draw Profile Legend
  fill(#0000FF, 200);
  rect(MARGIN + profilesX, profilesY, 15, 10);
  fill(textColor, 150);
  rect(MARGIN + profilesX, profilesY + 20, 15, 10);
  fill(textColor);
  textAlign(LEFT);
  text("Legend (" + agileModel.TIME_UNITS + "):", MARGIN + profilesX, profilesY - 10);
  text("Actual", MARGIN + profilesX+20, profilesY + 10);
  text("Forecast", MARGIN + profilesX+20, profilesY + 20 + 10);
  
  noStroke();
  fill(#00CC00);
  rect(MARGIN + profilesX+100, profilesY, 3, 10);
  fill(#CC0000);
  rect(MARGIN + profilesX+100, profilesY + 20, 3, 10);
  fill(textColor);
  textAlign(LEFT);
  text("Ph.III Lead", MARGIN + profilesX+115, profilesY + 10);
  text("End", MARGIN + profilesX+115, profilesY + 20 + 10);
  
  fill(textColor);
  rect(MARGIN + profilesX+200, profilesY, 10, 3);
  text("Capacity", MARGIN + profilesX+215, profilesY + 10);
  
}
