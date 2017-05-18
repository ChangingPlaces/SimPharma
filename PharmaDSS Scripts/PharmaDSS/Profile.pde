// Demand profile for a chemical entity (i.e. NCE)

float MAX_PROFILE_VALUE = 0;

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
  
  // Peak Demands (Forecast and Actual)
  float demandPeak_F, demandPeak_A; // calculate from demandProfile
  float peakTime_F, peakTime_A;
  
  // Peak Actual Demand
  
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

  //  Columns of consecutive, discrete time intervals describing:
  //  - Time
  //  - Actual Capacity (weight per time)
  //  - Ideal Capacity (weight per time)
  Table capacityProfile;

  
  // Basic Constructor
  Profile(int INDEX) {
    productionCost = new ArrayList<Float>();
    demandProfile = new Table();
    ABSOLUTE_INDEX = INDEX;
  }
  
  ArrayList<Float> localProductionLimit;
  float globalProductionLimit;
  
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
    
    //Initialize Table for holding capacity values
    initCapacityProfile();
  }
  
  // Given an existing profile, rescales all demand values (forecast and actual) according to a new peak value
  void setPeak(float newPeak) {
    float scaler = newPeak/demandPeak_F;
    for (int i=0; i<demandProfile.getColumnCount(); i++) {
      demandProfile.setFloat(1, i, demandProfile.getFloat(1, i) * scaler); // Forecast
      demandProfile.setFloat(2, i, demandProfile.getFloat(2, i) * scaler); // Actual
    }
  }
  
  // Based on Profile, compute the peak forecast demand
  void peak() {
    demandPeak_F = 0;
    demandPeak_A = 0;
    float value_F, value_A, time;
    for (int i=0; i<demandProfile.getColumnCount(); i++) {
      time = demandProfile.getFloat(0, i);
      value_F = demandProfile.getFloat(1, i); // Forecast
      value_A = demandProfile.getFloat(2, i); // Actual
      if (demandPeak_F < value_F ) {
        demandPeak_F = value_F;
        peakTime_F = time;
        
        // Sets global max profile value
        if (MAX_PROFILE_VALUE < value_F) MAX_PROFILE_VALUE = value_F;
      }
      if (demandPeak_A < value_A ) {
        demandPeak_A = value_A;
        peakTime_A = time;
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
  
  void initCapacityProfile() {
    capacityProfile = new Table();
    capacityProfile.addRow(); //Time
    capacityProfile.addRow(); //Capacity (Actual)
    for (int i=0; i<demandProfile.getColumnCount(); i++) {
      capacityProfile.addColumn();
      capacityProfile.setFloat(0, i, demandProfile.getFloat(0,i)); //Time
      capacityProfile.setFloat(1, i, 0.0); // Capacity
    }
  }
  
  void calcProduction(ArrayList<Site> factories) {
    
    localProductionLimit = new ArrayList<Float>();
    globalProductionLimit = 0;
    int numSites, numBuilds;
    Build current;
    
    numSites = factories.size();
    for (int i=0; i<numSites; i++) {
      localProductionLimit.add(0.0);
      numBuilds = factories.get(i).siteBuild.size();
      for (int j=0; j<numBuilds; j++) {
        current = factories.get(i).siteBuild.get(j);
        if (current.built) {
          if (current.PROFILE_INDEX == ABSOLUTE_INDEX) {
            localProductionLimit.set(i, localProductionLimit.get(i) + current.capacity);
          }
        }
      }
      globalProductionLimit += 1000*localProductionLimit.get(i);
    }
    capacityProfile.setFloat(1, session.current.TURN, globalProductionLimit);
  }
  
  void draw(int x, int y, int w, int h, boolean axis, boolean selected, boolean detail) {
    float unit = 5000;
    float scalerH, scalerW;
    float markerH = 1.25;
    float forecastScalerH = 1.5; // leaves room for actual demand to overshoot forecast
    if (detail) {
      scalerH = h/(forecastScalerH*demandPeak_F);
    } else {
      scalerH = h/MAX_PROFILE_VALUE;
    }
    scalerW = float(w)/demandProfile.getColumnCount();
    
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
      float barF, barA, cap, capLast, globalCap;
      barF = scalerH * demandProfile.getFloat(1, i); // Forecast Demand
      barA = scalerH * demandProfile.getFloat(2, i); // Actual Demand
      cap = scalerH * capacityProfile.getFloat(1, i); // Actual Global Production Capacity
      globalCap = scalerH * globalProductionLimit; // Actual Global Production Capacity
      if (i==0) {
        capLast = 0;
      } else {
        capLast = scalerH * capacityProfile.getFloat(1, i-1); 
      }
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
      if (peakTime_F == demandProfile.getFloat(0, i)) {
        fill(textColor);
        ellipse(x + scalerW * (0.5+i), y - barF, 3, 3);
        fill(textColor);
        textAlign(CENTER);
        text(int(demandPeak_F/100)/10.0 + "k " + agileModel.WEIGHT_UNITS, x + scalerW * (0.5+i) + 1, y - barF - 5);
      }
      
      // Draw Details such as axis
      fill(textColor);
      textAlign(CENTER);
      if (detail && (i==0 || (i+1)%5 == 0)) {
        stroke(textColor);
        strokeWeight(1);
        line(x + scalerW * i + 0.5*scalerW, y, x + scalerW * i + 0.5*scalerW, y+3);
        noStroke();
        text(i+1 + " yr", x + scalerW * (i+.5) + 1, y + 15);
      }
      
      // Draw Global Manufacturing Capacity
      if (gameMode) {
        noFill();
        if (i <= session.current.TURN) {
          stroke(textColor);
        } else {
          stroke(textColor, 50);
          cap = globalCap;
          capLast = globalCap;
        }
        strokeWeight(2);
        // Draw Vertical Line
        line(x + scalerW * (i-0) +1, y - cap, x + scalerW * (i-0) +1, y - capLast);
        // Draw Horizontal Line
        line(x + scalerW * (i-0) +1, y - cap, x + scalerW * (i-0) + 1 + scalerW - 2, y - cap);
        noStroke();
      }
    }
    
    // Draw Profile Name and Summary
    // Draw small year axis on last NCE only
    if (!detail) {
      fill(textColor);
      textAlign(LEFT);
      if (gameMode && timeEnd != session.current.TURN-1 && session.current.TURN != NUM_INTERVALS) {
        text(name, x, y + 15);
      } else {
        text(name + ", " + summary, x, y + 15);
      }
      if (axis) {
        textAlign(RIGHT);
        text(NUM_INTERVALS + " " + agileModel.TIME_UNITS, x + w, y + 15);
      }
    }
    
    // Lead Date
    fill(#00CC00);
    rect(x + scalerW * timeLead - 3, y - markerH*h, 3, markerH*h);
    if (detail) {
      textAlign(CENTER);
      text("Ph.III, T=" + int(timeLead), x + scalerW * timeLead - 3, y-markerH*h-5);
    }
    
    // End Date
    if (!gameMode || session.current.TURN > timeEnd) {
      fill(#CC0000);
      rect(x + scalerW * timeEnd - 3, y - markerH*h, 3, markerH*h);
      if (detail) {
        textAlign(CENTER);
        text("T=" + int(timeEnd), x + scalerW * timeEnd - 3, y-markerH*h-5);
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
    if (gameMode) {
      float barA = 0;
      float cap = 0;
      if (session.current.TURN > 0) {
        cap = demandProfile.getFloat(2, session.current.TURN-1);
        barA = scalerH * cap;
      }
      fill(textColor, 50);
      float X, Y;
      if (detail) {
        Y = y - barA;
      } else {
        Y = y - h;
      }
      X = x + scalerW * (min(demandProfile.getColumnCount(), session.current.TURN)) - 3;
      if (detail) {
        rect(X, Y, 3, max(3, barA) );
      } else {
        if (session.current.TURN != timeLead)
          rect(X, Y, 3, h );
      }
      if (detail) {
        fill(abs(textColor - 150));
        rect(X+1, y, 1, 25);
        fill(textColor);
        textAlign(LEFT);
        text(int(cap/100)/10.0 + agileModel.WEIGHT_UNITS, X, Y-5);
        textAlign(CENTER);
        text("Turn " + session.current.TURN, X, y + 40);
      }
    }
    
    // Y-Axis for Large-scale graphic
    if (detail) {
      unit = demandPeak_F/6;
      stroke(textColor, 20);
      strokeWeight(1);
      for (int i=0; i<=int(forecastScalerH*demandPeak_F/unit); i++) {
        line(x, y - scalerH*i*unit, x+w, y - scalerH*i*unit);
        fill(textColor, 50);
//        textAlign(RIGHT);
//        text(i*unit/1000 + "k " + agileModel.WEIGHT_UNITS, x - 10, y - scalerH*(i-0.5)*unit);
        textAlign(LEFT);
        text(i*int(unit/100)/10.0 + "k " + agileModel.WEIGHT_UNITS, x + w + 5, y - scalerH*(i-0.25)*unit);
      }
    }
  } 
}
