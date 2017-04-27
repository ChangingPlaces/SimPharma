 /* PharmaDSS Beta
 /  Ira Winder, jiw@mit.edu
 /  Cambridge, MA
 /
 /  Beta 1.0 Reslease:
 /
 /  The following scripts demonstrate a basic environment for "PharmaDSS."
 /  The scripts are a parametric implementation of GSK's "Agile Network Meta-model v7"
 /  developed by Mason Briner and Giovonni Giorgio in U.K. 
 /
 /  The primary purpose of this work is overcome various limitations of excel such as: 
 /  graphics, usability, and stochastic variability.
 /
 /  The Beta is designed with the following minimum viable features:
 /  - Object-oriented framework for model components
 /  - Directly read values from Microsoft Excel, linking GSK (Excel-based) and MIT (Java-based) workflows
 /  - Basic Visualization of System Inputs
*/

 /* The following is planned for Beta 1.1:
 /  - Dynamic, Turn-based interaction using mouse and keyboard commands:
 /      1. Allocate/Move/Delete NCE capacity between sites
 /      2. Progress each turn
 /  - Implement stochastic events not easily performed in excel
 /  - Allow user to compare performance with baseline scenario(s)
*/

// Initialize (1)system and (2)objects of model:
System agileModel;

// Specify to "true" if reading System Values from an XLS spreadsheet file in the "data/" folder"
boolean readXLS = true;

// "setup()" runs once upon executing script
void setup() {
  
  // Initiate System and Objects
  agileModel = new System();
  
  // Load Model XLS
  if (readXLS) {
    
    /* Note the following requisites to read an excel file in this program:
     / - filename must end in ".xls"
     / - file must be saved as "Excel 97-2004 Workbook (.xls)"
     / - 2007+ XLSX files will NOT work
     / - Referenced cells are VALUES, not EQUATIONS
    */
    
    loadModel_XLS(agileModel, "Agile Network Model v7_XLS.xls"); // assumes file to be in the data folder, refer to tab "xls.pde"

  }
  
  // Setup for Canvas Visualization
  size(1280, 800);
  
  testDraw();
}

// "draw()" runs as infinite loop after setup() is performed, unless "noLoop()" is instantiated.
void draw() {
  
}

//Here are some function to test drawing the visualization
void testDraw() {
  background(0);
  
  // Draw Profiles
  fill(255);
  textAlign(LEFT);
  text("NCE Demand Profiles:", 50, 50 - 10);
  for (int i=1; i<=NUM_PROFILES; i++) {
    agileModel.PROFILES.get(i-1).draw(50, int(1.5*height/NUM_PROFILES) + int(0.85*i/float(NUM_PROFILES+1)*height), 300, int(0.3*height/float(NUM_PROFILES+1)));
  }
  
  // Draw Profile Legend
  fill(#0000FF, 200);
  rect(50, 100, 10, 10);
  fill(255, 150);
  rect(50, 120, 10, 10);
  fill(255);
  textAlign(LEFT);
  text("Legend:", 50, 90);
  text("Actual", 70, 100 + 10);
  text("Forecast", 70, 120 + 10);
  
  // Draw Sites
  fill(255);
  textAlign(LEFT);
  text("Site Characteristics:", 1000, 50 - 10);
  for (int i=0; i<NUM_SITES; i++) {
    agileModel.SITES.get(i).draw(1000, 100 + 300*i);
  }
  
//  // Draw Site Scale:
//  int scaleValue = 50;
//  fill(255, 100);
//  rect(450, height - 125, 10*sqrt(scaleValue), 10*sqrt(scaleValue));
//  fill(255);
//  textAlign(LEFT);
//  text("Site Capacities:", 450, height - 125 - 10);
//  textAlign(CENTER);
//  text(scaleValue + " " + agileModel.WEIGHT_UNITS, 450 + 10*sqrt(scaleValue)/2, height - 125 + 10*sqrt(scaleValue)/2 + 5);
  
  // Draw Build/Repurpose Units
  int buildW = 500;
  int buildH = 100;
  fill(255);
  textAlign(LEFT);
  text("Pre-Engineered Production Units:", buildW - 60, 50 - 10);
  
  // Draw GMS Build Options
  fill(255);
  textAlign(LEFT);
  text("GMS:", buildW - 60, buildH - 10);
  text("Build", buildW, buildH - 10);
  text("Repurpose", buildW + 80, buildH - 10);
  for (int i=0; i<NUM_GMS_BUILDS; i++) {
    agileModel.GMS_BUILDS.get(i).draw(buildW, 5 + buildH + 33*i, "GMS");
  }
  
  // Draw R&D Build Options
  fill(255);
  textAlign(LEFT);
  text("R&D:", buildW - 60, int(0.57*height) + buildH - 10);
  text("Repurpose", buildW + 80, int(0.57*height) + buildH - 10);
  for (int i=0; i<NUM_RND_BUILDS; i++) {
    agileModel.RND_BUILDS.get(i).draw(buildW, int(0.57*height) + 5 + buildH + 33*i, "R&D");
  }
  
  // Draw Personnel Legend
  fill(255);
  textAlign(LEFT);
  text("Legend:", buildW + 280, buildH - 10);
  for (int i=0; i<NUM_LABOR; i++) {
    if (i==0) {
      fill(#FF0000);
    } else if (i==1) {
      fill(#00FF00);
    } else if (i==2) {
      fill(#0000FF);
    } else if (i==3) {
      fill(#FFFF00);
    } else if (i==4) {
      fill(#FF00FF);
    } else {
      fill(#00FFFF);
    }
    ellipse(buildW + 280, buildH + 10 + 15*i, 3, 10);
    fill(255);
    text(agileModel.LABOR_TYPES.getString(i,0), buildW + 280 + 10, buildH + 15 + 15*i);
  }
}
