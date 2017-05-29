//GSK Orange:
//RGB 255 108 47 
//HEX/HTML FF6C2F 
//CMYK 0 45 86 0

/*
FeatureScope:
  - Framework for methods
  - Automate drawing of Sites based upon relative/absolute sizes
  - Make purty
*/

int GSK_ORANGE = #FF6C2F;
import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;

TableSurface mfg;

float[] siteCapacity;
boolean enableSites;

int canvasWidth = 1920;
int canvasHeight = 1080;

void setup() {
  // Keystone will only work with P3D or OPENGL renderers, 
  // since it relies on texture mapping to deform
  size(canvasWidth, canvasHeight, P3D);
  
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(canvasHeight, canvasHeight, 20);
  
  // We need an offscreen buffer to draw the surface we
  // want projected
  // note that we're matching the resolution of the
  // CornerPinSurface.
  // (The offscreen buffer can be P2D or P3D)
  offscreen = createGraphics(canvasHeight, canvasHeight, P3D);
  
  // TableSurface(int u, int v, boolean left_margin)
  mfg = new TableSurface(canvasHeight, canvasHeight, 22, 22, true);
  
  enableSites = true;
  generateBasins();
  ks.load();
}

void generateBasins() {
  int numBasins = int(random(2,4));
  siteCapacity = new float[numBasins];
  for (int i=0; i<numBasins; i++) { 
    siteCapacity[i] = random(10,50);
  }
  
  mfg.clearBasins();
  mfg.addBasins(siteCapacity);
  enableSites = true;
}

void draw() {
  // most likely, you'll want a black background to minimize
  // bleeding around your projection area
  background(0);
  
  if (enableSites) {
    
    // Draw Table Surface
    mfg.draw(offscreen);
 
    // render the scene, transformed using the corner pin surface
    surface.render(offscreen);
    
  }
}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
    
  case 'r':
    // saves the layout
    generateBasins();
    break;
  }
}

class TableSurface {
  
  int U, V;
  float cellW, cellH;

  boolean LEFT_MARGIN;
  int MARGIN_W = 4;
  int BASINS_Y = 5;
  
  ArrayList<Basin> inputArea;
  
  TableSurface(int W, int H, int u, int v, boolean left_margin) {
    U = u;
    V = v;
    LEFT_MARGIN = left_margin;
    inputArea = new ArrayList<Basin>();
    
    cellW = float(W)/U;
    cellH = float(H)/V;
  }
  
  void draw(PGraphics p) {
    
    p.beginDraw();
    p.background(50);
    
    if (inputArea.size() > 0) {
      for (int i=0; i<inputArea.size(); i++) {
        p.fill(255);
        p.textAlign(CENTER, CENTER);
        p.textSize(cellH/2);
        p.text(i, (inputArea.get(i).basinX - 0.5)*cellW, (inputArea.get(i).basinY - 1.5)*cellH);
        p.shape(inputArea.get(i).s[0]);
        p.shape(inputArea.get(i).s[1]);
      }
    }
    
    p.noFill();
    p.stroke(0);
    p.strokeWeight(3);
    
    // Draw black edges where Lego grad gaps are
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {
        if (!LEFT_MARGIN || (LEFT_MARGIN && u >= MARGIN_W) ) {
          p.rect(u*cellW, v*cellH, cellW, cellH);
        }
      }
    }
    
    // Draw Black Edge around 4x22 left margin area
    if (LEFT_MARGIN) {
      p.rect(0, 0, MARGIN_W*cellW, p.height);
    }
    
    p.endDraw();
  }
  
  void addBasins(float[] basinSize) {
    int num = basinSize.length;
    int availableWidth = U - MARGIN_W;
    int basinWidth = int(float(availableWidth)/num);
    for (int i=0; i<num; i++) {
      inputArea.add( new Basin(MARGIN_W + 1 + i*basinWidth, BASINS_Y, int(basinSize[i]), basinWidth - 2) );
    }
  }
  
  void clearBasins() {
    inputArea.clear();
  }
  
  // A basin is an area on the table grid representing a total quantity 
  // of some available parameter. Typically, basins are "filled in" by tagged lego pieces.
  class Basin {
    int basinX, basinY, basinSize, basinWidth;
    int[] CORNER_BEVEL;
    
    boolean isQuad = true;
    PShape[] s;
    
    Basin(int basinX, int basinY, int basinSize, int basinWidth) {
      this.basinX = basinX;
      this.basinY = basinY;
      this.basinSize = basinSize;
      this.basinWidth = basinWidth;
      
      CORNER_BEVEL = new int[2];
      CORNER_BEVEL[0] = 10;
      CORNER_BEVEL[1] =int( 0.75*CORNER_BEVEL[0] );
      s = new PShape[2];
      
      if (basinSize%basinWidth != 0) {
        isQuad = false;
      }
      
      // Outline
      for (int i=0; i<2; i++) {
        s[i] = createShape();
        s[i].beginShape();
        
        s[i].noFill();
        s[i].strokeWeight(1.5*CORNER_BEVEL[i]);
        
        if (i==0) {
          s[i].stroke(255);
        } else {
          s[i].stroke(GSK_ORANGE, 200);
        }

        s[i].vertex( - CORNER_BEVEL[i] +  basinX*cellW,                 - CORNER_BEVEL[i] +  basinY*cellH);
        s[i].vertex( + CORNER_BEVEL[i] + (basinX + basinWidth) * cellW, - CORNER_BEVEL[i] +  basinY*cellH);
        if (isQuad) {
          s[i].vertex( + CORNER_BEVEL[i] + (basinX + basinWidth) * cellW, + CORNER_BEVEL[i] + (basinY + basinSize / basinWidth) * cellH);
        } else {
          s[i].vertex( + CORNER_BEVEL[i] + (basinX + basinWidth) * cellW, + CORNER_BEVEL[i] + (basinY + basinSize / basinWidth - 1) * cellH);
          s[i].vertex( + CORNER_BEVEL[i] + (basinX + basinSize%basinWidth) * cellW, + CORNER_BEVEL[i] + (basinY + basinSize / basinWidth - 1) * cellH);
          s[i].vertex( + CORNER_BEVEL[i] + (basinX + basinSize%basinWidth) * cellW, + CORNER_BEVEL[i] + (basinY + basinSize / basinWidth) * cellH);
        }
        s[i].vertex( - CORNER_BEVEL[i] +  basinX*cellW,                 + CORNER_BEVEL[i] + (basinY + basinSize / basinWidth) * cellH);
  
        s[i].endShape(CLOSE);
      }
    }
  }

}
