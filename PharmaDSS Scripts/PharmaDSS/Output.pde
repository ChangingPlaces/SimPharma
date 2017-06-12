ArrayList<float[]> outputs;

// Uses first N outputs in below list only. Increase to activate
int NUM_OUTPUTS = 5;

String[] outputNames = {
  "Capital\nExpenses",
  "Demand\nMet",
  "Security\nof Supply",
  "Cost of\nGoods",
  "Operating\nExpenses"
};

float[] outputMax = {
  200000000.0,
  1.0,
  1.0,
  1.0,
  1.0
};

String[] outputUnits = {
  "mil GBP",
  "%",
  "%",
  "mil GBP",
  "mil GBP"
};

void initOutputs() {
  for (int i=0; i<NUM_OUTPUTS; i++) {
    outputs = new ArrayList<float[]>();
  }
}

void calcOutputs(int turn) {
  
  if (outputs.get(turn).length > 0) {
    // Capital Expenditures
    outputs.get(turn)[0] = calcCAPEX();
  }
  
  if (outputs.get(turn).length > 1) {
    // Ability to meet Demand
    outputs.get(turn)[1] = calcDemandMeetAbility();
  }
  
  if (outputs.get(turn).length > 2) {
    // Security of Supply
    outputs.get(turn)[2] = calcSecurity();
  }
  
  if (outputs.get(turn).length > 3) {
    // Operating Expenditures
    outputs.get(turn)[3] = calcOPEX();
  }
  
  if (outputs.get(turn).length > 4) {
    // Cost of Goods
    outputs.get(turn)[4] = calcCOGs();
  }
}

void randomOutputs() {
  outputs.clear();
  
  float[] o;
  for (int i=0; i<NUM_INTERVALS; i++) {
    o = new float[NUM_OUTPUTS];
    for(int j=0; j<NUM_OUTPUTS; j++) {
      o[j] = 0.9/(j+1) * (i+1)/20.0 + random(-0.1, 0.1);
    }
    outputs.add(o);
  }
  
  // Set KPI Radar to Last Available Output array
  o = outputs.get(outputs.size() - 1);
  
  for (int i=0; i<NUM_OUTPUTS; i++) {
    kpi.setScore(i, o[i]);
  }
}

void flatOutputs() {
  outputs.clear();
  
  float[] o;
  for (int i=0; i<NUM_INTERVALS; i++) {
    o = new float[NUM_OUTPUTS];
    for(int j=0; j<NUM_OUTPUTS; j++) {
      o[j] = 1.0;
    }
    outputs.add(o);
  }
  
  // Set KPI Radar to Last Available Output array
  o = outputs.get(outputs.size() - 1);
  
  for (int i=0; i<NUM_OUTPUTS; i++) {
    kpi.setScore(i, o[i]);
  }
}

// Returns the capital expenses for the current turn
float calcCAPEX() {
  float expenses = 0.0;
  Build current;
  for (int i=0; i<agileModel.SITES.size(); i++) {
    for (int j=0; j<agileModel.SITES.get(i).siteBuild.size(); j++) {
      current = agileModel.SITES.get(i).siteBuild.get(j);
      if (!current.capEx_Logged) {
        expenses += current.buildCost;
        if (current.age != 0) current.capEx_Logged = false;
      }
    }
  }
  return expenses;
}

// Returns the Cost of Goods for the current turn
float calcCOGs() {
  return 0.2;
}

// Returns the operating expenses for the current turn
float calcOPEX() {
  return 0.7;
}

// Returns the % ability to meet demand for a given turn (0.0 - 1.0)
float calcDemandMeetAbility() {
  float percent; // 0.0 - 1.0
  float totDemandMet = 0;
  float totDemand = 0;
  
  float profileCapacity, profileActualDemand;
  
  for (int i=0; i<agileModel.activeProfiles.size(); i++) {
    profileCapacity = agileModel.activeProfiles.get(i).globalProductionLimit;
    profileActualDemand = agileModel.activeProfiles.get(i).demandProfile.getFloat(2, session.current.TURN-1);
    
    totDemandMet += min(profileCapacity, profileActualDemand);
    totDemand += profileActualDemand;
  }
  
  if (totDemand > 0) {
    percent = totDemandMet / totDemand;
  } else {
    percent = 1.0;
  }
  return percent;

}

