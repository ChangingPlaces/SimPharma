// Main Tab for enabling user interface elements such as buttons, key presses, and mouse clicks

// Class that holds a button menu
Menu mainMenu, hideMenu;

// Global Text and Background Color
int textColor = 255;
int background = 50;
int BUTTON_OFFSET_H = 45;
int BUTTON_OFFSET_W = 50;
boolean invert = false;

// Menu Alignment on Screen
String align = "LEFT";

// Set this to true to display the main menue upon start
boolean showMainMenu = true;

// Define/Arrange how many buttons are in the Main Menu and 
// what they are named by editing this String array:
// [0] Name; [1] Abbreviated name
String[][] buttonNames = 
{ 
  { "Load Random Data", "q" },
  { "Load XLS Data", "x" },
  { "VOID", "" },
  { "Toggle Profile", "p" },
  { "Play Game", "g" },
  { "End Turn", "SPACE" },
  { "VOID", "" },
  { "VOID", "" },
  { "VOID", "" },
  { "VOID", "" },
  { "Table Projection", "`" },
  { "Table Test", "t" },
  { "Invert Colors", "i" },
  { "Debug", "0" },
  { "VOID", "" },
  { "VOID", "" },
  { "VOID", "" },
  { "VOID", "" },
  { "VOID", "" }

// Obsolete Keys
//  { "Toggle Site", "s" },
//  { "Toggle Site Build", "b" },
//  { "Deploy Selection", "d" },
//  { "Remove Selection", "r" },
//  { "Repurpose Selection", "e" },
//  { "Toggle KPI's", "k" },
//  { "Enlarge Profile", "l" },
  
};

// Hash Map of Button Names where Key is key-command and Value is buttonNames[] index
HashMap<String, Integer> bHash;

// This Strings is for the hideMenu, formatted as array for Menu Class Constructor
String[][] show = { {"Show Main Menu", "h"} };

void loadMenu(int canvasWidth, int canvasHeight) {
  // Initializes Menu Items (canvas width, canvas height, button width[pix], button height[pix], 
  // number of buttons to offset downward, String[] names of buttons)
  String[][] hideText = show;
  hideMenu = new Menu(canvasWidth, canvasHeight, max(int(width*.13), 160), 25, 0, hideText, align);
  mainMenu = new Menu(canvasWidth, canvasHeight, max(int(width*.13), 160), 25, 2, buttonNames, align);
  
  // Hash Map of Button Names where Key is key-command and Value is buttonNames[] index
  bHash = hashButtons(buttonNames);
  
  hideMenu.buttons[0].isPressed = showMainMenu;
  
  // Hides certain buttons unless game is active
  mainMenu.buttons[ bHash.get("g") ].isPressed = gameMode;
  mainMenu.buttons[ bHash.get("SPACE") ].isVoid = !gameMode;
//  mainMenu.buttons[ bHash.get("d") ].isVoid = !gameMode;
//  mainMenu.buttons[ bHash.get("r") ].isVoid = !gameMode;
//  mainMenu.buttons[ bHash.get("e") ].isVoid = !gameMode;
  
  mainMenu.buttons[ bHash.get("t") ].active = !tableTest;
}

void keyPressed() {
  switch(key) {
    case 'h': 
      key_h();
      break;
    case 'q': 
      key_q();
      break;
    case 'x': 
      key_x();
      break;
    case 'g': 
      key_g();
      break;
    case 'p': 
      key_p();
      break;
//    case 's': 
//      key_s();
//      break;
    case 'u': 
      key_u();
      break;
//    case 'b': 
//      key_b();
//      break;
//    case 'd': 
//      key_d();
//      break;
//    case 'r': 
//      key_r();
//      break;
//    case 'e': 
//      key_e();
//      break;
//    case 'k': 
//      key_k();
//      break;
    case 'i': 
      key_i();
      break;
    case '`': 
      key_tilde();
      break;
    case 't': 
      key_t();
      break;
//    case 'l':
//      key_l();
//      break;
    case ' ': 
      key_space();
      break;
    case '0': 
      key_0();
      break;
      
    // Debugging (no formal buttons)
    case 'X':
      // Randomize pieces just for debugging....
      fauxPieces(3, tablePieceInput, 15);
      // testPlace(tablePieceInput, u, v, ID)
      //testPlace(tablePieceInput, 2, 8, 0);
      changeDetected = true;
      break;
      
  }
  
  if (key == CODED) {
    if (keyCode == UP) {
      key_up();
    }
    
    if (keyCode == DOWN) {
      key_down();
    }
    
    if (keyCode == LEFT) {
      key_left();
    }
    
    if (keyCode == RIGHT) {
      key_right();
    }
  }
  
  changeDetected = true;
  loop();
}

