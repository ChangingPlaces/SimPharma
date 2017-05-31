/* ButtonDemo is a script that shows the basic framework for implementing, aligning, and hiding buttons in Processing.
 * It was largely written by Nina Lutz for AgentDemo, but was extracted in it's simplest for by Ira Winder
 * MIT Media Lab, March 2016
 */

// Class that holds a button menu
Menu mainMenu, hideMenu;

// Global Text and Background Color
int textColor = 50;
int background = 255;
int BUTTON_OFFSET_H = 40;
int BUTTON_OFFSET_W = 50;

// Menu Alignment on Screen
String align = "LEFT";

// Set this to true to display the main menue upon start
boolean showMainMenu = true;

// Define how many buttons are in the Main Menu and 
// what they are named by editing this String array:
String[] buttonNames = 
{
  "Load Random Data (SH+R)",  // 0
  "Load XLS Data (SH+X)",  // 1
  "Play Game (g)",  // 2
  "VOID",  // 3
  "Toggle Profile (p)",    // 4
  "Toggle Site (s)",  // 5
  "Toggle Existing Build (SH+S)", //6
  "Toggle New Build (b)",  // 7
  "VOID",  // 8
  "Deploy Selection (d)",  // 9
  "Remove Selection (r)",  // 10
  "Repurpose Selection (e)",  // 11
  "VOID",  // 12
  "End Turn (SPACE)",    // 13
  "VOID",  // 14
  "VOID",  // 15
  "VOID",  // 16
  "Invert Colors (i)", // 17
  "Project Table (`)", // 18
  
  
};

// These Strings are for the hideMenu, formatted as arrays for Menu Class Constructor
String[] hide = {"Hide Main Menu (h)"};
String[] show = {"Show Main Menu (h)"};

// The result of each button click is defined here
void mouseClicked() {
  
  int numProfiles;
  if (!gameMode) {
    numProfiles = agileModel.PROFILES.size();
      for(int i =0; i<numProfiles; i++){
        if(mouseX <= agileModel.PROFILES.get(i).xClick + agileModel.PROFILES.get(i).wClick && mouseX >= agileModel.PROFILES.get(i).xClick - agileModel.PROFILES.get(i).wClick 
        && mouseY <= agileModel.PROFILES.get(i).yClick + agileModel.PROFILES.get(i).hClick && mouseY >= agileModel.PROFILES.get(i).yClick - agileModel.PROFILES.get(i).hClick){
          session.setProfile(i);
        }
      }
  } else {
    numProfiles = agileModel.activeProfiles.size();
          for(int i =0; i<numProfiles; i++){
        if(mouseX <= agileModel.activeProfiles.get(i).xClick + agileModel.activeProfiles.get(i).wClick && mouseX >= agileModel.activeProfiles.get(i).xClick - agileModel.activeProfiles.get(i).wClick 
        && mouseY <= agileModel.activeProfiles.get(i).yClick + agileModel.activeProfiles.get(i).hClick && mouseY >= agileModel.activeProfiles.get(i).yClick - agileModel.activeProfiles.get(i).hClick){
          session.setProfile(i);
        }
      }
  }
  
  //Hide/Show Menu
  if(hideMenu.buttons[0].over()){  
    toggleMainMenu();
  }
  
  if(mainMenu.buttons[0].over()){ 
    loadOriginal = false;
    regenerateGame();
  }
  
  if(mainMenu.buttons[1].over()){ 
    loadOriginal = true;
    regenerateGame();
  }
  
  if(mainMenu.buttons[2].over()){ 
    toggleGame();
  }
  
  if(mainMenu.buttons[4].over()){ 
    nextProfile();
  }
  
  if(mainMenu.buttons[5].over()){ 
    nextSite();
  }
  
  if(mainMenu.buttons[6].over()){ 
    nextSiteBuild();
  }
  
  if(mainMenu.buttons[7].over()){ 
    nextBuild();
  }
  
  if(mainMenu.buttons[9].over()){ 
    deploySelection();
  }
  
  if(mainMenu.buttons[10].over()){ 
    removeSelection();
  }
  
  if(mainMenu.buttons[11].over()){ 
    repurposeSelection();
  }
  
  if(mainMenu.buttons[13].over()){ 
    endTurn();
  }
  
  if(mainMenu.buttons[17].over()){ 
    invertColors();
  }
  
  if(mainMenu.buttons[18].over()){ 
    toggleProjection();
  }
  
  loop();
}

void keyPressed() {
  switch(key) {
    case 'h': // "Hide Main Menu (h)"
      toggleMainMenu();
      break;
    case 'i': // "Invert Colors (i)"
      invertColors();
      break;
    case 'R': // "Regenerate Random Game Data (SH+R)"
      loadOriginal = false;
      regenerateGame();
      fauxPieces(0, tablePieceInput, 15);
      break;
    case 'X': // "Regenerate XLS Game Data (SH+X)"
      loadOriginal = true;
      regenerateGame();
      break;
    case 'g': // "Play Game (g)"
      toggleGame();
      break;
    case 'p': // "Toggle Profile (p)"
      nextProfile();
      break;
    case 's': // "Toggle Site (s)"
      nextSite();
      break;
    case 'S': // "Toggle Existing Build (SH+S)",
      nextSiteBuild();
      break;
    case 'b': // "Toggle Build (b)"
      nextBuild();
      break;
    case 'd': // "Deploy Selection (d)"
      if (gameMode) deploySelection();
      break;
    case 'r': // "Remove Selection (r)"
      if (gameMode) removeSelection();
      break;
    case 'e': // "Repurpose Selection (e)"
      if (gameMode) repurposeSelection();
      break;
    case ' ': // "Next Turn (SPACE)"
      if (gameMode) endTurn();
      break;
    case '`': //  "Enable Projection (`)"
      toggleProjection();
      break;
    case 'y':
      println(mouseX, mouseY);
      break;
  }
  loop();
}

