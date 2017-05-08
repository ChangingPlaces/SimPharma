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
  
  // Lead Date
  float timeLead;
  
  // End Date (date when demand drops to zero)
  float timeEnd;
  
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
  
  void calc() {
    peak();
    lead();
    end();
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
  
  void lead() {
    timeLead = 0;
    for (int i=0; i<demandProfile.getColumnCount(); i++) {
      float value = demandProfile.getFloat(1, i);
      //println(value);
      if (value > 0) {
        timeLead = max(0, i - agileModel.LEAD_TIME);
        break;
      }
    }
  }
  
  void end() {
    timeEnd = Float.POSITIVE_INFINITY;
    boolean viable = false;
    float current, previous;
    for (int i=1; i<demandProfile.getColumnCount(); i++) {
      current = demandProfile.getFloat(2, i);
      previous = demandProfile.getFloat(2, i-1);
      if (current == 0 && previous > 0) {
        timeEnd = i;
        break;
      }
      if (current > 0) {
        viable = true;
      }
    }
    if (!viable) timeEnd = timeLead;
  }
  
  void draw(int x, int y, int w, int h, boolean axis, boolean selected) {
    float MAX_VALUE = 20000.0;
    float scalerH = h/MAX_VALUE;
    float scalerW = float(w)/demandProfile.getColumnCount();
    
    noStroke();
    
    // Time Bar
    if (textColor == 255) {
      fill(textColor, 100);
    } else {
      fill(#00CC00, 40);
    }
    if (!gameMode) {
      rect(x + scalerW * timeLead, y - h, scalerW * (min(timeEnd, demandProfile.getColumnCount()) - timeLead), h);
    } else {
      rect(x + scalerW * timeLead, y - h, scalerW * (min(min(timeEnd, demandProfile.getColumnCount()), session.current.TURN) - timeLead), h);
    }
    
    for (int i=0; i<demandProfile.getColumnCount(); i++) {
      float barF = scalerH * demandProfile.getFloat(1, i); // Forecast Demand
      float barA = scalerH * demandProfile.getFloat(2, i); // Actual Demand
      noStroke();
      
      fill(abs(textColor-200));
      rect(x + scalerW * i +1, y - barF, scalerW - 2, barF);
      
      if (peakTime == demandProfile.getFloat(0, i)) {
        fill(textColor);
        ellipse(x + scalerW * (0.5+i), y - barF, 3, 3);
        fill(textColor);
        textAlign(CENTER);
        text(int(demandPeak/100)/10.0 + "k " + agileModel.WEIGHT_UNITS, x + scalerW * (0.5+i) + 1, y - barF - 5);
      }
      
      // If game is on, only shows actual demand for finished turns
      if (!gameMode || session.current.TURN > i) {
        fill(#0000FF, 200);
        rect(x + scalerW * i + 1, y - barA, scalerW - 2, barA);
      }
    }
    fill(textColor);
    textAlign(LEFT);
    text(name + ", " + summary, x, y + 15);
    if (axis) {
      textAlign(RIGHT);
      text(NUM_INTERVALS + " " + agileModel.TIME_UNITS, x + w, y + 15);
    }
    
    // Lead Date
    fill(#00CC00);
    rect(x + scalerW * timeLead - 3, y - h, 6, h);
    
    // End Date
    if (!gameMode || session.current.TURN > timeEnd) {
      fill(#CC0000);
      rect(x + scalerW * timeEnd - 3, y - h, 6, h);
    }
    
    // Draw Profile Selection
    if (selected) {
      noFill();
      //stroke(255 - background, 100);
      stroke(#CCCC00, 100);
      strokeWeight(4);
      rect(x - 20, y - 2.1*h, w + 40, 3.0*h, 5);
      noStroke();
    }
  } 
}