// The result of each button click is defined here
void mousePressed() {
  
  if (mfg.mouseInGrid()) {
    // Add piece to table virtually (Must run BEFORE Main Menu Button Implementation)
    int ID;
    if (gameMode) {
      ID = agileModel.activeProfiles.get(session.selectedProfile).ABSOLUTE_INDEX;
      //println(ID);
    } else {
      ID = session.selectedProfile;
    }
    mfg.addMousePiece(ID);
    changeDetected = true;
  } else {
    // Allow Onscreen Slection of Profiles, Sites, etc
    checkSelections("click");
  }
  
  // Hide/Show Menu
  if(hideMenu.buttons[0].over()){  
    key_h();
  }
  
  // Main Menu Buttons:
  if(mainMenu.buttons[ bHash.get("q") ].over()){ 
    key_q();
  }
  
  if(mainMenu.buttons[ bHash.get("x") ].over()){ 
    key_x();
  }
  
  if(mainMenu.buttons[ bHash.get("g") ].over()){ 
    key_g();
  }
  
  if(mainMenu.buttons[ bHash.get("p") ].over()){ 
    key_p();
  }
  
//  if(mainMenu.buttons[ bHash.get("s") ].over()){ 
//    key_s();
//  }
//  
//  if(mainMenu.buttons[ bHash.get("u") ].over()){ 
//    key_u();
//  }
//  
//  if(mainMenu.buttons[ bHash.get("b") ].over()){ 
//    key_b();
//  }
//  
//  if(mainMenu.buttons[ bHash.get("d") ].over()){ 
//    key_d();
//  }
//  
//  if(mainMenu.buttons[ bHash.get("r") ].over()){ 
//    key_r();
//  }
//  
//  if(mainMenu.buttons[ bHash.get("e") ].over()){ 
//    key_e();
//  }
//  
//  if(mainMenu.buttons[ bHash.get("k") ].over()){ 
//    key_k();
//  }
  
  if(mainMenu.buttons[ bHash.get("i") ].over()){ 
    key_i();
  }
  
  if(mainMenu.buttons[ bHash.get("`") ].over()){ 
    key_tilde();
  }
  
  if(mainMenu.buttons[ bHash.get("t") ].over()){ 
    key_t();
  }
  
//  if(mainMenu.buttons[ bHash.get("l") ].over()){ 
//    key_l();
//  }
  
  if(mainMenu.buttons[ bHash.get("SPACE") ].over()){ 
    key_space();
  }
  
  if(mainMenu.buttons[ bHash.get("0") ].over()){ 
    key_0();
  }
  
  loop();
}

// Refreshes when there's a mouse mouse movement
void mouseMoved() {
  hoverElement = checkSelections("hover");
  loop();
}

// Updates when mouse released
void mouseReleased() {
  loop();
}

void key_h() {
  // "Hide Main Menu"
  showMainMenu = !showMainMenu;
  hideMenu.buttons[0].isPressed = showMainMenu;
}

void key_q() {
  // Random Game Configuration
  loadOriginal = false;
  regenerateGame();
}

void key_x() {
  //  Reset to Originl Configuration
  loadOriginal = true;
  regenerateGame();
}

void key_g() {
  // Toggle God Mode vs. Game Mode
  if (gameMode) {
    gameMode = false;
    mainMenu.buttons[ bHash.get("g") ].isPressed = false;
    mainMenu.buttons[ bHash.get("SPACE") ].isVoid = true;
//    mainMenu.buttons[ bHash.get("d") ].isVoid = true;
//    mainMenu.buttons[ bHash.get("r") ].isVoid = true;
//    mainMenu.buttons[ bHash.get("e") ].isVoid = true;
  } else {
    gameMode = true;
    session = new Game();
    regenerateGame();
    updateProfileCapacities();
    mainMenu.buttons[ bHash.get("g") ].isPressed = true;
    mainMenu.buttons[ bHash.get("SPACE") ].isVoid = false;
//    mainMenu.buttons[ bHash.get("d") ].isVoid = false;
//    mainMenu.buttons[ bHash.get("r") ].isVoid = false;
//    mainMenu.buttons[ bHash.get("e") ].isVoid = false;
  }
  
  println("gameMode: " + gameMode);
}

void key_p() {
  nextProfile();
}

void key_s() {
  nextSite();
}

void key_b() {
  nextSiteBuild();
}

void key_u() {
  nextBuild();
}

