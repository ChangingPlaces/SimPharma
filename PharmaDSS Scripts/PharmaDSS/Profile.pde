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
  float peakTime;
  
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
        peakTime = demandProfile.getFloat(0, i);
      }
    }
  }
  
  void draw(int x, int y, int w, int h, boolean axis) {
    float MAX_VALUE = 20000.0;
    float scalerH = h/MAX_VALUE;
    float scalerW = float(w)/demandProfile.getColumnCount();
    for (int i=0; i<demandProfile.getColumnCount(); i++) {
      float barF = scalerH * demandProfile.getFloat(1, i);
      float barA = scalerH * demandProfile.getFloat(2, i);
      noStroke();
      fill(textColor, 150);
      rect(x + scalerW * i +1, y - barF, scalerW - 2, barF);
      fill(#0000FF, 200);
      rect(x + scalerW * i + 1, y - barA, scalerW - 2, barA);
      if (peakTime == demandProfile.getFloat(0, i)) {
        fill(textColor);
        ellipse(x + scalerW * (0.5+i) + 1, y - barF, 3, 3);
        fill(textColor, 150);
        textAlign(CENTER);
        text(int(demandPeak/100)/10.0 + "k " + agileModel.WEIGHT_UNITS, x + scalerW * (0.5+i) + 1, y - barF - 5);
      }
    }
    fill(textColor);
    textAlign(LEFT);
    text(name + ", " + summary, x, y + 15);
    if (axis) {
      textAlign(RIGHT);
      text(NUM_INTERVALS + " " + agileModel.TIME_UNITS, x + w, y + 15);
    }
  }
}
