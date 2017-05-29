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

// Regenerate Game
void regenerateGame() {
  
  boolean interrupt = false;;
  
  // Cannot reset game while in active game mode
  if (gameMode) {
    interrupt = true;
    gameMode = false;
  }
  
  // Initiate MFG_System and Objects
  agileModel = new MFG_System();
  //Initiate Game
  loadModel_XLS(agileModel, "Agile Network Model v7_XLS.xls"); 
  
  session = new Game();
  // Turns game back on if interrupted so god mode is never seen
  if (interrupt) {
    gameMode = true;
  }
  
  // Generate New Basins for Sites
  generateBasins();
  
  //resets Scores for debugging
  for (int i=0; i<kpi.nRadar; i++) {
    kpi.setScore(i, random(1.0));
  }
}

// Returns an array of integers (0 - amt) but randomized.
// For example, if amt = 10, outputs: {2, 6, 9, 7, 0, 8, 5, 1, 3, 4}

int[] randomIndex(int amt) {
  int[] list = new int[amt];
  
  //sets all values to -1
  for (int i=0; i<amt; i++) list[i] = -1;
  
  int random;
  int allocated = 0;
  while(allocated < amt) {
    random = int(random(0, amt));
    if (random < 0 || random >= amt) random = 0; // checks in bounds
    if (list[random] == -1) {
      list[random] = allocated;
      allocated ++;
    }
  }
  return list;
}
