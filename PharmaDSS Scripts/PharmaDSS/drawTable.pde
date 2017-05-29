// The following scripts stage the drawing that is eventually projected upon a Tactile Matrix

TableSurface mfg;
float[] siteCapacity;
boolean enableSites;

/*      ---------------> + U-Axis
 *     |
 *     |
 *     |
 *     |
 *     |
 *     |
 *   + V-Axis
 *
 */

void setupTable() {
  offscreen = createGraphics(projectorHeight, projectorHeight, P3D);
  // TableSurface(int u, int v, boolean left_margin)
  mfg = new TableSurface(projectorHeight, projectorHeight, V_MAX, V_MAX, true);
  enableSites = true;
  generateBasins();
}

void drawTable() {
  
  // Draw the scene, offscreen
  mfg.draw(offscreen);
  
  if (testProjectorOnMac) {

//    fill(#000000, 100);
//    noStroke();
//    rect(0, 0, screenWidth, screenHeight);
    
    stroke(background);
    fill(textColor, 150);
    rect((width - int(0.85*height) ) / 2, (height - int(0.85*height) ) / 2, int(0.85*height), int(0.85*height), 10);
    
    image(offscreen, (width - int(0.8*height) ) / 2, (height - int(0.8*height) ) / 2, int(0.8*height), int(0.8*height));
  }
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
    
    if (enableSites) {
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
