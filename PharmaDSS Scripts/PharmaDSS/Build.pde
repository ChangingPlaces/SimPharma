// A production unit that describes a socio-technical process for manufacturing a chemical entity at a site
class Build {

  // Name of Production Type (i.e. "Continuous Batch Hybrid")
  String name;

  //  Build/Repurpose  Size
  float capacity; 

  //  Build Cost, Build Time
  float buildCost, buildTime;

  //  Repurpose Cost, Repurpose Time
  float repurpCost, repurpTime; 

  // Operators (Amount, Shifts, Cost)
  ArrayList<Person> labor;
  
  // Status of Build when allocated to a site:

  // NCE profile produced by build
  int PROFILE_INDEX;
  // Is build operational, yet?
  boolean built;
  // How many years since the build has been comissioned?
  int age;
  // Is the build flagged to be demolished?
  boolean demolish = false;
  // Is the build being repurposed?
  boolean repurpose = false;
  
  boolean capEx_Logged = false;

  // Basic Constructor
  Build() {
    labor = new ArrayList<Person>();
  }

  // The Class Constructor
  Build(String name, float capacity, float buildCost, float buildTime, float repurpCost, float repurpTime, ArrayList<Person> labor) {
    this.name = name;
    this.capacity = capacity;
    this.buildCost = buildCost;
    this.buildTime = buildTime;
    this.repurpCost = repurpCost;
    this.repurpTime = repurpTime;
    this.labor = labor;
  }

  // Allocate Specific Profile Information to a Build when it is deployed on Site
  void assignProfile(int index) {
    PROFILE_INDEX = index;
    built = false;
    age = 0;
  }

  // Update Temporal aspects of build, such as age and construction progress
  void updateBuild() {
    age++;
    if (repurpose) {
      if (age >= repurpTime) {
        built = true;
        repurpose = false;
      }
    } else if (age >= buildTime) {
      // Build becomes active after N years of construction
      built = true;
    }
  }

  void draw(PGraphics p, int x, int y, int w, int h, String type, boolean selected) {

//    // Draw Build Selection Box
//    if (selected) {
//      p.fill(HIGHLIGHT, 40);
//      //stroke(HIGHLIGHT, 80);
//      //strokeWeight(1);
//
//      p.noStroke();     
//      p.rect(x - 15, y - h - 7, w + 40, h+32, 5);
//      p.noStroke();
//    }

    // Draw Build Characteristics
    int scaler = 3;
    p.noStroke();    
    p.fill(abs(255 - 75));
    p.rect(x + 35, y - 5, scaler*capacity, 10, 3);
    p.textAlign(LEFT);
    p.textSize(12);
    p.fill(255);
    p.text(capacity + " " + agileModel.WEIGHT_UNITS, x, y + 4);
    if (type.equals("GMS")) {
      p.text("BLD: " + int(buildTime) + " " + agileModel.TIME_UNITS + ", " + int(buildCost/100000)/10.0 + agileModel.COST_UNITS, x, y - 11);
      p.text("RPP: " + int(repurpTime) + " " +agileModel.TIME_UNITS + ", " + int(repurpCost/100000)/10.0 + agileModel.COST_UNITS, x + 100, y - 11);
    } else {
      p.text("RPP: " + int(repurpTime) + " " +agileModel.TIME_UNITS + ", " + int(repurpCost/100000)/10.0 + agileModel.COST_UNITS, x, y - 11);
    }
    for (int i=0; i< labor.size (); i++) {
      if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(0, 0) )) {
        p.fill(#CC0000);
      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(1, 0) )) {
        p.fill(#00CC00);
      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(2, 0) )) {
        p.fill(#0000CC);
      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(3, 0) )) {
        p.fill(#CCCC00);
      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(4, 0) )) {
        p.fill(#CC00CC);
      } else {
        p.fill(#00CCCC);
      }
      p.ellipse(x + 37 + i*5, y + 15, 3, 10);
    }
  }
}

