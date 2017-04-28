 /* PharmaDSS Beta
 /  Ira Winder, jiw@mit.edu
 /  Cambridge, MA
*/
 
 String VERSION = "BETA v1.01";
 
 /*  Beta 1.0 Release:
 /
 /  The following scripts demonstrate a basic environment for "PharmaDSS" (Decision Support System)
 /  The scripts are a parametric implementation of GSK's "Agile Network Meta-model v7"
 /  developed by Mason Briner and Giovonni Giorgio in U.K. 
 /
 /  The primary purpose of this work is overcome various limitations of excel such as: 
 /  graphics, arithmatic operations, usability, and stochastic variability.
 / 
 /  Classes that define primary object abstractions in the system are: 
 /  (a) Profile: NCE demand profile
 /  (b) Site: Factory Location/Area
 /  (c) Build: Manufacturing Unit/Process
 /  (d) Person: "Human Beans", as the BFG would say (i.e. Labor)
 / 
 /  The Beta is designed with the following minimum viable features:
 /  - Object-oriented framework for model components
 /    - Profiles, Sites, Builds, and Persons
 /  - Directly read values from Microsoft Excel, linking GSK (Excel-based) and MIT (Java-based) workflows
 /  - Basic Visualization of System Inputs
 /
 /  Beta 1.1 Release
 /  - Misc Visual:
 /    - Add peak forecast demand tag to Profiles
 /
*/

 /* The following is planned for Beta 1.1:
 /  - Dynamic, Turn-based interaction using mouse and keyboard commands:
 /      1. Allocate/Move/Delete NCE capacity between sites
 /      2. Progress each turn
 /  - Implement stochastic events not easily performed in excel
 /  - Allow user to compare performance with baseline scenario(s)
 /  - Allow user/player to "nudge" baseline parameters before proceeding with game (for instance, change assumption about NCE R&D allowed on Sites)
 /  - Include Salary modifier for different Sites
 /  - Misc Visual:
 /    - Switch between weight/cost metrics for Build Types
 /    - Add R&D "modules", specified by limit, to Site Visualization
*/

// Library needed for ComponentAdapter()
import java.awt.event.*;

// Initialize (1)system and (2)objects of model:
System agileModel;

// Specify to "true" if reading System Values from an XLS spreadsheet file in the "data/" folder"
// (Do not set to false unless you provide for default initialization values for system)
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
    
    // assumes file to be in the data folder, refer to tab "xls.pde"
    loadModel_XLS(agileModel, "Agile Network Model v7_XLS.xls"); 

  }
  
  // Setup for Canvas Visualization
  size(1280, 800);
  
  // Window may be resized after initialized
  frame.setResizable(true);
  
  // Recalculates relative positions of canvas items if screen is resized
  frame.addComponentListener(new ComponentAdapter() { 
     public void componentResized(ComponentEvent e) { 
       if(e.getSource()==frame) { 
         loadMenu(width, height);
       } 
     } 
   }
   );
  
  // Loads and formats menue items
  loadMenu(width, height);
}

// "draw()" runs as infinite loop after setup() is performed, unless "noLoop()" is instantiated.
void draw() {
  
  testDraw();
  
  // Draws Menu
  hideMenu.draw();
  if (showMainMenu) {
    mainMenu.draw();
  }
  
  noLoop();
}

// Refreshes when there's a mouse mouse movement
void mouseMoved() {
  loop();
}

void loadMenu(int canvasWidth, int canvasHeight) {
  // Initializes Menu Items (canvas width, canvas height, button width[pix], button height[pix], 
  // number of buttons to offset downward, String[] names of buttons)
  hideMenu = new Menu(canvasWidth, canvasHeight, 170, 25, 0, hide, align);
  mainMenu = new Menu(canvasWidth, canvasHeight, 170, 25, 2, buttonNames, align);
}

//Here are some function to test drawing the visualization
void testDraw() {
  background(abs(background - 20));
  
  float testScalerW = 0.85;
  float testScalerH = 0.85;
  int margin = 50;
  
  // Upper Left Corners
  int profilesX = 850;
  int profilesY = 200;
  int buildsX = 350;
  int buildsY = 200;
  int sitesX = 0;
  int sitesY = 200;
  
  
  // Draw Title
  fill(textColor);
  text("PharmaDSS " + VERSION, margin, margin);
  text("MIT Media Lab + GlaxoSmithKline", margin, margin + 15);
  text("Ira Winder, Giovonni Giorgio, Mason Briner, Joana Gomes", margin, margin + 30);
  
  // Draw Profiles
  fill(textColor);
  textAlign(LEFT);
  text("NCE Demand Profiles:", margin + int(testScalerW*(profilesX)), profilesY - 60);
  for (int i=1; i<=NUM_PROFILES; i++) {
    agileModel.PROFILES.get(i-1).draw(margin + int(testScalerW*(profilesX)), 20 + profilesY + int(testScalerH*0.85*i/float(NUM_PROFILES+1)*800), int(testScalerW*300), int(testScalerH*0.3*800/float(NUM_PROFILES+1)));
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
  
  // Draw Sites
  fill(textColor);
  textAlign(LEFT);
  text("Site Characteristics:", margin + int(testScalerW*(sitesX)), sitesY - 60);
  for (int i=0; i<NUM_SITES; i++) {
    agileModel.SITES.get(i).draw(margin + int(testScalerW*(sitesX)), sitesY + int(testScalerH*(300*i)));
  }
  
//  // Draw Site Scale:
//  int scaleValue = 50;
//  fill(textColor, 100);
//  rect(450, height - 125, 10*sqrt(scaleValue), 10*sqrt(scaleValue));
//  fill(textColor);
//  textAlign(LEFT);
//  text("Site Capacities:", 450, height - 125 - 10);
//  textAlign(CENTER);
//  text(scaleValue + " " + agileModel.WEIGHT_UNITS, 450 + 10*sqrt(scaleValue)/2, height - 125 + 10*sqrt(scaleValue)/2 + 5);
  
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
    agileModel.GMS_BUILDS.get(i).draw(margin + int(testScalerW*(buildsX)), buildsY - 10 + int(testScalerH*(15 +33*i)), "GMS");
  }
  
  // Draw R&D Build Options
  fill(textColor);
  textAlign(LEFT);
  float vOffset = buildsY - 10 + int(testScalerH*(15 + 33*(agileModel.GMS_BUILDS.size()+1)));
  text("R&D:", margin + int(testScalerW*(buildsX - 60)), vOffset);
  text("Repurpose", margin + int(testScalerW*(buildsX + 80)), vOffset);
  for (int i=0; i<NUM_RND_BUILDS; i++) {
    agileModel.RND_BUILDS.get(i).draw(margin + int(testScalerW*(buildsX)),  + int(vOffset + testScalerH*(15 +33*i) ), "R&D");
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
}
