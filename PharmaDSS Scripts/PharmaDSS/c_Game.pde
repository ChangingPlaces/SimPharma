boolean gameMode = true;

// Regenerate Game
void regenerateGame() {
  
  boolean interrupt = false;
  
  // Reset game if in game mode
  if (gameMode) {
    interrupt = true;
    gameMode = false;
  }
  
  // Initiate MFG_System and Objects
  agileModel = new MFG_System();
  //Initiate Game
  loadModel_XLS(agileModel, dataLocation);
  
  session = new Game();
  updateProfileCapacities();
  
  // Turns game back on if interrupted so god mode is never seen
  if (interrupt) {
    gameMode = true;
  }
  
  // Calculates Max Capacity Site
  agileModel.maxCapacity();
  
  // Generate New Basins for Sites
  mfg.resetCellTypes();
  generateBasins();
  
  //resets Scores
  performance.maxOutputs();
  prediction.maxOutputs();
  
  // Reset Table Pieces
  fauxPieces(2, tablePieceInput, 15);
}

// Game, Turn, Event classes help log and manage actions over the passage of time
// Games are made up of a series of Turns, and Turns are made up of 0 or more events that effect the system.
class Game {
  
  // turn element tracks the passage of time in discrete intervals
  // Units of Time are defined in the "MFG_System" as "TIME_UNITS"
  Turn current;
  ArrayList<Turn> turnLog;
  
  int selectedProfile;
  int selectedSite, selectedSiteBuild;
  int selectedBuild;
  
  int hoverProfile;
  int hoverSite, hoverSiteBuild;
  int hoverBuild;
  
  // Boolean to specify if continuous manufacturing technology is allowed
  boolean continuousMfG = false;
  
  Game() {
    current = new Turn(0);
    
    selectedProfile = 0;
    selectedSite = 0;
    selectedSiteBuild = 0;
    selectedBuild = 0;
    
    hoverProfile = 0;
    hoverSite = 0;
    hoverSiteBuild = 0;
    hoverBuild = 0;
    
    turnLog = new ArrayList<Turn>();
    tableHistory.clear();
    
    // Only adds profiles with 4 years advance forecast
    agileModel.activeProfiles.clear();
    populateProfiles();
    
    // Clear all user-defined builds from each site
    resetSites();
  }
  
  // Clear all user-defined builds from sites
  void resetSites() {
    
    // Clears Sites
    for (int i=0; i<agileModel.SITES.size(); i++) {
      agileModel.SITES.get(i).siteBuild.clear();
    }
    
    // Pre-Populates Sites with Build in Queue
//    for (int i=0; i<agileModel.activeProfiles.size(); i++) {
//      Event initialize = new Event("initialize", int(random(NUM_SITES-0.01)), int(random(agileModel.GMS_BUILDS.size()-0.01)), agileModel.activeProfiles.get(i).ABSOLUTE_INDEX);
//      current.event.add(initialize);
//    }
    
  }
  
  // End the turn and commit all events to the Log
  void execute() {
    
    // Lock User Input on table for game turn execution
    mfg.lockEdits();
    
    if (current.TURN < NUM_INTERVALS) {
      int[][][] input = new int[U_MAX][V_MAX][2];
      for (int u=0; u<U_MAX; u++) {
        for (int v=0; v<V_MAX; v++) {
          for (int i=0; i<2; i++) input[u][v][i] = tablePieceInput[u][v][i];
          mfg.blocker[u+4][v].update();
          if (input[u][v][0] == -1) mfg.inUse[u+4][v] = false;
        }
      }
      
      // Update Slice Construction Status
      if (enableSites) {
        if (mfg.inputArea.size() > 0) {
          for (int i=0; i<mfg.inputArea.size (); i++) {
            for (int j=0; j<mfg.inputArea.get(i).numSlices; j++) {
              
              if (mfg.inputArea.get(i).sliceTimer[j] > 0) {
                mfg.inputArea.get(i).sliceTimer[j] --;
              } else if (mfg.inputArea.get(i).sliceTimer[j] == 0) {
                mfg.inputArea.get(i).sliceBuilt[j] = true;
              }
              
              mfg.updateExisting();
            }
          }
        }
      }
      
      tableHistory.add(input);
      println("Table state logged #" + (tableHistory.size() - 1));
      turnLog.add(current);
      println("Turn " + current.TURN + " logged");
      
      current = new Turn(current.TURN + 1);
      
      // Only adds profiles to game within known Lead Time
      populateProfiles();
      //println("There are now " + agileModel.activeProfiles.size() + " Active Profiles.");
      
      // Updates the Status of builds on each site at end of each turn (age, etc)
      for (int i=0; i<agileModel.SITES.size(); i++) {
        agileModel.SITES.get(i).updateBuilds();
      }
      
      // Updates the production capacities for each NCE
      updateProfileCapacities();
      
      // Updates the status of the radar plot to now-previous turn
      calcOutputs(session.current.TURN - 1, "execute");
      for (int i=0; i<performance.numScores; i++) {
        if (i < 3) {
          radar.setScore(i, 1 - performance.scores.get(session.current.TURN - 1)[i]/performance.max[i]);
        } else {
          radar.setScore(i, performance.scores.get(session.current.TURN - 1)[i]/performance.max[i]);
        }
      }
      
      // Turns on KPI Radar if not already on
      displayRadar = true;
//      mainMenu.buttons[ bHash.get("k") ].isPressed = displayRadar;
    }
  }
  
