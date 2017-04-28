 /* System specifies constraints for the entire manufacturing system.  
 /  Rules specified here universally apply to classes within the "Objects" tab.
*/
 
 /* Classes that define primary object abstractions in the system such as: 
 /  (a) Profile: NCE demand profile
 /  (b) Site: Factory Location/Area
 /  (c) Build: Manufacturing Unit/Process
 /  (d) Person: "Human Beans", as the BFG would say (i.e. Labor)
*/ 
 
class System {
  
  // Units for Describing Weight (i.e. "tons")
  String WEIGHT_UNITS;
  
  // Units for Describing time (i.e. "years")
  String TIME_UNITS;
  
  // Units for Describing cost (i.e. "GBP")
  String COST_UNITS;
  
  // Objects that hold marginal attributes of various build volumes.  
  // Each build is associated with a discrete build volume.
  ArrayList<Profile> PROFILES;
  ArrayList<Site> SITES;
  ArrayList<Build> GMS_BUILDS, RND_BUILDS;
  
  // Table that describes labor types and associated costs 
  Table LABOR_TYPES;

  // Maximum portion (0.0 - 1.0) of site utilization considered "safe."
  float MAX_SAFE_UTILIZATION;
  
  System() {
    LABOR_TYPES = new Table();
    PROFILES = new ArrayList<Profile>();
    SITES = new ArrayList<Site>();
    GMS_BUILDS = new ArrayList<Build>();
    RND_BUILDS = new ArrayList<Build>();
  }
}
