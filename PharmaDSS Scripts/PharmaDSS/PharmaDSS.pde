 /* PharmaDSS Beta
 /  Ira Winder, jiw@mit.edu
 /  Cambridge, MA
 /
 /  Beta 1.0 Reslease:
 /
 /  The following scripts demonstrate a basic interactive environment for "PharmaDSS."
 /  The scripts are a parametric implementation of GSK's "Agile Network Meta-model v7"
 /  developed by Mason Briner and Giovonni Giorgio in U.K. 
 /
 /  The primary purpose of this work is overcome various limitations of excel such as: 
 /  graphics, usability, and stochastic variability.
 /
 /  The Beta is designed with the following minimum viable features:
 /  - Object-oriented framework for model components
 /  - Directly read values from Microsoft Excel, linking GSK (Excel-based) and MIT (Java-based) workflows
 /  - Turn-based interaction using mouse and keyboard commands:
 /      1. Allocate/Move/Delete NCE capacity between sites
 /      2. Progress each turn
 /  - Implement stochastic events not easily performed in excel
 /  - Allow user to compare performance with baseline scenario(s)
*/

// Initialize (1)system and (2)objects of model:
System agileModel;

// Specify to "true" if reading System Values from an XLS spreadsheet file in the "data/" folder"
boolean readXLS = true;

// "setup()" runs once upon executing script
void setup() {
  
  // Initiate System and Objects
  agileModel = new System();
  
  // Load Model XLS
  if (readXLS) {
    
    /* Note the following requisites to read an excel file in this program:
     / - filename must end in ".xls"
     / - file must be saved as "Excel 97-2004 Workbook (.xls)"
     / - 2007+ XLSX files will NOT work
     / - Referenced cells are VALUES, not EQUATIONS
    */
    
    loadModel_XLS(agileModel, "Agile Network Model v7_XLS.xls"); // assumes file to be in the data folder, refer to tab "xls.pde"

  }
  
  // Setup for Canvas Visualization
  size(800, 400);
  background(0);
}

// "draw()" runs as infinite loop after setup() is performed, unless "noLoop()" is instantiated.
void draw() {
  
}