  // Set the Active Profile selected by the user
  void setProfile(int index) {
    selectedProfile = index;
  }
  
  void populateProfiles() {
    
    // When game is active, only add profiles that are visibile by forecast lead_time on first turn
    for (int i=0; i<agileModel.PROFILES.size(); i++) {
      if (agileModel.PROFILES.get(i).timeLead == current.TURN || (current.TURN == 0 && agileModel.PROFILES.get(i).timeLead < 0) ) {
        agileModel.PROFILES.get(i).globalProductionLimit = 0;
        agileModel.PROFILES.get(i).initCapacityProfile();
        agileModel.activeProfiles.add(agileModel.PROFILES.get(i));
      }
    }
    
    // Remove "Dead" Profiles
    if (current.TURN == 0) {
      for (int i=0; i<agileModel.activeProfiles.size(); i++) {
        if (agileModel.activeProfiles.get(i).timeEnd + 1 < current.TURN) {
          
          // Resets selection to 0 if current profile is being deleted
          if (selectedProfile == i) selectedProfile = 0;
          
          agileModel.activeProfiles.remove(i);
          
          // keeps current profile selected if one behind it is removed
          if (selectedProfile > i) {
            selectedProfile--;
          }
            
        }
      }
    }

  }
  
}

// A class that holds information about events executed during each turn
class Turn {
  
  int TURN;
  ArrayList<Event> event;
  
  Turn(int TURN) {
    this.TURN = TURN;
    event = new ArrayList<Event>();
  }
  
}

// An Event might describe a change to the system initiated by (a) the user or (b) external forces
class Event {
  String eventType;
  
  // Define the site, build, and profile associated with an event
  int siteIndex, buildIndex, siteBuildIndex, profileIndex;
  boolean repurp;
  
  Event(String eventType, int siteIndex, int buildIndex, int profileIndex, boolean repurp) {
    this.eventType = eventType;
    this.siteIndex = siteIndex;
    this.buildIndex = buildIndex;
    this.profileIndex = profileIndex;
    this.repurp = repurp;
    
    if (eventType.equals("deploy")) {
      // stage a build/deployment event based upon pre-engineered modules 
      stage();
    } else if (eventType.equals("initialize")) {
      // init. a build/deployment event based upon pre-engineered modules 
      initialize();
    } else if (eventType.equals("repurpose")) {
      // stage a build/deployment event based upon pre-engineered modules 
      this.siteBuildIndex = buildIndex;
      flagRepurpose();
    }
  }
  
  Event(String eventType, int siteIndex, int siteBuildIndex) {
    this.eventType = eventType;
    this.siteIndex = siteIndex;
    this.siteBuildIndex = siteBuildIndex;
    
    // flag a build/deployment for removal 
    flagRemove();
  }
  
  // stage a build/deployment event based upon pre-engineered modules 
  void stage() {
    Build event = new Build();
    
    // Copy Ideal Build attributes to site-specific build
    event.name         = agileModel.GMS_BUILDS.get(buildIndex).name;
    event.capacity     = agileModel.GMS_BUILDS.get(buildIndex).capacity;
    event.buildCost    = agileModel.GMS_BUILDS.get(buildIndex).buildCost;
    event.buildTime    = agileModel.GMS_BUILDS.get(buildIndex).buildTime;
    event.repurpCost   = agileModel.GMS_BUILDS.get(buildIndex).repurpCost;
    event.repurpTime   = agileModel.GMS_BUILDS.get(buildIndex).repurpTime;
    event.labor        = agileModel.GMS_BUILDS.get(buildIndex).labor;
    event.repurpose    = repurp;
    event.editing      = true;
    
    // Customizes a Build for a given NCE
    event.assignProfile(profileIndex);
    
    // Add the NCE-customized Build to the given Site
    agileModel.SITES.get(siteIndex).siteBuild.add(event);
  }
  
