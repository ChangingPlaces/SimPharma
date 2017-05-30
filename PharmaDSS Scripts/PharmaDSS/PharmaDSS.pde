/*  PharmaDSS, Copyright 2017 Ira Winder et al
 *   Ira Winder, jiw@mit.edu
 *   Nina Lutz, nlutz@mit.edu
 *
 *  Check "About" tab for:
 *    A. MIT Licensing
 *    B. Project Description
 *    C. Development History
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
//  PFont main = createFont("Arial", 20, false);
  PFont main = loadFont("data/ArialUnicodeMS-20.vlw");
  textFont(main);
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
  
  // Calculates Max Capacity Site
  agileModel.maxCapacity();
  
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
  nce = loadImage("data/coumpound2.png");
  
  initOutputs();
  setupRadar();
  
  randomOutputs();
  setupTable();

  initUDP();
}

int textSize = 12;

void draw() {

  textSize = min(12,int(width/100));

  // Decode Lego pieces only if there is a change in Colortizer input
  if (changeDetected) {
    decodePieces();
    changeDetected = false;
  }
  
  // Refers to "drawScreen" tab
  drawScreen();
  
  drawPhaseDiagram();
  
  // Refers to "drawTable" tab (need to draw twice to clear buffer?!)
  noStroke();
  drawTable();
  drawTable();
 
  
  // Draws Menu
  hideMenu.draw();
  if (showMainMenu) {
    mainMenu.draw();
  }
  
//  drawPhaseDiagram();  
  fill(0);
//  rect(width-50, height-50, width/100, width/100);
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
  hideMenu = new Menu(canvasWidth, canvasHeight, max(int(width*.13), 160), 25, 0, hideText, align);
  mainMenu = new Menu(canvasWidth, canvasHeight, max(int(width*.13), 160), 25, 2, buttonNames, align);
  
  // Hides "End Turn" and "next Profile" button unless game is active
  mainMenu.buttons[13].isVoid = !gameMode;
  mainMenu.buttons[9].isVoid = !gameMode;
  mainMenu.buttons[10].isVoid = !gameMode;
  mainMenu.buttons[11].isVoid = !gameMode;
}
