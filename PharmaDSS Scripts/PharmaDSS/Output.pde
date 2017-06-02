ArrayList<float[]> outputs;

// Uses first N outputs in below list only. Increase to activate
int NUM_OUTPUTS = 3;

String[] outputNames = {
  "Capital\nExpenses",
  "Demand\nMet",
  "Security\nof Supply",
  "Cost of\nGoods",
  "Operating\nExpenses"
};

float[] outputMax = {
  20000000.0,
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
  // Ability to meet Demand
  outputs.get(turn)[1] = calcDemandMeetAbility();
  
  // Capital Expenditures
  outputs.get(turn)[0] = calcCAPEX();
  
  // Security of Supply
  outputs.get(turn)[2] = calcSecurity();
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

// Returns the operating expenses for the current turn
float calcOPEX() {
  return 0.0;
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
  return 0.0;
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
  return 0.5;
}