  // stage a build/deployment event based upon pre-engineered modules 
  void initialize() {
    Build event = new Build();
    
    // Copy Ideal Build attributes to site-specific build
    event.name         = agileModel.GMS_BUILDS.get(buildIndex).name;
    event.capacity     = agileModel.GMS_BUILDS.get(buildIndex).capacity;
    event.buildCost    = agileModel.GMS_BUILDS.get(buildIndex).buildCost;
    event.buildTime    = agileModel.GMS_BUILDS.get(buildIndex).buildTime;
    event.repurpCost   = agileModel.GMS_BUILDS.get(buildIndex).repurpCost;
    event.repurpTime   = agileModel.GMS_BUILDS.get(buildIndex).repurpTime;
    event.labor        = agileModel.GMS_BUILDS.get(buildIndex).labor;
    event.repurpose    = repurp;
    event.editing      = true;
    
    // Customizes a Build for a given NCE
    event.assignProfile(profileIndex);
    event.age          = int(event.buildTime - agileModel.PROFILES.get(profileIndex).timeLaunch);
    event.capEx_Logged = true;
    
    // Add the NCE-customized Build to the given Site
    agileModel.SITES.get(siteIndex).siteBuild.add(event);
  }
  
  void flagRemove() {
    if (siteBuildIndex + 1 <= agileModel.SITES.get(siteIndex).siteBuild.size()) {
      Build current = agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex);
      agileModel.SITES.get(siteIndex).siteBuild.remove(siteBuildIndex);
//      if (current.editing) {
//        agileModel.SITES.get(siteIndex).siteBuild.remove(siteBuildIndex);
//      } else {
//        agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex).demolish = true;
//      }
    } else {
      println("No Build Present to Remove. Try Deploying Some!");
    }
    
  }
  
  void flagRepurpose() {
    if (siteBuildIndex + 1 <= agileModel.SITES.get(siteIndex).siteBuild.size()) {
      if (agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex).built == false) {
        game_message ="Can't repurpose while under construction. Wait a few turns";
        println("Can't Repurpose while Under Construction.  Wait a few turns.");
      } else {
        agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex).repurpose = true;
        agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex).built = false;
        agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex).age = 0;
        agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex).PROFILE_INDEX = profileIndex;
        game_message = " ";
      }
    } else {
      println("No Build Present to Repurpose. Try Deploying Some!");
    }
  }
}

// User Selects Next Available Profile
void nextProfile() {
  int numProfiles;
  
  if (!gameMode) {
    numProfiles = agileModel.PROFILES.size();
  } else {
    numProfiles = agileModel.activeProfiles.size();
  }
  
  if (session.selectedProfile >= numProfiles - 1) {
    session.setProfile(session.selectedProfile = 0);
  } else {
    session.setProfile(session.selectedProfile + 1);
  }
  
  println("Profile: " + (session.selectedProfile+1));
}

// User Selects Next Available Site
void nextSite() {
  session.selectedSiteBuild = 0;
  if (session.selectedSite >= agileModel.SITES.size() - 1) {
    session.selectedSite = 0;
  } else {
    session.selectedSite++;
  }
  println("Site: " + (session.selectedSite+1));
}

// User Selects Next Available Build
void nextBuild() {
  if (session.selectedBuild >= agileModel.GMS_BUILDS.size() - 1) {
    session.selectedBuild = 0;
  } else {
    session.selectedBuild++;
  }
  println("GMS Build Type: " + (session.selectedBuild+1));
}

// User Selects Next Available Build on a specific site
void nextSiteBuild() {
  if (agileModel.SITES.get(session.selectedSite).siteBuild.size() == 0) {
    game_message = "Site has no Production!";
    println("Site has no Production!");
  } else {
    game_message = " ";
    if (session.selectedSiteBuild >= agileModel.SITES.get(session.selectedSite).siteBuild.size() - 1) {
      session.selectedSiteBuild = 0;
    } else {
      session.selectedSiteBuild++;
    }
    println("Site " + session.selectedSite + " Build Type: " + (session.selectedSiteBuild+1));
  }
}

// Build Selected Manufacturing Option
void deploySelection() {
  game_message = " ";
  try {
    boolean repurp = false;
    Event deploy = new Event("deploy", session.selectedSite, session.selectedBuild, agileModel.activeProfiles.get(session.selectedProfile).ABSOLUTE_INDEX, repurp);
    session.current.event.add(deploy);
  } catch (Exception e) {
    println("deploySelection() failed to execute");
  }
  updateProfileCapacities();
}

// Remove Selected Manufacturing Option
void removeSelection() {
  Event remove = new Event("remove", session.selectedSite, session.selectedSiteBuild);
  session.current.event.add(remove);
  updateProfileCapacities();
}

// Repurpose Selected Manufacturing Option
void repurposeSelection() {
  boolean repurp = true;
  Event repurpose = new Event("repurpose", session.selectedSite, session.selectedSiteBuild, agileModel.activeProfiles.get(session.selectedProfile).ABSOLUTE_INDEX, repurp);
  session.current.event.add(repurpose);
  updateProfileCapacities();
}

// Advance to Next Turn
void endTurn() {
  session.execute();
}

// when given an absolute profile index, returns the active profile index if available
int activeProfileIndex (int profile) {
  int index = -1;
  for (int i=0; i<agileModel.activeProfiles.size(); i++) {
    if (profile == agileModel.activeProfiles.get(i).ABSOLUTE_INDEX) {
      index = i;
      break;
    }
  }
  return index;
}

