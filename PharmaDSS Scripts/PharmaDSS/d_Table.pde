// The following scripts stage the drawing that is eventually projected upon a Tactile Matrix

TableSurface mfg;
float[][] siteCapacity;
boolean enableSites;

boolean dockedNCE = false;
boolean tableTest = false;

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

int BASINS_H = 6; // Height of Largest Basin (in Lego Squares)

void setupTable() {
  offscreen = createGraphics(projectorHeight, projectorHeight);
  // TableSurface(int u, int v, boolean left_margin)
  mfg = new TableSurface(projectorHeight, projectorHeight, V_MAX, V_MAX, true);
  enableSites = true;
  generateBasins();
}

void drawTable() {

  // Draw the scene, offscreen
  mfg.draw(offscreen);

  if (tableTest) {
    stroke(background);
    strokeWeight(1);
    fill(textColor, 100);
    rect((width - int(0.85*height) ) / 2, (height - int(0.85*height) ) / 2, int(0.85*height), int(0.85*height), 10);
    image(offscreen, (width - int(0.8*height) ) / 2, (height - int(0.8*height) ) / 2, int(0.8*height), int(0.8*height));

    mfg.mouseToGrid((width - int(0.8*height) ) / 2, (height - int(0.8*height) ) / 2, int(0.8*height), int(0.8*height));
  }
}

void generateBasins() {
  siteCapacity = new float[NUM_SITES][2];
  mfg.inputOccupied.clear();
  for (int i=0; i<NUM_SITES; i++) { 
    //siteCapacity[i] = agileModel.SITES.get(i).capEx + agileModel.SITES.get(i).capGn;
    siteCapacity[i][0] = agileModel.SITES.get(i).capEx;
    siteCapacity[i][1] = agileModel.SITES.get(i).capGn;

    // Define the number of tile blockers on start
    float percentBlocked = 0.25;
    mfg.inputOccupied.add( int(percentBlocked*siteCapacity[i][0]) );
  }

  mfg.clearBasins();
  mfg.addBasins(siteCapacity);
  enableSites = true;
}

class TableSurface {

  int U, V;
  int gridMouseU, gridMouseV;
  float cellW, cellH;

  String[][][] cellType;
  // Site, Existing/Green, Slice

  boolean LEFT_MARGIN;
  int MARGIN_W = 4;  // Left Margin for Grid (in Lego Squares)
  int BASINS_Y = 4;  // Top Margin for Basins (in Lego Squares)

  ArrayList<Basin> inputArea;
  ArrayList<Integer> inputOccupied; // Some Input Squares are initially occupied

    boolean[][] inUse, editing;
  Blocker[][] blocker;
  int[][] siteIndex, siteBuildIndex;

  TableSurface(int W, int H, int U, int V, boolean left_margin) {
    this.U = U;
    this.V = V;
    LEFT_MARGIN = left_margin;
    inputArea = new ArrayList<Basin>();
    inputOccupied = new ArrayList<Integer>();
    cellType = new String[U][V][3];
    inUse = new boolean[U][V];
    editing = new boolean[U][V];
    blocker = new Blocker[U][V];
    siteBuildIndex = new int[U][V];
    siteIndex = new int[U][V];

    cellW = float(W)/U;
    cellH = float(H)/V;

    resetCellTypes();
  }

  class Blocker {
    boolean active;
    int longevity;

    Blocker(int longevity) {
      active = true;
      this.longevity = longevity;
    }

    void update() {
      if (active) {
        longevity--;
        if (longevity < 0) active = false;
      }
    }
  }

  // Converts screen-based mouse coordinates to table grid position represented on screen during "Screen Mode"
  PVector mouseToGrid(int mouseX_0, int mouseY_0, int mouseW, int mouseH) {
    PVector grid = new PVector();
    boolean valid = true;

    grid.x = float(mouseX - mouseX_0) / mouseW * U;
    grid.y = float(mouseY - mouseY_0) / mouseH * V;

    if (grid.x >=MARGIN_W && grid.x < U) {
      gridMouseU = int(grid.x);
    } else {
      valid = false;
    }

    if (grid.y >=0 && grid.y < V) {
      gridMouseV = int(grid.y);
    } else {
      valid = false;
    }

    if (!valid) {
      gridMouseU = -1;
      gridMouseV = -1;
    }

    return grid;
  }

