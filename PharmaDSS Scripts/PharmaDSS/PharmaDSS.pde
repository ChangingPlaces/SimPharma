 /* PharmaDSS Alpha
 /  Ira Winder, jiw@mit.edu
 /  Cambridge, MA
*/

 String VERSION = "ALPHA V1.3";
 
 /* Release Notes:
 /
 /  ALPHA V1.3 Release
 /  - Select Subset of builds in site...remove or repurpose site builds
 /  - Prepopulate Builds
 /  - Random order for XLS PRofiles
 /  - Add Total Capacity to NCEs
 /  - Make Builds and NCEs similar magnitides
 /  - Add Process Graphic to visualization
 /  - Make Screen Resolution Lower/Resizable
 /  - Draw Launch Tick
 /  - Make Version That is Compatible with Small Screens
 /  - Normalize Large-scale Profile graph
 /  - Make Current Year more Visible during GameMode
 /  - Add R&D "modules", specified by limit, to Site Visualization
 /  - Relative scaling for Large-format Profile visualization
 /  - Implement stochastic events not easily performed in excel
 /
 /  ALPHA V1.2 Release
 /  Dynamic, Turn-based interaction using button and keyboard commands
 /    - Added UI for selecting specific (a)Profiles, (b)Sites, and (c)Builds
 /    - Allocate NCE "Build" capacity between sites
 /    - Enabled "deploy" event that allocates capacity to site in a given turn
 /    Misc Visual:
 /      - Add Large-scale format for selected profile for greater legibility
 /      - Build capacity has 3 states: (1) Under Construction, (2) Active, (3) Inactive/Not utilized 
 /
 /  BETA V1.1 Release
 /  Dynamic, Turn-based interaction using mouse and keyboard commands
 /  Misc Visual:
 /    - Added peak forecast demand tag to Profiles
 /    - Added Color Inversion
 /    - Added turn-based Profile explorer
 /    - Incorporate 5-yr lead times
 /
 /  ALPHA V1.0 Release:
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
*/

 /*
 /  The following is planned for BETA V1.0:
 /
 /  Giovonni's Notes:
 /  - R&D Slot tonnage is not terribly important
 /  - Have 2 modes for batch vs. continuous - continuous effectively makes sites have higher capacity
 /
 /  - Output summary of 5 KPIs
 /     - CAPEX
 /     - OPEX
 /     - Ability to Meet Demand
 /     - Cost of Goods
 /     - Security of Supply
 / 
 /  - Allow user/player to "nudge" baseline parameters before proceeding with game (for instance, change assumption about NCE R&D allowed on Sites)
 /  - Include Salary modifier for different Sites
 /  - Switch between weight/cost metrics for Build Types
 /  - Allow user to compare performance with baseline scenario(s)
 /
 /  - Make click-based interface?
 /  - Add Batch/Continuous Mode
 /  - Place into R&D First
 /  - Only fill up production capacities partially on sites
 /  - Update Capacity into future
 /  - Graphic Icons for (a) NCE (molecule?) and (b) Build (Widget?) and (c) R&D (beaker?)
*/

// Library needed for ComponentAdapter()
import java.awt.event.*;

// Initialize (1)system and (2)objects of model:
System agileModel;
Game session;

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
  
  //Initiate Game
  session = new Game();
  
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
  
  phasing = loadImage("data/phasing.png");
  sitePNG = loadImage("data/site.png");
  sitePNG_BW = loadImage("data/site_BW.png");
  
  setupRadar();
}

// "draw()" runs as infinite loop after setup() is performed, unless "noLoop()" is instantiated.
void draw() {
  
  // Refers to "draw" tab
  drawFramework();
  
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
  String[] hideText;
  if (showMainMenu) {
    hideText = hide;
  } else {
    hideText = show;
  }
  hideMenu = new Menu(canvasWidth, canvasHeight, 150, 25, 0, hideText, align);
  mainMenu = new Menu(canvasWidth, canvasHeight, 150, 25, 2, buttonNames, align);
  
  // Hides "End Turn" and "next Profile" button unless game is active
  mainMenu.buttons[14].isVoid = !gameMode;
  mainMenu.buttons[10].isVoid = !gameMode;
  mainMenu.buttons[11].isVoid = !gameMode;
  mainMenu.buttons[12].isVoid = !gameMode;
}
