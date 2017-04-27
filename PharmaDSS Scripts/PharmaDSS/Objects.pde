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
