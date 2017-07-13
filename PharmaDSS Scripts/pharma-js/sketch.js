var screenWidth = 1280;
var screenHeight = 800;
var textSizeValue = 12;
var MARGIN = 50;
var profilesX, profilesY, buildsX, buildsY, sitesX, sitesY, radarX, radarY, titlesY, lineX, lineY, infoX, infoY;
var profilesW, profilesH, buildsW, buildsH, sitesW, sitesH, radarH, lineW, lineH, infoW, infoH;
var HIGHLIGHT, THEME, GSK_ORANGE, CAPACITY_COLOR, NOW, END;
var textColor = 255;
var backgroundValue = 50;
var BUTTON_OFFSET_H = 40;
var BUTTON_OFFSET_W = 50;
var dataLocation = "xls/giovanni-edit2/Agile Network Model v7_XLS.xls";

var displayBuilds = true;
var displayRadar = true;
var infoOverlay = false;
var infoOverride = false;


function preload() {

}

function setup() {
  var HIGHLIGHT = color(174, 230, 230);
  var THEME = color(255, 108,47);
  var GSK_ORANGE = color(255, 108,47);
  var CAPACITY_COLOR = color(200, 95, 224); 
  var NOW = color(255, 220, 4);
  var END = color(249, 60, 60);

  // Initiate MFG_System and Objects
  agileModel = new MFG_System();
  
  // Load Model XLS
  // if (readXLS) {
  //   loadModel_XLS(agileModel, dataLocation);
  // }
  agileModel.maxCapacity();
  
  //Initiate Game
  // session = new Game();
  // updateProfileCapacities();
    
  // Setup for Canvas Visualization
  // setupDemo(DEMO);
  createCanvas(screenWidth, screenHeight, P2D);
  
  // Window may be resized after initialized
  // frame.setResizable(true);
  
  // Recalculates relative positions of canvas items if screen is resized
  // frame.addComponentListener(new ComponentAdapter() { 
  //    public void componentResized(ComponentEvent e) { 
  //      if(e.getSource()==frame) { 
  //        loadMenu(width, height);
  //      } 
  //    } 
  //  }
  //  );
  
  // Loads and formats menue items
  // loadMenu(width, height);






  phasing = loadImage("data/phasing.png");
  sitePNG = loadImage("data/site.png");
  sitePNG_BW = loadImage("data/site_BW.png");
  nce = loadImage("data/coumpound2.png");
  nceMini = loadImage("data/compound.png");
  chip = loadImage("data/chip.png");
  
  logo_GSK = loadImage("data/GSK-logo-2014.png");
  logo_MIT = loadImage("data/MIT_logo_BW.png");

  var main = loadFont("data/Arial.ttf");
  textFont(main);

  createCanvas(screenWidth, screenHeight);
  noStroke();

  textSize(textSizeValue);







  initOutputs();
  // setupRadar();
  
  // flatOutputs();
  // setupTable();

  initUDP();
}

function draw() {
  textSizeValue = min(12,int(width/100));
 
  // Decode Lego pieces only if there is a change in Colortizer input
  if (changeDetected) {
    println("Lego Movement Detected");
    decodePieces();
    changeDetected = false;
  }
  
  drawScreen();
  // drawPhaseDiagram();
  
  // Draws Overlay Graphic to describe NCE attributes
  if (infoOverlay || infoOverride) {
      drawInfoOverlay();
  }
  
  // Refers to "drawTable" tab (need to draw twice to clear buffer?!)
  noStroke();
  // drawTable();
  // drawTable();
  
  // Draws Menu
  // hideMenu.draw();
  // if (showMainMenu) {
  //   mainMenu.draw();
  // }
  
  // if(!gameMode){
  //   game_message = " ";
  // }

 gameText();
  
 noLoop();
}


// Refreshes when there's a mouse mouse movement
function mouseMoved() {
  loop();
}

function loadMenu(canvasWidth, canvasHeight) {
  // // Initializes Menu Items (canvas width, canvas height, button width[pix], button height[pix], 
  // // number of buttons to offset downward, String[] names of buttons)
  // var hideText;
  // if (showMainMenu) {
  //   hideText = hide;
  // } else {
  //   hideText = show;
  // }
  // hideMenu = new Menu(canvasWidth, canvasHeight, max(int(width*.13), 160), 25, 0, hideText, align);
  // mainMenu = new Menu(canvasWidth, canvasHeight, max(int(width*.13), 160), 25, 2, buttonNames, align);
  
  // // Hides "End Turn" and "next Profile" button unless game is active
  // mainMenu.buttons[13].isVoid = !gameMode;
  // mainMenu.buttons[9].isVoid = !gameMode;
  // mainMenu.buttons[10].isVoid = !gameMode;
  // mainMenu.buttons[11].isVoid = !gameMode;
}

function gameText(){
  textAlign(LEFT);
  fill(END);
  textSize(textSizeValue+ 2);
  text(game_message, 50, height-260, profilesX-MARGIN*1.5, height/8);
}