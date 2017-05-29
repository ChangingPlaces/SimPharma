/*  PharmaDSS, Copyright 2017
 *  Ira Winder, jiw@mit.edu
 *  Cambridge, MA
 *
 *  
 *  Check "About" tab for:
 *  A. MIT Licensing
 *  B. Project Description
 *  C. Development History
 */
 
int screenWidth = 1280;
int screenHeight = 800;
 
int projectorWidth = 1920;
int projectorHeight = 1200;
int projectorOffset = 1280;

// Library needed for ComponentAdapter()
import java.awt.event.*;

// Initialize (1)system and (2)objects of model:
MFG_System agileModel;
Game session;

// Specify to "true" if reading MFG_System Values from an XLS spreadsheet file in the "data/" folder"
// (Do not set to false unless you provide for default initialization values for system)
boolean readXLS = true;

// "setup()" runs once upon executing script
void setup() {
//  PFont main = createFont("Arial", 19, false);
//  textFont(main);
  // Initiate MFG_System and Objects
  agileModel = new MFG_System();
  
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
  size(screenWidth, screenHeight, P2D);
  
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
  logo = loadImage("data/GSK-logo-2014.png");
  setupRadar();
  setupTable();

  initUDP();
}

// "draw()" runs as infinite loop after setup() is performed, unless "noLoop()" is instantiated.
void draw() {
  
  // Decode Lego pieces only if there is a change in Colortizer input
  if (changeDetected) {
    decodePieces();
    changeDetected = false;
  }
  
  // Refers to "drawScreen" tab
  drawScreen();
  
  // Refers to "drawTable" tab (need to draw twice to clear buffer?!)
  drawTable();
  drawTable();
  
  // Draws Menu
  hideMenu.draw();
  if (showMainMenu) {
    mainMenu.draw();
  }
  
  drawPhase((profilesW + 1.75*MARGIN)/6, (profilesW + 1.75*MARGIN)/12, (profilesW + 1.75*MARGIN)/20, color(200, 10, 20), "RANDOM");
  
  shape(s, 0.25*MARGIN + profilesX, MARGIN - 10);
  shape(s, 0.25*MARGIN + profilesX + (profilesW + 1.75*MARGIN)/5, MARGIN - 10);
  shape(s, 0.25*MARGIN + profilesX + 2*(profilesW + 1.75*MARGIN)/5, MARGIN - 10);
  shape(s,0.25*MARGIN + profilesX + 3*(profilesW + 1.75*MARGIN)/5, MARGIN - 10);
  shape(s,0.25*MARGIN + profilesX + 4*(profilesW + 1.75*MARGIN)/5, MARGIN - 10);    
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
  mainMenu.buttons[12].isVoid = !gameMode;
  mainMenu.buttons[8].isVoid = !gameMode;
  mainMenu.buttons[9].isVoid = !gameMode;
  mainMenu.buttons[10].isVoid = !gameMode;
}
