boolean gameMode = false;

// Game, Turn, Event classes help log and manage actions over the passage of time
// Games are made up of a series of Turns, and Turns are made up of 0 or more events that effect the system.
class Game {
  
  // turn element tracks the passage of time in discrete intervals
  // Units of Time are defined in the "System" as "TIME_UNITS"
  Turn current;
  ArrayList<Turn> turnLog;
  
  Game() {
    current = new Turn(0);
    turnLog = new ArrayList<Turn>();
  }
  
  void execute() {
    turnLog.add(current);
    println("Turn " + current.TURN + " logged");
    
    current = new Turn(current.TURN + 1);
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


