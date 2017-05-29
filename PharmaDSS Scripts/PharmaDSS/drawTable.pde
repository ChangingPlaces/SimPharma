// The following scripts stage the drawing that is eventually projected upon a Tactile Matrix

TableSurface mfg;
float[][] siteCapacity;
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

    stroke(background);
    strokeWeight(1);
    fill(textColor, 100);
    rect((width - int(0.85*height) ) / 2, (height - int(0.85*height) ) / 2, int(0.85*height), int(0.85*height), 10);
    image(offscreen, (width - int(0.8*height) ) / 2, (height - int(0.8*height) ) / 2, int(0.8*height), int(0.8*height));
  }
}

void generateBasins() {
  siteCapacity = new float[NUM_SITES][2];
  for (int i=0; i<NUM_SITES; i++) { 
    //siteCapacity[i] = agileModel.SITES.get(i).capEx + agileModel.SITES.get(i).capGn;
    siteCapacity[i][0] = agileModel.SITES.get(i).capEx;
    siteCapacity[i][1] = agileModel.SITES.get(i).capGn;
  }

  mfg.clearBasins();
  mfg.addBasins(siteCapacity);
  enableSites = true;
}

class TableSurface {

  int U, V;
  float cellW, cellH;
  
  String[][][] cellType;

  boolean LEFT_MARGIN;
  int MARGIN_W = 4;
  int BASINS_Y = 5;

  ArrayList<Basin> inputArea;

  TableSurface(int W, int H, int U, int V, boolean left_margin) {
    this.U = U;
    this.V = V;
    LEFT_MARGIN = left_margin;
    inputArea = new ArrayList<Basin>();
    cellType = new String[U][V][2];

    cellW = float(W)/U;
    cellH = float(H)/V;
    
    resetCellTypes();
  }
  
