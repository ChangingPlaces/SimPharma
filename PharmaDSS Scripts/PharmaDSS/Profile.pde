// Demand profile for a chemical entity (i.e. NCE)

float MAX_PROFILE_VALUE = 0;

class Profile {
  
  // Name of NCE Demand Profile
  String name; 
  
  // This static index should always refer to the profile's "ideal" state located in "MFG_System.PROFILES"
  int ABSOLUTE_INDEX;

  // Breif Descriptor of Profile (i.e. "Blockbuster" or "Never Manufactured")
  String summary;
  
  // Success/ Failure (due to clinical trail failure, competition enters market, etc)
  boolean success;
  boolean launched;
  
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
  float timeLaunch;
  
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
    launched = false;
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
    launched = false;
  }
  
  void calc() {
    // Based on Profile, compute the peak forecast demand
    peak();
    
    // Based on Profile, compute the date that forecast is first know based on N years advance notice (i.e. 5yr) MFG_System.LEAD_TIME
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
  
  // Based on Profile, compute the date that forecast is first know based on N years advance notice (i.e. 5yr) MFG_System.LEAD_TIME
  void lead() {
    timeLead = 0;
    for (int i=0; i<demandProfile.getColumnCount(); i++) {
      float value = demandProfile.getFloat(1, i);
      //println(value);
      if (value > 0) {
        timeLaunch = i;
        timeLead = i - agileModel.LEAD_TIME;
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
    float markerH = 1.00;
    float forecastScalerH = 2.0; // leaves room for actual demand to overshoot forecast
    scalerH = h/(forecastScalerH*demandPeak_F);
    scalerW = float(w)/demandProfile.getColumnCount();
    
    // Draw Profile Selection
    if (selected) {
      fill(HIGHLIGHT, 40);
      //stroke(HIGHLIGHT, 80);
      //strokeWeight(1);
      noStroke(); 
      rect(x - 15, y - h - 7, w + 30, h+18, 5);
      noStroke();
    }
    
    noStroke();
    
    // Time Bar
    if (!detail) {
      fill(#CCCCCC, 80);
      float begin = max(0, timeLead);
      float end = max(0, timeEnd);
      if (!gameMode) {
        rect(x + scalerW * begin, y - h, scalerW * (min(end, demandProfile.getColumnCount()) - begin), h);
      } else {
        rect(x + scalerW * begin, y - h, scalerW * (min(min(end, demandProfile.getColumnCount()), session.current.TURN) - begin), h);
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
      rect(x + scalerW * i +1, y - barF, scalerW - 1, barF);

      // If game is on, only shows actual demand bars for finished turns
      if (!gameMode || session.current.TURN > i) {
        fill(THEME, 150);
        rect(x + scalerW * i + 1, y - barA, scalerW - 1, barA);
      }
      
      // Draw Peak Forcast
      if (peakTime_F == demandProfile.getFloat(0, i)) {
        fill(textColor);
        ellipse(x + scalerW * (0.5+i), y - barF, 3, 3);
        fill(textColor);
        textAlign(CENTER);
        text(int(demandPeak_F/100)/10.0 + agileModel.WEIGHT_UNITS, x + scalerW * (0.5+i) + 1, y - barF - 5);
      }
      
      // Draw Details such as axis
      fill(textColor);
      textAlign(CENTER);
      if (detail && (i==0 || (i+1)%5 == 0)) {
        stroke(textColor);
        strokeWeight(1);
        line(x + scalerW * i + 0.5*scalerW, y, x + scalerW * i + 0.5*scalerW, y+3);
        noStroke();
        text((agileModel.YEAR_0+i), x + scalerW * (i+.5) + 1, y + 15);
      }
      
      // Draw Global Manufacturing Capacity
      if (gameMode) {
        noFill();
        if (i <= session.current.TURN) {
          stroke(textColor);
        } else {
          stroke(abs(textColor-100));
          cap = globalCap;
          capLast = globalCap;
        }
        strokeWeight(1.5);
        // Draw Vertical Line
        line(x + scalerW * (i-0), y - cap, x + scalerW * (i-0), y - capLast);
        // Draw Horizontal Line
        line(x + scalerW * (i-0), y - cap, x + scalerW * (i-0) + scalerW, y - cap);
        noStroke();
      }
    }
    
    // Draw Profile Name and Summary
    // Draw small year axis on last NCE only
    if (!detail) {
      fill(textColor);
      textAlign(LEFT);
      if (gameMode && timeEnd != session.current.TURN-1 && session.current.TURN != NUM_INTERVALS) {
        text(name, x, y + 10);
      } else {
        text(name + ", " + summary, x, y + 10);
      }
      if (axis) {
        textAlign(RIGHT);
        text(NUM_INTERVALS + " " + agileModel.TIME_UNITS, x + w, y + 10);
      }
    }
    
    // Lead Date
    if (timeLead >=0) {
      fill(#00CC00);
      rect(x + scalerW * timeLead - 3, y - markerH*h, 3, markerH*h);
      if (detail) {
        textAlign(CENTER);
        text("Ph.III", x + scalerW * timeLead - 3, y-markerH*h-5);
      }
    }

    // Launch Date
    if (timeLaunch >=0) {
      fill(#0000CC);
      rect(x + scalerW * timeLaunch - 3, y - markerH*h, 3, markerH*h);
      if (detail) {
        textAlign(CENTER);
        text("Launch", x + scalerW * timeLaunch - 3, y-markerH*h-5);
      }
    }
    
    // End Date
    if (!gameMode || session.current.TURN > timeEnd) {
      if (timeEnd >=0) {
        fill(#CC0000);
        rect(x + scalerW * timeEnd - 3, y - markerH*h, 3, markerH*h);
        if (detail) {
          textAlign(CENTER);
          text("End", x + scalerW * timeEnd - 3, y-markerH*h-5);
        }
      }
    }
    
    // Draw Time Details
    if (gameMode) {
      float barA = 0;
      float cap = 0;
      if (session.current.TURN > 0) {
        cap = demandProfile.getFloat(2, session.current.TURN-1);
        barA = scalerH * cap;
      }
      fill(abs(textColor - 50));
      float X, Y;
      if (detail) {
        Y = y - barA;
      } else {
        Y = y - h;
      }
      X = x + scalerW * (min(demandProfile.getColumnCount(), session.current.TURN)) - 3;
      if (detail) {
        rect(X, Y, 4, max(3, barA) );
      } else {
        if (session.current.TURN != timeLead) rect(X, Y, 3, h );
      }
      if (detail) {
        fill(abs(textColor - 150));
        rect(X+1, y, 2, 35);
        fill(textColor);
        textAlign(LEFT);
        text(int(cap/100)/10.0 + agileModel.WEIGHT_UNITS, X, Y-5);
        textAlign(CENTER);
        text((agileModel.YEAR_0 + session.current.TURN), X, y + MARGIN);
      }
    }
    
    // Y-Axis for Large-scale graphic
    if (detail) {
      unit = demandPeak_F/3;
      stroke(textColor, 20);
      strokeWeight(1);
      for (int i=0; i<=int(forecastScalerH*demandPeak_F/unit); i++) {
        line(x, y - scalerH*i*unit, x+w, y - scalerH*i*unit);
        fill(textColor, 50);
        textAlign(RIGHT);
        text(i*int(unit/100)/10.0 + agileModel.WEIGHT_UNITS, x + w + 35, y - scalerH*(i-0.25)*unit);
      }
    }
  } 
}
