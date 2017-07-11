var screenWidth = 1280;
var screenHeight = 800;
var textSizeValue = 12;
var MARGIN = 50;
var profilesX, profilesY, buildsX, buildsY, sitesX, sitesY, radarX, radarY, titlesY, lineX, lineY, infoX, infoY;
var profilesW, profilesH, buildsW, buildsH, sitesW, sitesH, radarH, lineW, lineH, infoW, infoH;
var HIGHLIGHT, THEME, GSK_ORANGE, CAPACITY_COLOR, NOW;
var textColor = 255;
var backgroundValue = 50;
var BUTTON_OFFSET_H = 40;
var BUTTON_OFFSET_W = 50;


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
}

function draw() {
  drawScreen();
}
















