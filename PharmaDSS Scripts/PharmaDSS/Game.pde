boolean gameMode = false;

// Game, Turn, Event classes help log and manage actions over the passage of time
// Games are made up of a series of Turns, and Turns are made up of 0 or more events that effect the system.
class Game {
  
  // turn element tracks the passage of time in discrete intervals
  // Units of Time are defined in the "System" as "TIME_UNITS"
  Turn current;
  ArrayList<Turn> turnLog;
  
  int selectedProfile;
  int selectedSite;
  int selectedBuild;
  
  Game() {
    current = new Turn(0);
    selectedProfile = 0;
    selectedSite = 0;
    selectedBuild = 0;
    turnLog = new ArrayList<Turn>();
    
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
  }
  
  // End the turn and commit all events to the Log
  void execute() {
    if (current.TURN < NUM_INTERVALS) {
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
      if (agileModel.PROFILES.get(i).timeLead == current.TURN) {
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
  int siteIndex, buildIndex, profileIndex;
  
  Event(String eventType, int siteIndex, int buildIndex, int profileIndex) {
    this.eventType = eventType;
    this.siteIndex = siteIndex;
    this.buildIndex = buildIndex;
    this.profileIndex = profileIndex;
    
    // stage a build/deployment event based upon pre-engineered modules 
    stage();
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
}


