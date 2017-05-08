float testScalerW = 0.85;
float testScalerH = 0.8;
int margin = 50;

// Upper Left Corners
int profilesX = 850;
int profilesY = 200;
int buildsX = 350;
int buildsY = 200;
int sitesX = 0;
int sitesY = 200;
  
//Here are some function to test drawing the visualization
void drawFramework() {
  background(abs(background));
  boolean selected;
  
  // Draw Title
  fill(textColor);
  textAlign(LEFT);
  text("PharmaDSS " + VERSION, margin, margin);
  text("MIT Media Lab + GlaxoSmithKline", margin, margin + 15);
  text("Ira Winder, Giovonni Giorgio, Mason Briner, Joana Gomes", margin, margin + 30);
  
  // Draw Profiles
  if (!gameMode) {
    drawProfiles(agileModel.PROFILES);
  } else {
    drawProfiles(agileModel.activeProfiles);
  }
 
  // Draw Sites
  fill(textColor);
  textAlign(LEFT);
  text("Site Characteristics:", margin + int(testScalerW*(sitesX)), sitesY - 60);
  for (int i=0; i<NUM_SITES; i++) {
    selected = false;
    if (i == session.selectedSite) selected = true;
    agileModel.SITES.get(i).draw(margin + int(testScalerW*(sitesX)), sitesY + int(testScalerH*(320*i)), selected);
  }
  
  // Draw Build/Repurpose Units
  fill(textColor);
  textAlign(LEFT);
  text("Pre-Engineered Production Units:", margin + int(testScalerW*(buildsX - 60)), buildsY - 60);
  
  
  
  // Draw GMS Build Options
  fill(textColor);
  textAlign(LEFT);
  text("GMS:", margin + int(testScalerW*(buildsX - 60)), buildsY - 10);
  text("Build", margin + int(testScalerW*(buildsX)), buildsY - 10);
  text("Repurpose", margin + int(testScalerW*(buildsX + 80)), buildsY - 10);
  for (int i=0; i<NUM_GMS_BUILDS; i++) {
    selected = false;
    if (i == session.selectedBuild) selected = true;
    agileModel.GMS_BUILDS.get(i).draw(margin + int(testScalerW*(buildsX)), buildsY - 10 + int(testScalerH*(15 +33*i)), "GMS", selected);
  }
  
  // Draw R&D Build Options
  fill(textColor);
  textAlign(LEFT);
  float vOffset = buildsY - 10 + int(testScalerH*(15 + 33*(agileModel.GMS_BUILDS.size()+1)));
  text("R&D:", margin + int(testScalerW*(buildsX - 60)), vOffset);
  text("Repurpose", margin + int(testScalerW*(buildsX + 80)), vOffset);
  for (int i=0; i<NUM_RND_BUILDS; i++) {
    selected = false;
    // if (...) selected = true;
    agileModel.RND_BUILDS.get(i).draw(margin + int(testScalerW*(buildsX)),  + int(vOffset + testScalerH*(15 +33*i) ), "R&D", selected);
  }
  
  // Draw Personnel Legend
  fill(textColor);
  textAlign(LEFT);
  text("Legend:", margin + int(testScalerW*(buildsX)) + 280, buildsY - 10);
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
    ellipse(margin + int(testScalerW*(buildsX)) + 280, buildsY + 10 + 15*i, 3, 10);
    fill(textColor);
    text(agileModel.LABOR_TYPES.getString(i,0), margin + int(testScalerW*(buildsX)) + 10 + 280, buildsY + 15 + 15*i);
  }
  
  //Draw Selected Profile in Large Format
  if (!gameMode) {
    drawLargeProfile(agileModel.PROFILES.get(session.selectedProfile));
  } else {
    drawLargeProfile(agileModel.activeProfiles.get(session.selectedProfile));
  }
}

void drawLargeProfile(Profile selected) {
  selected.draw(
    margin, 
    int(height*0.95), 
    int(0.85*width*testScalerW), 
    int(0.5*height*(1.0 - testScalerH)),
    true, false, true
  );
}

void drawProfiles(ArrayList<Profile> list) {
  fill(textColor);
  textAlign(LEFT);
  text("NCE Demand Profiles:", margin + int(testScalerW*(profilesX)), profilesY - 60);
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
        margin + int(testScalerW*(profilesX)), 
        20 + profilesY + int(testScalerH*0.85*i/float(numProf+1)*800), 
        int(testScalerW*300), 
        int(testScalerH*0.3*800/float(numProf+1)),
        axis, selected, false
      );
    }
  }
  
  // Draw Profile Legend
  fill(#0000FF, 200);
  rect(margin + int(testScalerW*(profilesX)), profilesY, 15, 10);
  fill(textColor, 150);
  rect(margin + int(testScalerW*(profilesX)), profilesY + 20, 15, 10);
  fill(textColor);
  textAlign(LEFT);
  text("Legend (" + agileModel.TIME_UNITS + "):", margin + int(testScalerW*(profilesX)), profilesY - 10);
  text("Actual", margin + int(testScalerW*(profilesX))+20, profilesY + 10);
  text("Forecast", margin + int(testScalerW*(profilesX))+20, profilesY + 20 + 10);
  
  noStroke();
  fill(#00CC00);
  rect(margin + int(testScalerW*(profilesX))+100, profilesY, 3, 10);
  fill(#CC0000);
  rect(margin + int(testScalerW*(profilesX))+100, profilesY + 20, 3, 10);
  fill(textColor);
  textAlign(LEFT);
  text("Lead", margin + int(testScalerW*(profilesX))+115, profilesY + 10);
  text("End", margin + int(testScalerW*(profilesX))+115, profilesY + 20 + 10);
  
}
