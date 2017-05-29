boolean gameMode = false;

// Regenerate Game
void regenerateGame() {
  
  boolean interrupt = false;
  
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
  
  // Calculates Max Capacity Site
  agileModel.maxCapacity();
  
  // Generate New Basins for Sites
  mfg.resetCellTypes();
  generateBasins();
  
  //resets Scores for debugging
  for (int i=0; i<kpi.nRadar; i++) {
    kpi.setScore(i, random(1.0));
  }
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
  
  // Boolean to specify if continuous manufacturing technology is allowed
  boolean continuousMfG = false;
  
  Game() {
    current = new Turn(0);
    selectedProfile = 0;
    selectedSite = 0;
    selectedSiteBuild = 0;
    selectedBuild = 0;
    turnLog = new ArrayList<Turn>();
    tableHistory.clear();
    
    // Only adds profiles with 5 years advance forecast
    agileModel.activeProfiles.clear();
    populateProfiles();
    
    // Clear all user-defined builds from each site
    resetSites();
  }
  
  // Clear all user-defined builds from sites
  void resetSites() {
    for (int i=0; i<agileModel.SITES.size(); i++) {
      agileModel.SITES.get(i).siteBuild.clear();
    }
    
    for (int i=0; i<agileModel.activeProfiles.size(); i++) {
      Event initialize = new Event("initialize", int(random(NUM_SITES-0.01)), int(random(agileModel.GMS_BUILDS.size()-0.01)), agileModel.activeProfiles.get(i).ABSOLUTE_INDEX);
      current.event.add(initialize);
    }
    
  }
  
  // End the turn and commit all events to the Log
  void execute() {
    
    if (current.TURN < NUM_INTERVALS) {
      if (connection) {
        tableHistory.add(tablePieceInput);
        println("Colortizer state logged #" + (tableHistory.size() - 1));
      }
      turnLog.add(current);
      println("Turn " + current.TURN + " logged");
      
      current = new Turn(current.TURN + 1);
      
      // Only adds profiles to game within known Lead Time
      populateProfiles();
      println("There are now " + agileModel.activeProfiles.size() + " Active Profiles.");
      
      // Updates the Status of builds on each site at end of each turn (age, etc)
      for (int i=0; i<agileModel.SITES.size(); i++) {
        agileModel.SITES.get(i).updateBuilds();
      }
      
      // Updates the production capacities for each NCE
      for (int i=0; i<agileModel.activeProfiles.size(); i++) {
        agileModel.activeProfiles.get(i).calcProduction(agileModel.SITES);
      }
    }
  }
  
  // Set the Active Profile selected by the user
  void setProfile(int index) {
    selectedProfile = index;
  }
  
  // Only adds profiles with 5 years advance forecast
  void populateProfiles() {
    
    // When not in game mode, all profiles are viewed in their entirety (i.e. Omnipotent mode..)
    for (int i=0; i<agileModel.PROFILES.size(); i++) {
      if (agileModel.PROFILES.get(i).timeLead == current.TURN || (current.TURN == 0 && agileModel.PROFILES.get(i).timeLead < 0) ) {
        agileModel.PROFILES.get(i).globalProductionLimit = 0;
        agileModel.PROFILES.get(i).initCapacityProfile();
        agileModel.activeProfiles.add(agileModel.PROFILES.get(i));
      }
    }
    
    // When game is active, only populate profiles that are visibile by 5-yr forecasts
    for (int i=0; i<agileModel.activeProfiles.size(); i++) {
      if (agileModel.activeProfiles.get(i).timeEnd + 1 < current.TURN) {
        
        // Resets selection to 0 if current profile is being deleted
        if (selectedProfile == i) selectedProfile = 0;
        
        agileModel.activeProfiles.remove(i);
        
        // keeps current profile selected if one behind it is removed
        if (selectedProfile > i) selectedProfile--;
          
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
  
  Event(String eventType, int siteIndex, int buildIndex, int profileIndex) {
    this.eventType = eventType;
    this.siteIndex = siteIndex;
    this.buildIndex = buildIndex;
    this.profileIndex = profileIndex;
    
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
    event.built        = false;
    
    // Customizes a Build for a given NCE
    event.assignProfile(profileIndex);
    event.age          = int(0 - agileModel.PROFILES.get(profileIndex).timeLead);
    
    // Add the NCE-customized Build to the given Site
    agileModel.SITES.get(siteIndex).siteBuild.add(event);
  }
  
  void flagRemove() {
    agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex).demolish = true;
  }
  
  void flagRepurpose() {
    if (agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex).built == false) {
      println("Can't Repurpose while Under Construction");
    } else {
      agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex).repurpose = true;
      agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex).built = false;
      agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex).age = 0;
      agileModel.SITES.get(siteIndex).siteBuild.get(siteBuildIndex).PROFILE_INDEX = profileIndex;
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
    println("Site has no Production!");
  } else {
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
  Event deploy = new Event("deploy", session.selectedSite, session.selectedBuild, agileModel.activeProfiles.get(session.selectedProfile).ABSOLUTE_INDEX);
  session.current.event.add(deploy);
}

// Remove Selected Manufacturing Option
void removeSelection() {
  Event remove = new Event("remove", session.selectedSite, session.selectedSiteBuild);
  session.current.event.add(remove);
}

// Repurpose Selected Manufacturing Option
void repurposeSelection() {
  Event repurpose = new Event("repurpose", session.selectedSite, session.selectedSiteBuild, agileModel.activeProfiles.get(session.selectedProfile).ABSOLUTE_INDEX);
  session.current.event.add(repurpose);
}

// Advance to Next Turn
void endTurn() {
  session.execute();
}

