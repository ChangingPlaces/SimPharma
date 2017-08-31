ScoreSet performance, prediction;

class ScoreSet {
  
  // Each element is one time-specific "turn" of an OutputSet
  ArrayList<float[]> scores;
  
  // Uses first N outputs in output list only. Increase/decrease to activate/deactivate
  int numScores;
  
  String[] name, unit;
  float[] max;
  
  ScoreSet(int numScores, String[] name, float[] max, String[] unit) {
    scores = new ArrayList<float[]>();
    this.numScores = numScores;
    this.name = name;
    this.max = max;
    this.unit = unit;
  }
  
  void randomOutputs() {
    scores.clear();
    
    float[] o;
    for (int i=0; i<NUM_INTERVALS; i++) {
      o = new float[numScores];
      for(int j=0; j<numScores; j++) {
        o[j] = 0.9/(j+1) * (i+1)/20.0 + random(-0.1, 0.1);
      }
      scores.add(o);
    }
    
    // Set KPI Radar to Last Available Output array
    o = scores.get(scores.size() - 1);
    
    for (int i=0; i<numScores; i++) {
      radar.setScore(i, o[i]);
    }
  }
  
  void flatOutputs() {
    scores.clear();
    
    float[] o;
    for (int i=0; i<NUM_INTERVALS; i++) {
      o = new float[numScores];
      for(int j=0; j<numScores; j++) {
        o[j] = max[j]*( 0.5 + random(-0.1, 0.1) );
      }
      scores.add(o);
    }
    
    // Set KPI Radar to Last Available Output array
    o = scores.get(scores.size() - 1);
    
    for (int i=0; i<numScores; i++) {
      radar.setScore(i, o[i]);
    }
  }
}