// Returns the security of the supply chain network for a given turn
float calcSecurity() {

  // percent = balanceScore + supplyScore [%]
  float percent, balanceScore, supplyScore;
  
  balanceScore = 0.0;
  supplyScore = 0.0;
  
  // WEIGHTS SHOULD ADD UP TO 1.0
  float BALANCE_WEIGHT = 0.5;
  float SUPPLY_WEIGHT  = 0.5;

  // Magnitude of allowed value difference before score reaches 0% (1.0 for 100% deviance; 2.0 for 200% deviance, etc)
  float TOLERANCE = 2.0;
  // Ideal %Capacity Available in Network
  float IDEAL_NETWORK_BUFFER = 0.2;
  
  float[] siteCapacity;
  float totalCapacity, numBackup, bufferSupply;
  int scoreCount;
  Build current;
  
  // If Demand Exists; NCE's Score Counts toward Total
  scoreCount = 0;
  
  // Cycles through Each NCE
  for (int i=0; i<agileModel.activeProfiles.size(); i++) {

    numBackup = 0.0;
    
    // Calculates NCE Capacity at each site;
    siteCapacity = new float[agileModel.SITES.size()];
    for (int s=0; s<agileModel.SITES.size(); s++) {
      siteCapacity[s] = 0.0;
      for (int b=0; b<agileModel.SITES.get(s).siteBuild.size(); b++) {
        current = agileModel.SITES.get(s).siteBuild.get(b);
        if (current.PROFILE_INDEX == agileModel.activeProfiles.get(i).ABSOLUTE_INDEX) {
          siteCapacity[s] += current.capacity;
        }
      }
      
    }
    
    // Calculates Total NCE Capacity
    totalCapacity = 0.0;
    for (int s=0; s<agileModel.SITES.size(); s++) {
      totalCapacity += siteCapacity[s];
    }
    
    float demand = agileModel.activeProfiles.get(i).demandProfile.getFloat(2, min(session.current.TURN, NUM_INTERVALS-1) );
    demand /= 1000.0; // units of kiloTons
    
    // Calaculates normalized balance and supply scores and adds them to total
    if ( demand > 0) { // Only scores if demand exists
      // If Demand Exists; NCE's Score Counts toward Total
      scoreCount ++;
    
      // Determines how many "backup" sites there are
      if (agileModel.SITES.size() == 1) {
        // Scores Perfect if only one site
        numBackup = 1.0;
      } else {
        // assigns "1" if capacity exists at site
        for (int s=0; s<agileModel.SITES.size(); s++) {
          if (siteCapacity[s] > 0.0) {
            numBackup += 1.0;
          }
        }
      }
      
      // normalizes balance/backup to a score 0.0 - 1.0;
      if (agileModel.SITES.size() > 1) {
        numBackup -= 1.0; // Eliminates effect of first site
        numBackup /= (agileModel.SITES.size() - 1);
        if (numBackup < 0.0) numBackup = 0.0;
      }
      
      // Adds the current NCE's balance score to the overall
      balanceScore += agileModel.activeProfiles.get(i).weightBalance * numBackup;
      

      // Calculate Normalized supply score and add it to total
      float sup = 0;
      bufferSupply = (1.0 + IDEAL_NETWORK_BUFFER) * demand / totalCapacity;
      if (totalCapacity == 0) {
        sup = 0.0;
      } else if (bufferSupply > 0 && bufferSupply <= 1.0) {
        sup = 1.0;
      } else if (bufferSupply > 1.0) {
        sup = TOLERANCE - bufferSupply;
        if (sup < 0.0) sup = 0;
      }
      supplyScore += agileModel.activeProfiles.get(i).weightSupply * sup;
      
    }
    
  }
  
  // Aggregate scores
  balanceScore /= scoreCount;
  supplyScore  /= scoreCount;
  percent = BALANCE_WEIGHT * balanceScore + SUPPLY_WEIGHT * supplyScore;
  
  return percent;
}