void toggleMainMenu() {
  showMainMenu = toggle(showMainMenu);
  if (showMainMenu) {
    hideMenu.buttons[0].label = hide[0];
  } else {
    hideMenu.buttons[0].label = show[0];
  }
  println("showMainMenu = " + showMainMenu);
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
  if (background == 50) {
    background = 255;
    textColor = 50;
    HIGHLIGHT = color(144, 200, 200);
  } else {
    background = 50;
    textColor = 255;
    HIGHLIGHT = color(174, 240, 240);
  }
  println ("background: " + background + ", textColor: " + textColor);
}

// Toggle God Mode vs. Game Mode
void toggleGame() {
  if (gameMode) {
    gameMode = false;
    mainMenu.buttons[2].label = "Play Game (g)";
    mainMenu.buttons[13].isVoid = true;
    mainMenu.buttons[9].isVoid = true;
    mainMenu.buttons[10].isVoid = true;
    mainMenu.buttons[11].isVoid = true;
  } else {
    gameMode = true;
    session = new Game();
    mainMenu.buttons[2].label = "God Mode (g)";
    mainMenu.buttons[13].isVoid = false;
    mainMenu.buttons[9].isVoid = false;
    mainMenu.buttons[10].isVoid = false;
    mainMenu.buttons[11].isVoid = false;
  }
  
  println("gameMode: " + gameMode);
}

void toggleProjection() {
  toggle2DProjection();
  println("displayProjection2D = " + displayProjection2D);
}

void pressButton(boolean bool, int button) {
  if (bool) {
    mainMenu.buttons[button].isPressed = false;
  } else {
    mainMenu.buttons[button].isPressed = true;
  }
}

// iterates an index parameter
int next(int index, int max) {
  if (index == max) {
    index = 0;
  } else {
    index ++;
  }
  return index;
}

// flips a boolean
boolean toggle(boolean bool) {
  if (bool) {
    return false;
  } else {
    return true;
  }
}

class Button{
  // variables describing upper left corner of button, width, and height in pixels
  int x,y,w,h;
  // String of the Button Text
  String label;
  // Various Shades of button states (0-255)
  int active = 180; // lightest
  int hover = 120;
  int pressed = 120; // darkest
  
  boolean isPressed = false;
  boolean isVoid = false;
  
  //Button Constructor
  Button(int x, int y, int w, int h, String label){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }
  
  //Button Objects are draw to a PGraphics object rather than directly to canvas
  void draw(PGraphics p){
    if (!isVoid) {
      p.noStroke();
      if( over() ) {  // Darkens button if hovering mouse over it
        p.fill(100, hover);
      } else if (isPressed){
        p.fill(100, pressed);
      } else {
        p.fill(100, active);
      }
      p.rect(x, y, w, h, 5);
      p.fill(255);
      p.textSize(min(textSize-1, 13));
      p.textAlign(CENTER);
      p.text(label, x + (w/2), y + 0.6*h); 
    }
  } 
  
  // returns true if mouse hovers in button region
  boolean over(){
    if(mouseX >= x  && mouseY >= y + 5 && mouseX <= x + w && mouseY <= y + 2 + h){
      return true;
    } else {
      return false;
    }
  }
}

class Menu{
  // Button Array Associated with this Menu
  Button[] buttons;
  // Graphics Object to Draw this Menu
  PGraphics canvas;
  // Button Name Array Associated with Menu
  String[] names;
  // Menu Alignment
  String align;
  // variables describing canvasWidth, canvas Height, Button Width, Button Height, Verticle Displacement (#buttons down)
  int w, h, x, y, vOffset;
  
  //Constructor
  Menu(int w, int h, int x, int y, int vOffset, String[] names, String align){
    this.names = names;
    this.w = w;
    this.h = h;
    this.vOffset = vOffset;
    this.align = align;
    this.x = x;
    this.y = y;
    
    // distance in pixels from corner of screen
    int marginH = BUTTON_OFFSET_H;
    int marginW = BUTTON_OFFSET_W;
    
    canvas = createGraphics(w, h);
    // #Buttons defined by Name String Array Length
    buttons = new Button[this.names.length];
    
    // Initializes the button objects
    for (int i=0; i<buttons.length; i++) {
      if ( this.align.equals("right") || this.align.equals("RIGHT") ) {
        // Right Align
        buttons[i] = new Button(this.w - this.x - marginW, marginH + this.vOffset*(this.y+5) + i*(this.y+5), this.x, this.y, this.names[i]);
      } else if ( this.align.equals("left") || this.align.equals("LEFT") ) { 
        // Left Align
        buttons[i] = new Button(marginW, marginH + this.vOffset*(this.y+5) + i*(this.y+5), this.x, this.y, names[i]);
      } else if ( this.align.equals("center") || this.align.equals("CENTER") ) { 
        // Center Align
        buttons[i] = new Button( (this.w-this.x)/2, marginH + this.vOffset*(this.y+5) + i*(this.y+5), this.x, this.y, this.names[i]);
      }
      
      // Alows a menu button spacer to be added by setting its string value to "VOID"
      if (this.names[i].equals("void") || this.names[i].equals("VOID") ) {
        buttons[i].isVoid = true;
      }
    }
  }
  
  // Draws the Menu to its own PGraphics canvas
  void draw() {
    canvas.beginDraw();
    canvas.clear();
    for (int i=0; i<buttons.length; i++) {
      buttons[i].draw(canvas);
    }
    canvas.endDraw();
    
    image(canvas, 0, 0);
  }
}
