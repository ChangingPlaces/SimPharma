//
// This is a script that allows one to open a new canvas for the purpose 
// of simple 2D projection mapping, such as on a flat table surface
//
// Right now, only appears to work in windows...
//
// To use this example in the real world, you need a projector
// and a surface you want to project your Processing sketch onto.
//
// Simply press the 'c' key and drag the corners of the 
// CornerPinSurface so that they
// match the physical surface's corners. The result will be an
// undistorted projection, regardless of projector position or 
// orientation.
//
// You can also create more than one Surface object, and project
// onto multiple flat surfaces using a single projector.
//
// This extra flexbility can comes at the sacrifice of more or 
// less pixel resolution, depending on your projector and how
// many surfaces you want to map. 
//

import javax.swing.JFrame;
import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;

TableSurface mfg;
float[] siteCapacity;
boolean enableSites;

// Visualization may show 2D projection visualization, or not
boolean displayProjection2D = false;
boolean testProjectorOnMac = false;

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

// New Application Window Parameters
PFrame proj2D = null; // f defines window to open new applet in
projApplet applet;    // applet acts as new set of setup() and draw() functions that operate in parallel

// Run Anything Needed to have Projection mapping work
void initializeProjection2D() {
  println("Projector Info: " + projectorWidth + ", " + projectorHeight + ", " + projectorOffset);
}

public class PFrame extends JFrame {
  public PFrame() {
    setBounds(0, 0, projectorWidth, projectorHeight );
    setLocation(projectorOffset, 0);
    applet = new projApplet();
    setResizable(false);
    setUndecorated(true); 
    setAlwaysOnTop(true);
    add(applet);
    applet.init();
    show();
    setTitle("Projection2D");
  }
}

public void showProjection2D() {
  if (proj2D == null) {
    proj2D = new PFrame();
  }
  proj2D.setVisible(true);
}

public void closeProjection2D() {
  proj2D.setVisible(false);
}

public void resetProjection2D() {
  initializeProjection2D();
  if (proj2D != null) {
    proj2D.dispose();
    proj2D = new PFrame();
    if (displayProjection2D) {
      showProjection2D();
    } else {
      closeProjection2D();
    }
  }
}

public class projApplet extends PApplet {
  public void setup() {
    // Keystone will only work with P3D or OPENGL renderers, 
    // since it relies on texture mapping to deform
    size(projectorWidth, projectorHeight, P2D);
    
    ks = new Keystone(this);
    
    reset();
  }
  
  public void reset() {
    surface = ks.createCornerPinSurface(projectorHeight, projectorHeight, 20);
    offscreen = createGraphics(projectorHeight, projectorHeight);
    
    try{
      ks.load();
    } catch(RuntimeException e){
      println("No Keystone.xml.  Save one first if you want to load one.");
    }
  }
  
  public void draw() {
    
    // Convert the mouse coordinate into surface coordinates
    // this will allow you to use mouse events inside the 
    // surface from your screen. 
//    PVector surfaceMouse = surface.getTransformedMouse();
    
    // most likely, you'll want a black background to minimize
    // bleeding around your projection area
    background(0);
    
    // Draw the scene, offscreen
    surface.render(offscreen);
  
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
      
      case '`': 
        if (displayProjection2D) {
          displayProjection2D = false;
          closeProjection2D();
        } else {
          displayProjection2D = true;
          showProjection2D();
        }
        break;
    }
  }
}

void toggle2DProjection() {
  if (System.getProperty("os.name").substring(0,3).equals("Mac")) {
    testProjectorOnMac = !testProjectorOnMac;
    println("Test on Mac = " + testProjectorOnMac);
    println("Projection Mapping Currently not Supported for MacOS");
  } else {
    if (displayProjection2D) {
      displayProjection2D = false;
      closeProjection2D();
    } else {
      displayProjection2D = true;
      showProjection2D();
    }
  }
}

void setupTable() {
  offscreen = createGraphics(projectorHeight, projectorHeight);
  // TableSurface(int u, int v, boolean left_margin)
  mfg = new TableSurface(projectorHeight, projectorHeight, 22, 22, true);
  enableSites = true;
  generateBasins();
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
