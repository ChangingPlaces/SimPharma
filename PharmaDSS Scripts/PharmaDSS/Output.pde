ArrayList<float[]> outputs;

String[] outputNames = {
  "CAPEX",
  "OPEX",
  "COGs",
  "ATMDEM",
  "SECSUP"
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
  return 0.0;
}
