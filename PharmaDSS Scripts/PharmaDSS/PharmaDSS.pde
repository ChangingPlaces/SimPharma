 /* PharmaDSS Beta
 /  Ira Winder, jiw@mit.edu
 /  Cambridge, MA
*/
 
 String VERSION = "BETA V1.1";
 
 /* Release Notes:
 /  
 /  BETA V1.1 Release
 /  Dynamic, Turn-based interaction using mouse and keyboard commands
 /  Misc Visual:
 /    - Added peak forecast demand tag to Profiles
 /    - Added Color Inversion
 /    - Added turn-based Profile explorer
 /    - Incorporate 5-yr lead times
 /
 /  BETA V1.0 Release:
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
*/

 /* Development Notes:
 /
 /  The following is planned for BETA V1.2:
 /  - Implement stochastic events not easily performed in excel
 /  - Allow user/player to "nudge" baseline parameters before proceeding with game (for instance, change assumption about NCE R&D allowed on Sites)
 /  - Include Salary modifier for different Sites
 /  - Misc Visual:
 /    - Switch between weight/cost metrics for Build Types
 /    - Add R&D "modules", specified by limit, to Site Visualization
 /  - Allocate/Move/Delete NCE capacity between sites
 /  - Allow user to compare performance with baseline scenario(s)
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
  
  //Initiate Game
  session = new Game();
  
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
  hideMenu = new Menu(canvasWidth, canvasHeight, 170, 25, 0, hideText, align);
  mainMenu = new Menu(canvasWidth, canvasHeight, 170, 25, 2, buttonNames, align);
  
  // Hides "Next Turn" button unless game is active
  mainMenu.buttons[1].isVoid = !gameMode;
}