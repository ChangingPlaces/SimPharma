// Game, Turn, Event classes help log and manage actions over the passage of time
// Games are made up of a series of Turns, and Turns are made up of 0 or more events that effect the system.

class Game {
  
  // turn element tracks the passage of time in discrete intervals
  // Units of Time are defined in the "System" as "TIME_UNITS"
  int turnCurrent;
  ArrayList<Turn> turn;
  
  Game() {
    turnCurrent = 0;
    turn = new ArrayList<Turn>();
  }
  
  void executeTurn(Turn current) {
    turn.add(current);
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