  void resetCellTypes() {
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {
        cellType[u][v][0] = "NULL";
        cellType[u][v][1] = "NULL";
      }
    }
  }

  void draw(PGraphics p) {

    p.beginDraw();
    p.background(50);

    // Draw Site Boundaries (Existing and Greenfield)
    if (enableSites) {
      if (inputArea.size() > 0) {
        for (int i=0; i<inputArea.size (); i++) {
          p.fill(255);
          p.textAlign(CENTER, CENTER);
          p.textSize(cellH/2);
          p.text(i, (inputArea.get(i).basinX - 0.5)*cellW, (inputArea.get(i).basinY - 1.5)*cellH);
          p.shape(inputArea.get(i).s[0]);
          p.shape(inputArea.get(i).s[1]);
        }
      }
    }

    // Cycle through each table grid, skipping margin
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {
        if (!LEFT_MARGIN || (LEFT_MARGIN && u >= MARGIN_W) ) {
          
          if (inBasin(u, v)) {
            // Draw Colortizer Input Pieces
            if (tablePieceInput[u - MARGIN_W][v][0] >=0 && tablePieceInput[u - MARGIN_W][v][0] < ID_MAX) {
              
              if (inExisting(u, v)) {
                p.fill(GSK_ORANGE, 100);
              } else {
                p.fill(#00FF00, 100);
              }
              p.noStroke();
              p.rect(u*cellW, v*cellH, cellW, cellH);
            }
          }
          
          // Draw black edges where Lego grad gaps are
          p.noFill();
          p.stroke(0);
          p.strokeWeight(3);
          p.rect(u*cellW, v*cellH, cellW, cellH);
          
        }
      }
    }

    // Draw Black Edge around 4x22 left margin area
    if (LEFT_MARGIN) {
      p.rect(0, 0, MARGIN_W*cellW, p.height);
    }
    
    // Draw Logo
    int buffer = 30;
    p.image(logo, buffer, buffer, MARGIN_W*cellW - 2*buffer, MARGIN_W*cellW - 2*buffer); 

    p.endDraw();
  }
  
  boolean inBasin(int u, int v) {
    if (cellType[u][v][0].substring(0,4).equals("SITE") ) {
      return true;
    } else {
      return false;
    }
  }
  
  boolean inExisting(int u, int v) {
    if (cellType[u][v][1].substring(0,4).equals("EXIS") ) {
      return true;
    } else {
      return false;
    }
  }
  
  void addBasins(float[][] basinSize) {
    int num = basinSize.length;
    int availableWidth = U - MARGIN_W;
    int basinWidth = int(float(availableWidth)/num);
    for (int i=0; i<num; i++) {
      inputArea.add( new Basin(i, MARGIN_W + 1 + i*basinWidth, BASINS_Y, basinSize[i], basinWidth - 2) );
    }
  }

  void clearBasins() {
    inputArea.clear();
  }

  // A basin is an area on the table grid representing a total quantity 
  // of some available parameter. Typically, basins are "filled in" by tagged lego pieces.
  class Basin {
    int basinX, basinY, basinWidth;
    int[] basinSize;
    float[] basinCap;
    int[] CORNER_BEVEL;
    int MAX_SIZE;
    boolean isQuad = true;
    PShape[] s;

    Basin(int index, int basinX, int basinY, float[] basinCap, int basinWidth) {
      this.basinX = basinX;
      this.basinY = basinY;
      this.basinCap = basinCap;
      this.basinWidth = basinWidth;

      MAX_SIZE = basinWidth * ( V_MAX - basinY - 5);
      basinSize = new int[2];
      basinSize[0] = int((basinCap[0] + basinCap[1]) / agileModel.maxCap * MAX_SIZE);
      basinSize[1] = int( basinCap[0] / agileModel.maxCap * MAX_SIZE);

      CORNER_BEVEL = new int[2];
      CORNER_BEVEL[0] = 10;
      CORNER_BEVEL[1] = 5;
      s = new PShape[2];

      // Designate CellType
      for (int i=0; i<basinSize[0]; i++) {
        int u = basinX + i%basinWidth;
        int v = basinY + i/basinWidth;
        cellType[u][v][0] = "SITE_" + index;
        if (i<basinSize[1]) {
          cellType[u][v][1] = "EXISTING";
        } else {
          cellType[u][v][1] = "GREENFIELD";
        }
      }

      // Outline (0 = Existing Capacity; 1 = Greenfield Capacity);
      for (int i=0; i<2; i++) {
        
        if (basinSize[i]%basinWidth != 0) {
          isQuad = false;
        } else {
          isQuad = true;
        }
      
        s[i] = createShape();
        s[i].beginShape();

        s[i].noFill();
        
        s[i].strokeWeight(2*CORNER_BEVEL[i]);

        if (i==0) {
          s[i].stroke(255, 150);
          
        } else {
          s[i].stroke(GSK_ORANGE);
        }

        s[i].vertex( - CORNER_BEVEL[i] +  basinX*cellW, - CORNER_BEVEL[i] +  basinY*cellH);
        s[i].vertex( + CORNER_BEVEL[i] + (basinX + basinWidth) * cellW, - CORNER_BEVEL[i] +  basinY*cellH);
        if (isQuad) {
          s[i].vertex( + CORNER_BEVEL[i] + (basinX + basinWidth) * cellW, + CORNER_BEVEL[i] + (basinY + basinSize[i] / basinWidth) * cellH);
          s[i].vertex( - CORNER_BEVEL[i] +  basinX*cellW, + CORNER_BEVEL[i] + (basinY + basinSize[i] / basinWidth) * cellH);
        } else {
          s[i].vertex( + CORNER_BEVEL[i] + (basinX + basinWidth) * cellW, + CORNER_BEVEL[i] + (basinY + basinSize[i] / basinWidth) * cellH);
          s[i].vertex( + CORNER_BEVEL[i] + (basinX + basinSize[i]%basinWidth) * cellW, + CORNER_BEVEL[i] + (basinY + basinSize[i] / basinWidth) * cellH);
          s[i].vertex( + CORNER_BEVEL[i] + (basinX + basinSize[i]%basinWidth) * cellW, + CORNER_BEVEL[i] + (basinY + basinSize[i] / basinWidth + 1) * cellH);
          s[i].vertex( - CORNER_BEVEL[i] +  basinX*cellW, + CORNER_BEVEL[i] + (basinY + basinSize[i] / basinWidth + 1) * cellH);
        }
        

        s[i].endShape(CLOSE);
      }
    }
  }
}

