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
  
  // Initiate System and Objects
  agileModel = new System();
  //Initiate Game
  loadModel_XLS(agileModel, "Agile Network Model v7_XLS.xls"); 
  
  session = new Game();
  // Turns game back on if interrupted so god mode is never seen
  if (interrupt) {
    gameMode = true;
  }
  
  loop();
}
