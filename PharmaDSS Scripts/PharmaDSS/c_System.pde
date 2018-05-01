// MFG_System specifies highest level, global constraints for the entire manufacturing system.  
// Rules specified here universally apply to classes within the "Objects" tab.

class MFG_System {
  
  // Units for Describing Weight (i.e. "tons")
  String WEIGHT_UNITS;
  
  // Units for Describing time (i.e. "years")
  String TIME_UNITS;
  
  int YEAR_0 = 2017;
  
  // Number of days of operation in a given year
  int DAYS_PER_YEAR = 300;
  
  int SLICE_SIZE     = 3; // Amount of Grid Units in Each Slice (in Lego Squares)
  int newSlices      = 0;
  int finishedSlices = 0;
  float BLOCKER_PERCENT = 0.5; // Percent of Existing tiles to be blocked upon setup

  float DAYS_PER_CHIP = DAYS_PER_YEAR / SLICE_SIZE;
  
  // Units for Describing cost (i.e. "GBP")
  String COST_UNITS;
  
  // Objects that hold marginal attributes of various build volumes.  
  // Each build is associated with a discrete build volume.
  ArrayList<Profile> PROFILES, activeProfiles;
  ArrayList<Site> SITES;
  ArrayList<Build> GMS_BUILDS, RND_BUILDS;
  
  color[] profileColor;
  
  // Max capacity value for a Site. (capEx + capGn)
  float maxCap;
  
  // Table that describes labor types and associated costs 
  Table LABOR_TYPES;

  // Maximum portion (0.0 - 1.0) of site utilization considered "safe."
  float MAX_SAFE_UTILIZATION;
  
  // Time Profile is know in advance of first expected demand;
  float LEAD_TIME = 3;
  
  MFG_System() {
    LABOR_TYPES = new Table();
    
    // The possible Universe/Reality of Profiles
    PROFILES = new ArrayList<Profile>();
    
    // Only the Profiles Visible/Used during a game situation
    activeProfiles = new ArrayList<Profile>();
    SITES = new ArrayList<Site>();
    GMS_BUILDS = new ArrayList<Build>();
    RND_BUILDS = new ArrayList<Build>();
  }
  
  void generateColors() {
    colorMode(HSB);
    
    profileColor = new color[PROFILES.size()];
    float hue;
    for (int i=0; i<profileColor.length; i++) {
      hue = i * 200.0 / profileColor.length;
      profileColor[i] = color(hue, 255, 255);
      
      if(i > 2){
        hue = i * 255.0 / profileColor.length;
        profileColor[i] = color(hue, 255, 255);
      }

    }
    
    colorMode(RGB);
  }
  
  float maxCapacity() {
    float current;
    maxCap = 0;
    for (int i=0; i<NUM_SITES; i++) { // Calculate maximum site capacity value
      current = agileModel.SITES.get(i).capEx + SITES.get(i).capGn;
      if ( current > agileModel.maxCap ) maxCap = current;
    }
    return maxCap;
  }
}
