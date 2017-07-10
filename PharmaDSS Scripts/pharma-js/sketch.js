var screenWidth = 1280;
var screenHeight = 800;
var textSize = 12;
var MARGIN = 50;
var profilesX, profilesY, buildsX, buildsY, sitesX, sitesY, radarX, radarY, titlesY, lineX, lineY, infoX, infoY;
var profilesW, profilesH, buildsW, buildsH, sitesW, sitesH, radarH, lineW, lineH, infoW, infoH;
var HIGHLIGHT, THEME, GSK_ORANGE, CAPACITY_COLOR, NOW;
var textColor = 255;
var background = 50;
var BUTTON_OFFSET_H = 40;
var BUTTON_OFFSET_W = 50;


var displayBuilds = true;
var displayRadar = true;
var infoOverlay = false;
var infoOverride = false;

function setup() {
  var HIGHLIGHT = color(174, 230, 230);
  var THEME = color(255, 108,47);
  var GSK_ORANGE = color(255, 108,47);
  var CAPACITY_COLOR = color(200, 95, 224); 
  var NOW = color(255, 220, 4);

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
  background(NOW);
  // background(abs(background - 15));

  textSize(textSize);
}

function draw() {
  drawScreen();
  image(logo_MIT, 5, 5, 30, 30);
}
















function drawScreen() {
  //Profile
  profilesX = int(0.18*width);
  profilesY = int(0.21*height);
  profilesW = int(0.23*width);
  profilesH = int(0.02*height);
  
  //Sites
  sitesX    = int(profilesX + profilesW + 100);
  sitesY    = int(0.21*height);
  sitesW    = int(0.08*width);
  sitesH    = int(height) - 2*MARGIN - sitesY;
  
  //Radar
  radarH    = int(0.05*width);
  radarX    = int(sitesX + radarH + 70);
  radarY    = int(0.8*height + 15);
  
  //Builds
  buildsX   = sitesX + radarH*3;
  buildsY   = sitesY + sitesH/2;
  buildsW   = int(0.13*width);
  buildsH   = profilesH;
  
  infoX     = int(0.05*(width) / 2 + 4*MARGIN);
  infoY     = int((height - int(0.85*height) ) / 2);
  infoW     = int(0.95*(width -4*MARGIN));
  infoH     = int(0.85*height);
  
  var canH = height - 2.8*MARGIN;

  // Output Graph
  if (displayRadar || displayBuilds) {
    lineX     = int(MARGIN*1.5 + sitesX + (width - sitesX - 1.25*MARGIN)/3 + 20);
    lineY     = int(2.2*MARGIN + 65 + canH*.6);
    lineW     = int(2*(width - sitesX - 1.25*MARGIN)/3 - 100);
    lineH     = int(canH*.25);
  } else {
    lineX     = int(MARGIN*1.5 + sitesX);
    lineY     = int(2.2*MARGIN + 65 + canH*.6);
    lineW     = int(width - sitesX - 3.25*MARGIN);
    lineH     = int(canH*.25);
  }

  noStroke();

  // Shadows
  fill(abs(background - 50));
  rect(0.25*MARGIN + profilesX+5, 2.2*MARGIN+5, profilesW + 1.75*MARGIN, canH, 4);
  rect(0.5*MARGIN + sitesX+5, 2.2*MARGIN+5, width - sitesX - 1.25*MARGIN, canH*.6, 4);
  rect(0.5*MARGIN + sitesX+5, 2.2*MARGIN + 25 + canH*.6 , width - sitesX - 1.25*MARGIN, canH*.4 - 20 , 4);
  
  // Canvas
  fill(abs(background - 0));
  rect(0.25*MARGIN + profilesX, 2.2*MARGIN, profilesW + 1.75*MARGIN, canH, 3);
  rect(0.5*MARGIN + sitesX, 2.2*MARGIN, width - sitesX - 1.25*MARGIN, canH*.6, 3);
  rect(0.5*MARGIN + sitesX, 2.2*MARGIN + 20 + canH*.6 , width - sitesX - 1.25*MARGIN, canH*.4 - 20 , 3);

  //Titles
  titlesY   = int(2.80*MARGIN);
  var selected;

  // Draw Title
  fill(textColor);
  textAlign(RIGHT);
  textSize(textSize);
  text("PharmaDSS " + VERSION, width - MARGIN, MARGIN);
  text("Ira Winder, Nina Lutz, Kent Larson (MIT), Joana Gomes (IIM, GSK)\nGiovanni Giorgio, Mason Briner (Capital Strategy and Design, GSK)\nAndrew Rutter (AMT), John Dyson (CSD, GSK)", width - MARGIN, MARGIN + textSize + 3);  
  
}