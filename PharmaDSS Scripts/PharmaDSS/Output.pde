ArrayList<float[]> outputs;

String[] outputNames = {
  "CAPEX",
  "OPEX",
  "COGs",
  "ATMDEM",
  "SECSUP"
};

float[] outputMax = {
  100.0,
  100.0,
  100.0,
  100.0,
  100.0
};

int NUM_OUTPUTS = outputNames.length;

void initOutputs() {
  for (int i=0; i<NUM_OUTPUTS; i++) {
    outputs = new ArrayList<float[]>();
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

// Returns the operating expenses for the current turn
float calcOPEX() {
  return 0.0;
}

// Returns the operating expenses for the current turn
float calcCAPEX() {
  return 0.0;
}

// Returns the Cost of Goods for the current turn
float calcCOGs() {
  return 0.0;
}

// Returns the security of the supply chain network for a given turn
float calcSecurity() {
  return 0.0;
}

// Returns the % ability to meet demand for a given turn
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
