// Demand profile for a chemical entity (i.e. NCE)
class Profile {
  
  // Name of NCE Demand Profile
  String name; 
  
  // This static index should always refer to the profile's "ideal" state located in "System.PROFILES"
  int ABSOLUTE_INDEX;

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
  Profile(int INDEX) {
    productionCost = new ArrayList<Float>();
    demandProfile = new Table();
    ABSOLUTE_INDEX = INDEX;
  }
  
  // The Class Constructor
  Profile(String name, String summary, boolean success, String timeStart, float recoveries, ArrayList<Float> productionCost, Table demandProfile, int INDEX) {
    this.name = name;
    this.summary = summary;
    this.success = success;
    this.timeStart = timeStart;
    this.productionCost = productionCost;
    this.demandProfile = demandProfile;
    ABSOLUTE_INDEX = INDEX;
  }
  
  void calc() {
    // Based on Profile, compute the peak forecast demand
    peak();
    
    // Based on Profile, compute the date that forecast is first know based on N years advance notice (i.e. 5yr) System.LEAD_TIME
    lead();
    
    // Based on Profile, compute the date that NCE Profile "terminates"
    end();
  }
  
  // Based on Profile, compute the peak forecast demand
  void peak() {
    demandPeak = 0;
    for (int i=0; i<demandProfile.getColumnCount(); i++) {
      if (demandPeak < demandProfile.getFloat(1, i) ) {
        demandPeak = demandProfile.getFloat(1, i);
        peakTime = demandProfile.getFloat(0, i);
      }
    }
  }
  
  // Based on Profile, compute the date that forecast is first know based on N years advance notice (i.e. 5yr) System.LEAD_TIME
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
  
  // Based on Profile, compute the date that NCE Profile "terminates" (i.e. is no longer viable)
  void end() {
    timeEnd = Float.POSITIVE_INFINITY;
    boolean viable = false;
    float current, previous;
    for (int i=1; i<demandProfile.getColumnCount(); i++) {
      current = demandProfile.getFloat(2, i);
      previous = demandProfile.getFloat(2, i-1);
      // If actual demand reaches zero, profile is no longer viable
      if (current == 0 && previous > 0) {
        timeEnd = i;
        break;
      }
      // If actual demand is still above zero, keep viable
      if (current > 0) {
        viable = true;
      }
    }
    if (!viable) timeEnd = timeLead;
  }
  
  void draw(int x, int y, int w, int h, boolean axis, boolean selected, boolean detail) {
    float MAX_VALUE = 30000.0;
    float unit = 5000;
    float scalerH = h/MAX_VALUE;
    float scalerW = float(w)/demandProfile.getColumnCount();
    
    noStroke();
    
    // Time Bar
    if (!detail) {
      if (timeEnd < session.current.TURN || (!gameMode && timeEnd < NUM_INTERVALS) ) {
        fill(#CC0000, 40);
      } else {
        fill(#00CC00, 40);
      }
      if (!gameMode) {
        rect(x + scalerW * timeLead, y - h, scalerW * (min(timeEnd, demandProfile.getColumnCount()) - timeLead), h);
      } else {
        rect(x + scalerW * timeLead, y - h, scalerW * (min(min(timeEnd, demandProfile.getColumnCount()), session.current.TURN) - timeLead), h);
      }
    }
    
    for (int i=0; i<demandProfile.getColumnCount(); i++) {
      float barF = scalerH * demandProfile.getFloat(1, i); // Forecast Demand
      float barA = scalerH * demandProfile.getFloat(2, i); // Actual Demand
      noStroke();
      
      // Draw Forecast Demand Bars
      fill(abs(textColor-200));
      rect(x + scalerW * i +1, y - barF, scalerW - 2, barF);

      // If game is on, only shows actual demand bars for finished turns
      if (!gameMode || session.current.TURN > i) {
        fill(#0000FF, 100);
        rect(x + scalerW * i + 1, y - barA, scalerW - 2, barA);
      }
      
      // Draw Peak Forcast
      if (peakTime == demandProfile.getFloat(0, i)) {
        fill(textColor);
        ellipse(x + scalerW * (0.5+i), y - barF, 3, 3);
        fill(textColor);
        textAlign(CENTER);
        text(int(demandPeak/100)/10.0 + "k " + agileModel.WEIGHT_UNITS, x + scalerW * (0.5+i) + 1, y - barF - 5);
      }
      
      // Draw Details such as axis
      fill(textColor);
      textAlign(CENTER);
      if (detail) {
        text(i+1 + " yr", x + scalerW * (i+.5) + 1, y + 15);
      }
    }
    
    // Draw small year axis on last NCE only
    if (!detail) {
      fill(textColor);
      textAlign(LEFT);
      text(name + ", " + summary, x, y + 15);
      if (axis) {
        textAlign(RIGHT);
        text(NUM_INTERVALS + " " + agileModel.TIME_UNITS, x + w, y + 15);
      }
    }
    
    // Lead Date
    fill(#00CC00);
    rect(x + scalerW * timeLead - 3, y - h, 3, h);
    if (detail) {
      textAlign(CENTER);
      text("T=" + int(timeLead), x + scalerW * timeLead - 3, y-h-5);
    }
    
    // End Date
    if (!gameMode || session.current.TURN > timeEnd) {
      fill(#CC0000);
      rect(x + scalerW * timeEnd - 3, y-h, 3, h);
      if (detail) {
        textAlign(CENTER);
        text("T=" + int(timeEnd), x + scalerW * timeEnd - 3, y-h-5);
      }
    }
    
    // Draw Profile Selection
    if (selected) {
      noFill();
      //stroke(255 - background, 100);
      stroke(#CCCC00, 100);
      strokeWeight(4);
      rect(x - 20, y - 1.75*h, w + 40, 3.0*h, 5);
      noStroke();
    }
    
    // Draw Time Details
    if (detail && gameMode) {
      fill(textColor);
      float X, Y;
      Y = y - h;
      X = x + scalerW * (min(demandProfile.getColumnCount(), session.current.TURN)) - 3;
      rect(X, Y, 6, h);
      textAlign(CENTER);
      text("T=" + session.current.TURN, X, Y-5);
    }
    
    // Y-Axis for Large-scale graphic
    if (detail) {
      stroke(textColor, 20);
      strokeWeight(1);
      for (int i=0; i<=int(MAX_VALUE/unit); i++) {
        line(x, y - scalerH*i*unit, x+w, y - scalerH*i*unit);
        fill(textColor, 50);
//        textAlign(RIGHT);
//        text(i*unit/1000 + "k " + agileModel.WEIGHT_UNITS, x - 10, y - scalerH*(i-0.5)*unit);
        textAlign(LEFT);
        text(i*unit/1000 + "k " + agileModel.WEIGHT_UNITS, x + w + 5, y - scalerH*(i-0.25)*unit);
      }
    }
  } 
}
