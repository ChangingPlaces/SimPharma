// A production unit that describes a socio-technical process for manufacturing a chemical entity at a site
class Build {

  // Name of Production Type (i.e. "Continuous Batch Hybrid")
  String name;

  //  Build/Repurpose  Size
  float capacity; 
  float production = 0.0;  // %capacity 0.0 - 1.0 being used for prodcution

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
  
  // flag determining if build's capital cost has already been scored
  boolean capEx_Logged = false;
  
  boolean editing = false;

  // Basic Constructor
  Build() {
    labor = new ArrayList<Person>();
  }

  // The Class Constructor
  Build(String name, float capacity, float buildCost, float buildTime, float repurpCost, float repurpTime, ArrayList<Person> labor, boolean editing) {
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
    
    capacity = agileModel.PROFILES.get(index).chipCapacity * agileModel.DAYS_PER_CHIP / 1000.0;
  }

  // Update Temporal aspects of build, such as age and construction progress
  void updateBuild() {
    age++;
    if (repurpose) {
      if (age > repurpTime) {
        built = true;
        repurpose = false;
      }
    } else if (age > buildTime) {
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
  
  void draw(int x, int y, int w, int h, String type, boolean selected) {

    // Draw Build Characteristics
    int scaler = 3;
    int jump;
    textAlign(LEFT);
    textSize(12);
    fill(textColor);
    
    // Draw "Chip" Image
    image(chip, x, y - 100 , w, 75);
    
    // Chip Throughput
    if (session.selectedProfile > -1) {
      int selP;
      if (gameMode) {
        selP = agileModel.activeProfiles.get(session.selectedProfile).ABSOLUTE_INDEX;
      } else {
        selP = session.selectedProfile;
      }
      float chipCap = agileModel.PROFILES.get(selP).chipCapacity;
      text("Production Capacity:" + int(chipCap) + " kg/day" + "\n" +
           "Profile: NCE " + (selP+1), x, y -140);
    } else {
      println("Error drawing NCE throughput. -1 array out of bounds.");
    }
    
//    text("Personnel: " , x, y - 115);
//    for (int i=0; i< labor.size (); i++) {
//      if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(0, 0) )) {
//        fill(#CC0000);
//      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(1, 0) )) {
//        fill(#00CC00);
//      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(2, 0) )) {
//        fill(#0000CC);
//      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(3, 0) )) {
//        fill(#CCCC00);
//      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(4, 0) )) {
//        fill(#CC00CC);
//      } else {
//        fill(#00CCCC);
//      }
//      ellipse(x + i*5 + 5, y - 105, 3, 10);
//    }
    
    jump = 0;
    fill(textColor);
    if (type.equals("GMS")) {
      text("Build Time: " + int(repurpTime) + " " + agileModel.TIME_UNITS, x, jump + y - 11);
      //text("Build Cost: " + int(buildCost/100000)/10.0 + "mil " + agileModel.COST_UNITS, x, jump + y +4);
      // This needs to actually represent sum of personnel costs
      text("Operational Cost: " + int(buildCost/1000000)/20.0 + "mil " + agileModel.COST_UNITS + "/yr", x, jump + y + 4); 
      //text("Repurpose Time: " + int(repurpTime) + " " +agileModel.TIME_UNITS, x, jump + y + 19);
      //text("Repurpose Cost: " + int(repurpCost/100000)/10.0 + agileModel.COST_UNITS, x, jump + y + 34);
    } else {
      //text("Repurpose Cost: " + int(repurpTime) + " " +agileModel.TIME_UNITS + ", " + int(repurpCost/100000)/10.0 + agileModel.COST_UNITS, x, jump + y - 11);
    }
    
    
    // Faux Slice Description (Probably need to make a slice class at one point)
    fill(textColor);
    text("Personnel: " , x, y + 100);
    for (int i=0; i< labor.size (); i++) {
      if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(0, 0) )) {
        fill(#CC0000);
      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(1, 0) )) {
        fill(#00CC00);
      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(2, 0) )) {
        fill(#0000CC);
      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(3, 0) )) {
        fill(#CCCC00);
      } else if (labor.get(i).name.equals(agileModel.LABOR_TYPES.getString(4, 0) )) {
        fill(#CC00CC);
      } else {
        fill(#00CCCC);
      }
      int mult = 1;
      for (int j=0; j<1; j++) ellipse(x + i*mult*5 + j*5 + 5, y + 110, 3, 10);
    }
    
    jump = 150;
    fill(textColor);
    if (type.equals("GMS")) {
      text("Build Time: " + 2 + " " + agileModel.TIME_UNITS, x, jump + y - 11);
      text("Build Cost: " + int(buildCost/100000)/10.0 + "mil " + agileModel.COST_UNITS, x, jump + y +4);
      // This needs to actually represent sum of personnel costs
      text("Operational Cost: " + int(buildCost/1000000)/10.0 + "mil " + agileModel.COST_UNITS + "/y", x, jump + y + 19); 
      //text("Repurpose Time: " + int(repurpTime) + " " +agileModel.TIME_UNITS, x, jump + y + 19);
      //text("Repurpose Cost: " + int(repurpCost/100000)/10.0 + agileModel.COST_UNITS, x, jump + y + 34);
    } else {
      //text("Repurpose Cost: " + int(repurpTime) + " " +agileModel.TIME_UNITS + ", " + int(repurpCost/100000)/10.0 + agileModel.COST_UNITS, x, jump + y - 11);
    }
  }
}

