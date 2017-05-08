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
  }
  
  void execute() {
    turnLog.add(current);
    println("Turn " + current.TURN + " logged");
    
    current = new Turn(current.TURN + 1);
    //setProfile(0);
    
    populateProfiles();
    println("There are now " + agileModel.activeProfiles.size() + " Active Profiles.");
    
    for (int i=0; i<agileModel.SITES.size(); i++) {
      agileModel.SITES.get(i).updateBuilds();
    }
  }
  
  void setProfile(int index) {
    selectedProfile = index;
    println("Now editing profile: " + agileModel.PROFILES.get(selectedProfile).name);
  }
  
  // Only adds profiles with 5 years advance forecast
  void populateProfiles() {
    for (int i=0; i<agileModel.PROFILES.size(); i++) {
      if (agileModel.PROFILES.get(i).timeLead == current.TURN) {
        agileModel.activeProfiles.add(agileModel.PROFILES.get(i));
      }
    }
    for (int i=0; i<agileModel.activeProfiles.size(); i++) {
      if (agileModel.activeProfiles.get(i).timeEnd + 1 < current.TURN) {
        if (selectedProfile == i) selectedProfile = 0;
        agileModel.activeProfiles.remove(i);
      }
    }
  }
  
}

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
  Event(String eventType) {
    this.eventType = eventType;
  }
}


