/*  PharmaDSS, Copyright 2017 Ira Winder et al
 *   Ira Winder, jiw@mit.edu
 *   Nina Lutz, nlutz@mit.edu
 *
 *  Check "About" tab for:
 *    A. MIT Licensing
 *    B. Project Description
 *    C. Development History
 *
 *  Tablature Name Guide:
 *    "PharmaDSS" - Main tab with highest-level setup() and draw() functions
 *    "About" - Tab only containing comments related to project documentation
 *    "ALLCAPS" - specifies scripts related to foundational implementation of non-native APIs, libraries, calculations, etc
 *    "c_Class" - specifies scripts related to a specific class and/or classes
 *    "d_Canvas" - specifies scripts related to drawing elements to a processing canvas
 */

// Set the Demo Name to "SYCAMORE", "MIT", etc to enable site-specific customization (i.e. screen resolution, projector size)
String DEMO = "SYCAMORE";
//String DEMO = "MIT";

boolean showRealSiteNames = true;
boolean workshop = true;

void setupDemo(String demo) {
  
  // Sycamore Settings (June 4, 2017)
  if (demo.equals("SYCAMORE")) {
    screenWidth = 1280;
    screenHeight = 800;
    projectorWidth = 1920;
    projectorHeight = 1200;
    projectorOffset = 1280;
  }
  
  // MIT IVL Settings (June 13, 2017)
  else if (demo.equals("MIT")) {
    screenWidth = 1280;
    screenHeight = 800;    
    projectorWidth = 1920;
    projectorHeight = 1200;
    projectorOffset = 1280;
  }
}

// Library needed for ComponentAdapter()
import java.awt.event.*;

// Initialize (1)system and (2)objects of model:
MFG_System agileModel;
Game session;

// Specify to "true" if reading MFG_System Values from an XLS spreadsheet file in the "data/" folder"
// (Do not set to false unless you provide for default initialization values for system)
boolean readXLS = true;

// dimensions of main canvas, in pixes
int screenWidth, screenHeight;

//String dataLocation = "xls/Agile Network Model v7_XLS.xls";
//String dataLocation = "xls/giovanni-edit1/Agile Network Model v7_XLS.xls";
//String dataLocation = "xls/giovanni-edit2/Agile Network Model v7_XLS.xls";
//String dataLocation = "xls/giovanni-edit3/Agile Network Model v7_XLS.xls";
String dataLocation = "xls/ira-edit4/Agile Network Model v7_XLS.xls";

// Information for Debugging
boolean debug = false;

// "setup()" runs once upon executing script
void setup() {
  
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
    loadModel_XLS(agileModel, dataLocation);

  }
  
  // Calculates Max Capacity Site
  agileModel.maxCapacity();
  
  //Initiate Game
  session = new Game();
  updateProfileCapacities();
    
  // Setup for Canvas Visualization
  setupDemo(DEMO);
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
  
  // Loads Images and Grpahics
  phasing = loadImage("data/phasing.png");
  sitePNG = loadImage("data/site.png");
  sitePNG_BW = loadImage("data/site_BW.png");
  nce = loadImage("data/compound_invert.png");
  nceMini = loadImage("data/compound.png");
  chip = loadImage("data/chip.png");
  logo_GSK = loadImage("data/GSK-logo-2014.png");
  logo_MIT = loadImage("data/MIT_logo_BW.png");
  
  // Setup Screen Font
  PFont main = loadFont("data/ArialUnicodeMS-20.vlw");
  textFont(main);
  
  initScores();
  setupRadar();
  performance.maxOutputs();
  prediction.maxOutputs();
  
  setupTable();
  
  // For good measure
  regenerateGame();

  initUDP();
  
  if (System.getProperty("os.name").substring(0,3).equals("Mac")) {
    testOnMac = true;
  }
}

int textSize = 12;

String game_message = " ";

void draw() {
  
  if (debug) background(0);
  
  textSize = min(12,int(width/100));
 
  // Decode Lego pieces only if there is a change in Colortizer input
  if (changeDetected) {
    println("Input Detected");
    decodePieces();
    changeDetected = false;
  }
  
  // Update prediction based upon extrapolating from current configuration
  updatePrediction(session.current.TURN);
  
  // Refers to "drawScreen" tab
  drawScreen();
  noStroke();
  
  // Draws Menu
  hideMenu.draw();
  if (showMainMenu) {
    mainMenu.draw();
  }
  
  if(!gameMode){
    game_message = " ";
  }
  gameText();
  
  if (debug) {
    fill(255); 
    text("Framerate: " + frameRate, 50, 25);
  } else {
    noLoop();
  }
}

void gameText(){
  textAlign(LEFT);
  fill(END);
  textSize(textSize+ 2);
  if (!game_message.equals(" ")) text("Error: " + game_message, 250, 100);
}
