 /* Classes that define primary object abstractions in the system such as: 
 /  (a) Profile: NCE demand profile
 /  (b) Site: Factory Location/Area
 /  (c) Build: Manufacturing Unit/Process
 /  (d) Person: "Human Beans", as the BFG would say (i.e. Labor)
*/

// Demand profile for a chemical entity (i.e. NCE)
class Profile {
  
  // Name of NCE Demand Profile
  String name; 

  // Breif Descriptor of Profile (i.e. "Blockbuster" or "Never Manufactured")
  String summary;
  
  // Success/ Failure (due to clinical trail failure, competition enters market, etc)
  boolean success;
  
  // (TBA) Criticality to Patient
  // (TBA) Number of Stages
  
  // Peak Forecast Demand  
  float demandPeak; // calculate from demandProfile
  
  // Start Time  
  String timeStart;
  
  //  Recoveries (cost per weight)
  float recoveries;
  
  // Each element describes unique production cost associated with a Site (cost per time)
  ArrayList<Float> productionCost; 
  
  
  //  Columns of consecutive, discrete time intervals describing:
  //  - Time
  //  - Forecast demand (weight per time)
  //  - Actual Demand (weight per time)
  //  - Event Description
  Table demandProfile;
  
  // Basic Constructor
  Profile() {
    productionCost = new ArrayList<Float>();
    demandProfile = new Table();
  }
  
  // The Class Constructor
  Profile(String name, String summary, boolean success, String timeStart, float recoveries, ArrayList<Float> productionCost, Table demandProfile) {
    this.name = name;
    this.summary = summary;
    this.success = success;
    this.timeStart = timeStart;
    this.productionCost = productionCost;
    this.demandProfile = demandProfile;
  }
  
  void peak() {
    demandPeak = 0;
    for (int i=0; i<demandProfile.getColumnCount(); i++) {
      if (demandPeak < demandProfile.getFloat(1, i) ) {
        demandPeak = demandProfile.getFloat(1, i);
      }
    }
  }
  
  void draw(int x, int y, int w, int h) {
    float scalerH = h/demandPeak;
    float scalerW = float(w)/demandProfile.getColumnCount();
    for (int i=0; i<demandProfile.getColumnCount(); i++) {
      float barF = scalerH * demandProfile.getFloat(1, i);
      float barA = scalerH * demandProfile.getFloat(2, i);
      noStroke();
      fill(255, 150);
      rect(x + scalerW * i, y - barF, scalerW, barF);
      fill(#0000FF, 200);
      rect(x + scalerW * i, y - barA, scalerW, barA);
      fill(255);
    }
    textAlign(LEFT);
    text(name + ", " + summary, x, y + 15);
    textAlign(RIGHT);
    text(NUM_INTERVALS + " " + agileModel.TIME_UNITS, x + w, y + 15);
  }
}

// Site Characteristics for a given manufacturing site (i.e. Cork, Jurong)
class Site {
  
  // Name of Site
  String name;
  
  // Capacity at site, existing and Greenfield
  float capEx, capGn;
  
  // Limit to the amount of NCEs on site for RnD
  int limitRnD;
  
  // Basic Constructor
  Site() {}
  
  // The Class Constructor
  Site(String name, float capEx, float capGn, int limitRnD) {
    this.name = name;
    this.capEx = capEx;
    this.capGn = capGn;
    this.limitRnD = limitRnD;
  }
  
  void draw(int x, int y) {
    float scaler = 6; // 
    float sideEx = sqrt(capEx);
    float sideGn = sqrt(capEx + capGn); 
    float wScale = 1.25;
    float hScale = 1.5;
    
    fill(#00FF00, 100);
    rect(x, y, wScale*scaler*sideGn, hScale*scaler*sideGn);
    fill(255);
    stroke(#CCCCCC);
    strokeWeight(3);
    rect(x, y, wScale*scaler*sideEx, hScale*scaler*sideEx);
    noStroke();
    
    textAlign(LEFT);
    text("Site " + name, x, y - 10);
    textAlign(RIGHT);
    text("Greenfield " + capGn + " " + agileModel.WEIGHT_UNITS, x + wScale*scaler*sideGn - 5, y + hScale*scaler*sideGn - 10);
    textAlign(CENTER);
    fill(0);
    text("Existing", x + wScale*scaler*sideEx/2, y + hScale*scaler*sideEx/2 + 0);
    text(capEx + " " + agileModel.WEIGHT_UNITS, x + wScale*scaler*sideEx/2, y + hScale*scaler*sideEx/2 + 15);

  }
  
}

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
  
  void draw(int x, int y, String type) {
    int scaler = 4;
    fill(255);
    rect(x + 155, y, scaler*capacity, 10);
    textAlign(LEFT);
    fill(255);
    text(capacity + " " + agileModel.WEIGHT_UNITS, x + 155 + scaler*capacity + 3, y + 9);
    if (type.equals("GMS")) {
      text(int(buildTime) + " " + agileModel.TIME_UNITS + ", " + int(buildCost/100000)/10.0 + agileModel.COST_UNITS, x, y + 19);
      text(int(repurpTime) + " " +agileModel.TIME_UNITS + ", " + int(repurpCost/100000)/10.0 + agileModel.COST_UNITS, x + 80, y + 19);
    } else {
      text(int(repurpTime) + " " +agileModel.TIME_UNITS + ", " + int(repurpCost/100000)/10.0 + agileModel.COST_UNITS, x + 80, y + 19);
    }
    for (int i=0; i< labor.size(); i++) {
      if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(0,0) )) {
        fill(#FF0000);
      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(1,0) )) {
        fill(#00FF00);
      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(2,0) )) {
        fill(#0000FF);
      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(3,0) )) {
        fill(#FFFF00);
      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(4,0) )) {
        fill(#FF00FF);
      } else {
        fill(#00FFFF);
      }
      ellipse(x +157 + i*6, y + 20, 3, 10);
    }
  }
}

// A human being involved in the production process
class Person {
  
  // Name of Role (i.e. "Operator")
  String name;
  
  float shifts; // per time
  
  float cost; // per shift
  
  // Basic Constructor
  Person() {}
  
  // The Class Constructor
  Person(String name, float shifts, float cost) {
    this.name = name;
    this.shifts = shifts;
    this.cost = cost;
  }
}