void key_d() {
  deploySelection();
}

void key_r() {
  removeSelection();
}

void key_e() {
  repurposeSelection();
}

void key_space() {
  if (gameMode) endTurn();
}

void key_k() {
  displayRadar = !displayRadar;
  mainMenu.buttons[ bHash.get("k") ].isPressed = displayRadar;
}

void key_i() {
  invertColors();
  mainMenu.buttons[ bHash.get("i") ].isPressed = invert;
}

void key_tilde() {
  // Toggle Table Projection
  toggle2DProjection();
}

void key_t() {
  tableTest = !tableTest;
  mainMenu.buttons[ bHash.get("t") ].isPressed = tableTest;
}

void key_0() {
  debug = !debug;
  mainMenu.buttons[ bHash.get("0") ].isPressed = debug;
}

void key_l() {
  // Toggle InfoOverlay
  infoOverride = !infoOverride;
}

void key_up() {
  //  Add Function
}

void key_down() {
  //  Add Function
}

void key_left() {
  //  Add Function
}

void key_right() {
  //  Add Function
}

void alignLeft() {
  align = "LEFT";
  loadMenu(width, height);
  println(align);
}

void alignRight() {
  align = "RIGHT";
  loadMenu(width, height);
  println(align);
}

void alignCenter() {
  align = "CENTER";
  loadMenu(width, height);
  println(align);
}

void invertColors() {
  invert = !invert;
  if (invert) {
    background = 255;
    textColor = 50;
  } else {
    background = 50;
    textColor = 255;
  }
  println ("background: " + background + ", textColor: " + textColor);
}

// Method for parsing mouse-based object selection
String hoverElement = "";
String checkSelections(String effect) {
  
  String hoverCheck = "";
  
  // Mouse-based Profile Selection
  int numProfiles;
  ArrayList<Profile> pList;
  Profile p;
  if (!gameMode) {
    numProfiles = agileModel.PROFILES.size();
    pList = agileModel.PROFILES;
  } else {
    numProfiles = agileModel.activeProfiles.size();
    pList = agileModel.activeProfiles;
  }
  for(int i = 0; i<numProfiles; i++){
    p = pList.get(i);
    if(mouseX <= p.xClick + p.wClick && mouseX >= p.xClick 
    && mouseY <= p.yClick + p.hClick && mouseY >= p.yClick){
      if (effect.equals("click")) {
        session.selectedProfile = i;
      } else if (effect.equals("hover")) {
        session.hoverProfile = i;
        session.selectedProfile = i;
        hoverCheck = "PROFILE";
      }
    }
  }
  
  // Mouse-based Site Selection
  for(int i = 0; i< NUM_SITES; i++){
    float clickX = MARGIN  + sitesX + i*((width-sitesX-MARGIN)/NUM_SITES);
    float clickW = ((width-sitesX-MARGIN)/NUM_SITES) - MARGIN*2;
    if(mouseX <= clickX + clickW && mouseX >= clickX  && mouseY <= sitesY + sitesH && mouseY >= sitesY){
      if (effect.equals("click")) {
        session.selectedSite = int(agileModel.SITES.get(i).name) - 1;
      } else if (effect.equals("hover")) {
        session.hoverSite = int(agileModel.SITES.get(i).name) - 1;
        hoverCheck = "SITE";
      }
    }
  }
  
  // Mouse-based Build Module Selection (within Sites)
  for(int j = 0; j<NCEClicks.size(); j++){
    float NCEClickX = NCEClicks.get(j)[0];
    float NCEClickY = NCEClicks.get(j)[1];
    float NCEClickWidth = NCEClicks.get(j)[2];
    float NCEClickHeight = NCEClicks.get(j)[3];  
    if(mouseX <= NCEClickX + NCEClickWidth && mouseX >= NCEClickX  && mouseY <= NCEClickY + NCEClickHeight && mouseY >= NCEClickY){
      if (effect.equals("click")) {
        session.selectedSiteBuild = int(NCEClicks.get(j)[4]);
      } else if (effect.equals("hover")) {
        session.hoverSiteBuild = int(NCEClicks.get(j)[4]);
        hoverCheck = "BUILD";
      }
      
      // Set Profile to be same as site build
      int prof;
      if (gameMode) {
        prof = activeProfileIndex(int(NCEClicks.get(j)[5]));
      } else {
        prof = int(NCEClicks.get(j)[5]);
      }
      if (effect.equals("click")) {
        session.selectedProfile = prof;
      } else if (effect.equals("hover")) {
        session.hoverProfile = prof;
      }
    }
  }
  
  return hoverCheck;
}