  boolean mouseInGrid() {
    if (gridMouseU == -1 || gridMouseV == -1) {
      return false;
    } else {
      return true;
    }
  }

  // add/remove a particular ID to a particular square
  void addMousePiece(int ID) {
    if (tablePieceInput[gridMouseU - MARGIN_W][gridMouseV][0] == -1) {
      tablePieceInput[gridMouseU - MARGIN_W][gridMouseV][0] = ID;
    } else {
      tablePieceInput[gridMouseU - MARGIN_W][gridMouseV][0] = -1;
    }
  }

  void resetCellTypes() {
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {

        // Sets Site ID to Null
        cellType[u][v][0] = "NULL";

        // Sets Site's "Existing" or "Greenfield" Status to Null
        cellType[u][v][1] = "NULL";

        inUse[u][v] = false;
        editing[u][v] = false;
        blocker[u][v] = new Blocker(3);
        blocker[u][v].active = false;
        siteBuildIndex[u][v] = -1;
        siteIndex[u][v] = -1;
      }
    }
  }

  void lockEdits() {
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {
        editing[u][v] = false;
      }
    }
  }
  
  void updateExisting() {
    // Cycle through each 22x22 Table Grid
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {  
        // Update Slice Construction Status
        int site = -1;
        int slice;
        if (cellType[u][v][0].equals("SITE_0")) site = 0;
        if (cellType[u][v][0].equals("SITE_1")) site = 1;
        if (cellType[u][v][0].equals("SITE_2")) site = 2;
        
        if (site >-1) {
          slice = int(cellType[u][v][2]);
          
          if ( inputArea.get(site).sliceBuilt[slice] ) {
            cellType[u][v][1] = "EXISTING";
          }
        }
      }
    }
  }
  
  void checkTableDeploy() {

    // Cycle through each 22x22 Table Grid
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {

        siteIndex[u][v] = -1;
        if (blocker[u][v].active) {
          tablePieceInput[u - MARGIN_W][v][0] = -1;
          tablePieceInput[u - MARGIN_W][v][1] = 0;
        }

        // Determine if the Cell is in a non-blocked "Site" Basin and, if so, which one
        if (inBasin(u, v) && inExisting(u, v) && !blocker[u][v].active) {
          if (cellType[u][v][0].equals("SITE_0")) siteIndex[u][v] = 0;
          if (cellType[u][v][0].equals("SITE_1")) siteIndex[u][v] = 1;
          if (cellType[u][v][0].equals("SITE_2")) siteIndex[u][v] = 2;

          if (tableHistory.size() > 0) {
            if (tablePieceInput[u - MARGIN_W][v][0] != tableHistory.get(tableHistory.size()-1)[u - MARGIN_W][v][0]) {
              editing[u][v] = true;
            }
          } else {
            editing[u][v] = true;
          }

          // If the cell is currently not in use, proceed
          if (!inUse[u][v]) {

            // If piece has ID
            if (tablePieceInput[u - MARGIN_W][v][0] > -1 && tablePieceInput[u - MARGIN_W][v][0] < NUM_PROFILES) {

              // Begin Building the Current Production Facility
              boolean repurp = inExisting(u, v);
              Event deploy = new Event("deploy", siteIndex[u][v], session.selectedBuild, agileModel.PROFILES.get(tablePieceInput[u - MARGIN_W][v][0]).ABSOLUTE_INDEX, repurp);
              session.current.event.add(deploy);
              siteBuildIndex[u][v] = agileModel.SITES.get(siteIndex[u][v]).siteBuild.size()-1;
              inUse[u][v] = true;
            }

            // If Lego Piece is Removed ...
            if (tablePieceInput[u - MARGIN_W][v][0] == -1 && siteBuildIndex[u][v] != -1) {
              try {
                //                if (agileModel.SITES.get(siteIndex[u][v]).siteBuild.get(siteBuildIndex[u][v]).editing) // If piece is yet to be confirmed
                inUse[u][v] = false;
                Event remove = new Event("remove", siteIndex[u][v], siteBuildIndex[u][v]);
                session.current.event.add(remove);
                dockIndex(siteBuildIndex[u][v]);
                siteBuildIndex[u][v] = -1;
                updateProfileCapacities();
              } 
              catch (Exception e) {
                println("Error Removing A Piece from the Table while NOT in use");
              }
            }
          } else { // If the cell is currently in use, proceed

            if (editing[u][v]) {
              // If Lego Piece is Removed ...
              if (tablePieceInput[u - MARGIN_W][v][0] == -1 && siteBuildIndex[u][v] != -1) { 
                try {
                  //                  if (agileModel.SITES.get(siteIndex[u][v]).siteBuild.get(siteBuildIndex[u][v]).editing) // If piece is yet to be confirmed
                  inUse[u][v] = false;
                  Event remove = new Event("remove", siteIndex[u][v], siteBuildIndex[u][v]);
                  session.current.event.add(remove);
                  dockIndex(siteBuildIndex[u][v]);
                  siteBuildIndex[u][v] = -1;
                  updateProfileCapacities();
                } 
                catch (Exception e) {
                  println("Error Removing A Piece from the Table while IN use");
                }
              } else { // If Lego Piece is Changed ....
              }
            }
          } // end else !inUse
        } // end inBasin
        
        // Profile Selection Dock
        if (tablePieceInput[7 - MARGIN_W][V-3][0] > -1 && tablePieceInput[7 - MARGIN_W][V-3][0] < NUM_PROFILES) {
          infoOverlay = true;
          if (gameMode) {
            session.selectedProfile = activeProfileIndex(tablePieceInput[7 - MARGIN_W][V-3][0]);
          } else {
            session.selectedProfile = tablePieceInput[7 - MARGIN_W][V-3][0];
          }
        } else {
          infoOverlay = false;
        }
        
        // Slice Deployment Slot
        if (enableSites) {
          if (inputArea.size() > 0) {
            for (int i=0; i<inputArea.size (); i++) {
              for (int j=0; j<inputArea.get(i).numSlices; j++) {
                
                int x_slice, y_slice;
                x_slice = inputArea.get(i).basinX - 3 - MARGIN_W;
                y_slice = inputArea.get(i).basinY + j;
                if (tablePieceInput[x_slice][y_slice][0] > -1 && inputArea.get(i).sliceTimer[j] == -1) {
                  inputArea.get(i).sliceTimer[j] = inputArea.get(i).SLICE_BUILD_TIME;
                }
                
              }
            }
          }
        }
        
      }
    }

    // Update Profile Information
    updateProfileCapacities();
  }

  void dockIndex(int dockedIndex) {
    // Cycle through each 22x22 Table Grid
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {
        if (siteBuildIndex[u][v] > dockedIndex) {
          siteBuildIndex[u][v]--;
        }
      }
    }
  }

  void draw(PGraphics p) {
    int buffer = 30;
    int spotLightHeight = int(1.15*cellH);
    int spotLightWidth = int(3.5*cellW);

    p.beginDraw();
    //  p.background(50);
    p.background(0);

    //draw spotlights
    for (int i = agileModel.profileColor.length-1; i>=0; i--) {
      p.fill(agileModel.profileColor[NUM_PROFILES - i - 1]);
      p.stroke(0, 100); p.strokeWeight(10);
      p.rect(15, (i*(spotLightHeight + 12) ) + buffer + 3*cellH, spotLightWidth, spotLightHeight, 10);
      p.fill(0);
      p.textSize(30);
      p.textAlign(CENTER, CENTER);
      p.text(NUM_PROFILES - i, 15 + 0.75*spotLightWidth, (i*(spotLightHeight + 12) ) + buffer + 3*cellH + spotLightHeight/2 - 2);
      p.image(nce, 0.25*spotLightWidth, (i*(spotLightHeight + 12) ) + buffer + 3*cellH + 0.05*spotLightHeight, cellW, cellH);
    }

    // Draw Site Boundaries (Existing and Greenfield) and/or Slices
    if (enableSites) {
      if (inputArea.size() > 0) {
        for (int i=0; i<inputArea.size (); i++) {
          p.fill(255);
          p.textAlign(BOTTOM);
          p.textSize(cellH/2);
//          p.text("Site " + (i+1), (inputArea.get(i).basinX + 0.0)*cellW, (inputArea.get(i).basinY - 4.1)*cellH);
          p.text("Site " + (i+1), (2.1 + MARGIN_W)*cellW, (inputArea.get(i).basinY + 3.5)*cellH);
//          p.shape(inputArea.get(i).s[0]);
//          p.shape(inputArea.get(i).s[1]);
          for (int j=0; j<inputArea.get(i).numSlices; j++) {
            
            p.stroke(0, 100); p.strokeWeight(20);
            if (inputArea.get(i).sliceBuilt[j]) {
              // Slice is built
              p.fill(GSK_ORANGE, 200);
            } else if (inputArea.get(i).sliceTimer[j] >= 0 ) {
              // slice under construction
              p.fill(#FFFF00, 200);
            } else {
              // Slice is not yet built or under construction
              p.fill(255, 70);
            }
            
            // Draw Slice In-site
            p.rect(inputArea.get(i).basinX*cellW, inputArea.get(i).basinY*cellH + j*cellH, inputArea.get(i).basinWidth*cellW, cellH);
            
            // Draw Slice Slot
            p.rect((inputArea.get(i).basinX - 3)*cellW, inputArea.get(i).basinY*cellH + j*cellH, cellW, cellH);
            p.textAlign(CENTER); p.textSize(10);
            p.text("SLICE", (inputArea.get(i).basinX - 2)*cellW + cellW/2, inputArea.get(i).basinY*cellH + j*cellH + cellH/2);
            p.textAlign(LEFT);
            
          }
          
//          p.shape(inputArea.get(i).s[0]);
          
          // p.tint(180);
//          p.image(sitePNG, (inputArea.get(i).basinX)*cellW, (1.5)*cellH, (inputArea.get(i).basinWidth)*cellW, (inputArea.get(i).basinY - 4.5)*cellH);
          p.image(sitePNG, (2 + MARGIN_W)*cellW, (inputArea.get(i).basinY)*cellH, 3.5*cellW, 3*cellH);
        }
      }
    }

    // Cycle through each table grid, skipping margin
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {
        if (!LEFT_MARGIN || (LEFT_MARGIN && u >= MARGIN_W) ) {

          if (blocker[u][v].active) {
            p.fill(GSK_ORANGE);
            p.rect(u*cellW, v*cellH, cellW, cellH);
            p.fill(0);
            p.stroke(255);
            p.strokeWeight(1);
            p.ellipse(u*cellW + 0.5*cellW, v*cellH + 0.5*cellH, cellW, cellH);
            p.fill(255);
            p.textSize(textSize);
            p.textAlign(CENTER);
            p.text("Exst", u*cellW + 0.5*cellW, v*cellH + 0.5*cellH);
            p.text("-" + blocker[u][v].longevity, u*cellW + 0.5*cellW, v*cellH + 0.85*cellH);
            p.textAlign(LEFT);
          }

          if (inBasin(u, v) && !blocker[u][v].active) {
            Build current;

            // Draw Colortizer Input Pieces
            if (tablePieceInput[u - MARGIN_W][v][0] >=0 && tablePieceInput[u - MARGIN_W][v][0] < NUM_PROFILES) {  
              p.noStroke();
              float ratio = 0.25;
              try {
                if (!agileModel.SITES.get(siteIndex[u][v]).siteBuild.get(siteBuildIndex[u][v]).built) {
                  // Draw Under Construction
                  p.fill(50);
                  p.rect(u*cellW, v*cellH, cellW, cellH);
                  p.fill(0);
                  p.stroke(agileModel.profileColor[ tablePieceInput[u - MARGIN_W][v][0] ], 200);
                  p.ellipse(u*cellW + 0.5*cellW, v*cellH + 0.5*cellH, 0.5*cellW, 0.5*cellH);
                } else {
                  // Draw Built
                  p.fill(agileModel.profileColor[ tablePieceInput[u - MARGIN_W][v][0] ]);
                  p.rect(u*cellW, v*cellH, cellW, cellH);
                  p.image(nce, u*cellW + ratio*cellW, v*cellH + 0.5*ratio*cellH, (1-2*ratio)*cellW, (1-2*ratio)*cellH);

                  //Draw Capacity
                  p.fill(0);
                  p.rect(u*cellW + 5, v*cellH + (1-ratio)*cellH - 5, cellW-10, ratio*cellH);
                  p.fill(255);
                  float cap = agileModel.SITES.get(siteIndex[u][v]).meetPercent;
                  p.rect(u*cellW + 5, v*cellH + (1-ratio)*cellH - 5, cap*(cellW-10), ratio*cellH);
                }
              } 
              catch (Exception e) {
                println("Error Drawing Table Piece");
              }
            }
          }

          // Draw black edges where Lego grid gaps are
          p.noFill();
          p.stroke(0);
          p.strokeWeight(3);
          p.rect(u*cellW, v*cellH, cellW, cellH);

          if (debug) {
            // Draw Symbol to show "in use"
            if (inUse[u][v]) {
              p.fill(#FF0000);
            } else {
              p.fill(#00FF00);
            }
            p.stroke(255);
            p.ellipse(u*cellW + 0.25*cellW, v*cellH + 0.5*cellH, 0.25*cellW, 0.25*cellH);

            // Draw Yellow Symbol if Active Editing
            if (editing[u][v]) {
              p.fill(#FFFF00);
              p.ellipse(u*cellW + 0.75*cellW, v*cellH + 0.5*cellH, 0.25*cellW, 0.25*cellH);
            }

            // Draw Other Info
            p.fill(255);
            p.textSize(10);
            p.text(siteIndex[u][v], u*cellW + 0.2*cellW, v*cellH + 0.2*cellH);
            p.text(siteBuildIndex[u][v], u*cellW + 0.2*cellW, v*cellH + 0.9*cellH);
          }         

          p.noFill();
        }
      }
    }

    // Draw Interface for Selecting NCE to Zoom In To
    p.fill(255);
    p.stroke(0, 100); p.strokeWeight(20);
    p.rect(6*cellW, (V-4)*cellH, cellW*3, 3*cellH, 0.5*cellW);
    p.noStroke();
    p.textSize(20);
    p.textAlign(RIGHT);
    p.text("Select\nNCE", 5.75*cellW, (V-3)*cellH + 20);
    p.fill(0);
    p.stroke(0, 100); p.strokeWeight(20);
    p.rect(7*cellW, (V-3)*cellH, cellW, cellH);

    // Draw NCE in Filter Dock
    if (tablePieceInput[7 - MARGIN_W][V-3][0] > -1 && tablePieceInput[7 - MARGIN_W][V-3][0] < NUM_PROFILES) {
      p.noStroke();
      p.fill(agileModel.profileColor[ tablePieceInput[7 - MARGIN_W][V-3][0] ]);
      p.noStroke();
      p.rect(7*cellW, (V-3)*cellH, cellW, cellH);
      p.image(nce, 7*cellW, (V-3)*cellH, cellW, cellH);
    }

    // Draw Black Edge around 4x22 left margin area
    if (LEFT_MARGIN) {
      p.noFill(); 
      p.stroke(0); 
      p.strokeWeight(3);
      p.rect(0, 0, MARGIN_W*cellW, p.height);
    }

    // Draw Mouse-based Cursor for Grid Selection
    if (gridMouseU != -1 && gridMouseV != -1) {
      p.fill(255, 50); 
      p.noStroke();
      p.rect(gridMouseU*cellW, gridMouseV*cellH, cellW, cellH);
    }

    // Draw logo_GSK, logo_MIT
    p.image(logo_GSK, 0.5*cellW, 1.0*cellW, 2.0*cellW, 2.0*cellW); 
    p.image(logo_MIT, 2.5*cellW, 2.1*cellW, 1.5*cellW, 0.7*cellW); 

    //drawBuilds(p);

    p.endDraw();
  }

  boolean inBasin(int u, int v) {
    if (cellType[u][v][0].substring(0, 4).equals("SITE") ) {
      return true;
    } else {
      return false;
    }
  }

  boolean inExisting(int u, int v) {
    if (cellType[u][v][1].substring(0, 4).equals("EXIS") ) {
      return true;
    } else {
      return false;
    }
  }

  void addBasins(float[][] basinSize) {
    int num = basinSize.length; // Number of Sites
    int availableWidth = U - MARGIN_W;
    int basinWidth;
//    int step;
    basinWidth = 8;
//    if (num == 2) {
//      basinWidth = 8;
//      step = 2;
//    } else {
//      basinWidth = int(float(availableWidth)/num);
//      step = 1;
//    }
    for (int i=0; i<num; i++) {
      // Creates Existing/Greenfield Basins for Site
//      inputArea.add( new Basin(i, MARGIN_W + step + i*basinWidth, BASINS_Y, basinSize[i], basinWidth - 2, BASINS_H) );
      inputArea.add( new Basin(i, U - basinWidth, BASINS_Y + int(i*(V - BASINS_Y)*0.4), basinSize[i], basinWidth - 2, BASINS_H) );
    }
  }

  void clearBasins() {
    inputArea.clear();
  }

  // A basin is an area on the table grid representing a total quantity 
  // of some available parameter. Typically, basins are "filled in" by tagged lego pieces.
  class Basin {
    int basinX, basinY, basinWidth, basinHeight;
    int[] basinSize;
    float[] basinCap;
    int[] CORNER_BEVEL;
    int MAX_SIZE;
    boolean isQuad = true;
    PShape[] s;
    int numSlices;
    boolean[] sliceBuilt;
    int SLICE_BUILD_TIME = 3;
    int[] sliceTimer;

    Basin(int index, int basinX, int basinY, float[] basinCap, int basinWidth, int basinHeight) {
      this.basinX = basinX;
      this.basinY = basinY;
      this.basinCap = basinCap; // Existing and Greenfield capacity
      this.basinWidth = basinWidth;
      this.basinHeight = basinHeight;

      MAX_SIZE = basinWidth * basinHeight;
      basinSize = new int[2];
      basinSize[0] = int((basinCap[0] + basinCap[1]) / agileModel.maxCap * MAX_SIZE); // Total
      basinSize[1] = int( basinCap[0] / agileModel.maxCap * MAX_SIZE); // Existing
      CORNER_BEVEL = new int[2];
      CORNER_BEVEL[0] = 10;
      CORNER_BEVEL[1] = 5;
      s = new PShape[2];
      numSlices = basinSize[0] / basinWidth;
      sliceBuilt = new boolean[numSlices];
      sliceTimer = new int[numSlices];
      for (int i=0; i<numSlices; i++) {
        sliceTimer[i] = -1; //null
        float e = basinSize[0]*float(i+1)/numSlices;
        
        // 0 = not built; 1 = built
        if (e <= basinSize[1]) {
          sliceBuilt[i] = true;
        } else {
          sliceBuilt[i] = false;
        }
      }

      // Designate CellType
      for (int i=0; i<basinSize[0]; i++) {
        int u = basinX + i%basinHeight;
        int v = basinY + i/basinHeight;
        cellType[u][v][0] = "SITE_" + index;
        if (i<basinSize[1]) {
          cellType[u][v][1] = "EXISTING";
          if (inputOccupied.get(index) > 0) {
            blocker[u][v].active = true;
            blocker[u][v].longevity = inputOccupied.get(index);
            inputOccupied.set(index, inputOccupied.get(index)-1);
          }
        } else {
          cellType[u][v][1] = "GREENFIELD";
        }
        cellType[u][v][2] = "" + (v - basinY);
        println(u, v, cellType[u][v][2]);
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
        
//        /*
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
        s[i].vertex( - CORNER_BEVEL[i] +  basinX*cellW, - CORNER_BEVEL[i] +  basinY*cellH);
//        */
        s[i].endShape(CLOSE);
      }
      
    }
  }
}

void fauxPieces(int code, int[][][] pieces, int maxID) {
  if (code == 2 ) {

    // Sets all grids to have "no object" (-1) with no rotation (0)
    for (int i=0; i<pieces.length; i++) {
      for (int j=0; j<pieces[0].length; j++) {
        pieces[i][j][0] = -1;
        pieces[i][j][1] = 0;
      }
    }
  } else if (code == 1 ) {

    // Sets grids to be alternating one of each N piece types (0-N) with no rotation (0)
    for (int i=0; i<pieces.length; i++) {
      for (int j=0; j<pieces[0].length; j++) {
        pieces[i][j][0] = i  % maxID+1;
        pieces[i][j][1] = 0;
      }
    }
  } else if (code == 0 ) {

    // Sets grids to be random piece types (0-N) with random rotation (0-3)
    for (int i=0; i<pieces.length; i++) {
      for (int j=0; j<pieces[0].length; j++) {
        if (random(0, 1) > 0.5) {
          pieces[i][j][0] = int(random(-1.99, maxID+1));
          pieces[i][j][1] = int(random(0, 4));
        } else { // 95% of pieces are blank
          pieces[i][j][0] = -1;
          pieces[i][j][1] = 0;
        }
      }
    }
  } else if (code == 3) {

    // Adds N random pieces to existing configuration
    for (int i=0; i<50; i++) {
      int u = int(random(0, pieces.length)); 
      int v = int(random(0, pieces[0].length)); 
      if (pieces[u][v][0] == -1) {
        pieces[u][v][0] = int(random(-1.99, maxID+1));
        pieces[u][v][1] = int(random(0, 4));
      }
    }
  }
}

void testPlace(int[][][] pieces, int u, int v, int id) {
  if (pieces[u][v][0] == -1) {
    pieces[u][v][0] = id;
  } else {
    pieces[u][v][0] = -1;
  }
}

void decodePieces() {
  mfg.checkTableDeploy();
}

void drawBuilds(PGraphics p) {
  // Draw Build/Repurpose Units

  //Builds
  buildsX = 20;
  buildsY = int(0.75*p.height);
  buildsW   = int(0.135*p.width);
  buildsH   = profilesH;

  boolean selected;

  p.beginDraw();

  // Build Var
  p.fill(255);
  p.textAlign(LEFT);
  p.textSize(12);
  p.text("Pre-Engineered \nProduction Units:", buildsX, buildsY - MARGIN);
  float spread = 3.0;

  // Draw GMS Build Options
  p.fill(255);
  p.textAlign(LEFT);
  p.text("GMS", buildsX, buildsY + 1.4*MARGIN);
  //      text("Build", MARGIN + buildsX, buildsY - 10);
  //      text("Repurpose", MARGIN + buildsX + 80, buildsY - 10);
  for (int i=0; i<agileModel.GMS_BUILDS.size (); i++) {
    selected = false;
    if (i == session.selectedBuild) selected = true;
    agileModel.GMS_BUILDS.get(i).draw(p, buildsX, 2*MARGIN + buildsY + int(spread*buildsH*i), buildsW, buildsH, "GMS", selected);
  }
  // Draw R&D Build Options
  p.fill(255);
  p.textAlign(LEFT);
  float vOffset = buildsY + spread*buildsH*(agileModel.GMS_BUILDS.size()+1);
  p.text("R&D", buildsX, vOffset + 1.4*MARGIN);
  for (int i=0; i<agileModel.RND_BUILDS.size (); i++) {
    selected = false;
    // if (...) selected = true;
    agileModel.RND_BUILDS.get(i).draw(p, buildsX, 2*MARGIN + int(vOffset + spread*buildsH*i ), buildsW, buildsH, "R&D", selected);
  }

  // Draw Personnel Legend
  int vOff = -50;
  p.fill(255);
  p.textAlign(LEFT);
  //      text("Personnel:", titlesY, MARGIN);
  for (int i=0; i<NUM_LABOR; i++) {
    if (i==0) {
      p.fill(#CC0000);
    } else if (i==1) {
      p.fill(#00CC00);
    } else if (i==2) {
      p.fill(#0000CC);
    } else if (i==3) {
      p.fill(#CCCC00);
    } else if (i==4) {
      p.fill(#CC00CC);
    } else {
      p.fill(#00CCCC);
    }

    int xOff = 0;
    if (i > 2) {
      xOff = 100;
    }

    p.ellipse(buildsX + xOff, 15*(i%3) - 4 + buildsY, 3, 10);
    p.fill(255);
    p.text(agileModel.LABOR_TYPES.getString(i, 0), buildsX + 10 + xOff, 15*(i%3) + buildsY);
  }

  p.endDraw();
}

