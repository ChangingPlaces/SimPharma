 /*  GSK Manufacturing & Supply Chain Score Calculation Methods/Functions (June 4, 2017)
  *  
  *  All are ideally normalized to a percentage of an "ideal" actor.
  *  Theoretically, we need a different "ideal" actor algorithm for each Performance metric.
  *
  *  CAPEX ->  Percentage is relational to (buildCost + repurp Cost):
  *
  *  OPEX -> Percentgage is relational to (personnel cost)
  *
  *  COGs -> Related to site production cost
  *
  *  Ability to Meet Demand -> Weight each NCE the same regardless of total tonnage
  *
  *  Security of Supply; Composite of Site Security and Capacity Security
  *  Weight each NCE the same regardless of total tonnage
  *  50% - Spread between sites? (deviation from equal / half ... i.e. 1t and 4t at site 1 and two repectively has deviation of 1.5/2.5
  *  50% - Assume that 100% Security is ability to meet demand if actual demand doubles in a given year.
  *
  */

void initScores() {
  
  // Uses first N outputs in below list only. Increase to activate
  int NUM_OUTPUTS = 5;

  String[] outputNames = {
    "Capital\nExpenses",
    "Cost of\nGoods",
    "Operating\nExpenses",
    "Demand\nMet",
    "Security\nof Supply"
  };
  
  float[] outputMax = {
    250000000.0,
      2000000.0,
     20000000.0,
            1.0,
            1.0
  };
  
  String[] outputUnits = {
    "mil GBP",
    "mil GBP",
    "mil GBP",
    "%",
    "%"
  };

  performance = new ScoreSet(NUM_OUTPUTS, outputNames, outputMax, outputUnits);
}

void calcOutputs(int turn) {
  
  if (performance.scores.get(turn).length > 0) {
    // Capital Expenditures
    performance.scores.get(turn)[0] = calcCAPEX();
  }
  
  if (performance.scores.get(turn).length > 1) {
    // Ability to meet Demand
    performance.scores.get(turn)[3] = calcDemandMeetAbility();
  }
  
  if (performance.scores.get(turn).length > 2) {
    // Security of Supply
    performance.scores.get(turn)[4] = calcSecurity();
  }
  
  if (performance.scores.get(turn).length > 3) {
    // Operating Expenditures
    performance.scores.get(turn)[1] = calcCOGs();
  }
  
  if (performance.scores.get(turn).length > 4) {
    // Cost of Goods
    performance.scores.get(turn)[2] = calcOPEX();
  }
  
}

// Returns the capital expenses for the current turn
float calcCAPEX() {
  float expenses = 0.0;
  Build current;
  for (int i=0; i<agileModel.SITES.size(); i++) {
    for (int j=0; j<agileModel.SITES.get(i).siteBuild.size(); j++) {
      current = agileModel.SITES.get(i).siteBuild.get(j);
      if (!current.capEx_Logged) { // Ensures capital cost for build is only counted once
        expenses += current.buildCost;
        if (current.age != 0) current.capEx_Logged = false;
      }
    }
  }
  return expenses;
}

// Returns the Operating Expenses for the current turn
float calcOPEX() {
  float expenses = 0.0;
  Build current;
  for (int i=0; i<agileModel.SITES.size(); i++) {
    for (int j=0; j<agileModel.SITES.get(i).siteBuild.size(); j++) {
      current = agileModel.SITES.get(i).siteBuild.get(j);
      if (current.built) {
        for (int l=0; l<current.labor.size(); l++) {
          expenses += current.labor.get(l).cost;
        }
      }
    }
  }
  return expenses;
}

// Returns the cost of goods for the current turn
float calcCOGs() {
  float expenses = 0.0;
  Build current;
  Profile nce;
  for (int i=0; i<agileModel.SITES.size(); i++) {
    for (int j=0; j<agileModel.SITES.get(i).siteBuild.size(); j++) {
      current = agileModel.SITES.get(i).siteBuild.get(j);
      nce = agileModel.PROFILES.get(current.PROFILE_INDEX);
      if (current.built) {
        expenses += current.production * current.capacity * nce.productionCost.get(i);
      }
    }
  }
  return expenses;
}

// Returns the % ability to meet demand for a given turn (0.0 - 1.0)
float calcDemandMeetAbility() {
  float percent; // 0.0 - 1.0
  float totDemandMet = 0;
  float totDemand = 0;
  int scoreCount = 0;
  
  float profileCapacity, profileActualDemand;
  
  percent = 0.0;
  
  for (int i=0; i<agileModel.activeProfiles.size(); i++) {
    
    profileCapacity = agileModel.activeProfiles.get(i).globalProductionLimit;
    profileActualDemand = agileModel.activeProfiles.get(i).demandProfile.getFloat(2, session.current.TURN-1);
    
    if (profileActualDemand > 0) {
      scoreCount++;
      totDemandMet += min(profileCapacity, profileActualDemand);
      totDemand += profileActualDemand;
      percent += min(profileCapacity, profileActualDemand) / profileActualDemand;
    }
  }
  
  if (totDemand > 0) {
    //percent = totDemandMet / totDemand;
    percent /= scoreCount;
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

// Based on Capacity (tons), calculates build cost for a facility in GBP
float buildCost(float capacity) {
  return 1000000 * ( 1.4 * (capacity - 0.5) + 2.0 ); //GBP
}

// Based on Capacity (tons), calculates build time for a facility in years
float buildTime(float capacity) {
  if (capacity <= 10) {
    return 3; //yr
  } else if (capacity <= 20) {
    return 4; //yr
  } else {
    return 5; //yr
  }
}
