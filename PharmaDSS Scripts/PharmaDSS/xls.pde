 /* Scripts for reading values from GSK Meta-Model XLS file. The scripts:
 /  (a) read values into memory
 /  (b) write the values into local objects that are used in the model
*/

// Library for reading XLS files into Processing
import de.bezier.data.*;  

  // Data Locations (Last modified according to "Agile Network Model v7")
  // Note that NCE profiles need to be edited so that all demand (forecast AND actual) are proper values (not equations). 
  // In other words, values should not self-reference each other.
  
  // "Overarching Game Rules&Inputs"
  int SYSTEM_SHEET = 4; 
  
    // Cell A48
    int LABOR_ROW = 47; 
    int LABOR_COL = 0;
    int NUM_LABOR = 6;
    
    // Cell C38
    int SITE_ROW = 37; 
    int SITE_COL = 1;
    int NUM_SITES = 2;
    
    // Cell D3
    int GMS_ROW = 2; 
    int GMS_COL = 3;
    int NUM_GMS_BUILDS = 12;
    
    // Cell U3
    int RND_ROW = 2; 
    int RND_COL = 20;
    int NUM_RND_BUILDS = 6;
    
    // Cell B63
    int SAFE_ROW = 62; 
    int SAFE_COL = 1;
    
    // Cell B58
    int RND_LIMIT_ROW = 57; 
    int RND_LIMIT_COL = 1;
  
  // "NCE Profile Data"
  int PROFILE_SHEET = 0; 
    
    // Cell A1
    int PROFILE_ROW = 0; 
    int PROFILE_COL = 0;
    int NUM_PROFILES = 10;
    int NUM_INTERVALS = 20;
    
// the xls reader object
XlsReader reader;         

// reads the XLS file and assigns values to System and Objects
void loadModel_XLS(System model, String name) {
  
  // open xls file for reading
  reader = new XlsReader( this, name );  
  
  // Read System Information
  reader.openSheet(SYSTEM_SHEET);
    
  // Read System: Units
  model.WEIGHT_UNITS = reader.getString(SITE_ROW, SITE_COL+2);
  model.TIME_UNITS = reader.getString(GMS_ROW+2, GMS_COL-2);
  model.COST_UNITS = reader.getString(GMS_ROW+7, GMS_COL-2).substring(0,1);

  // Read System: Labor Types
  model.LABOR_TYPES.addColumn(reader.getString(LABOR_ROW, LABOR_COL));
  model.LABOR_TYPES.addColumn(reader.getString(LABOR_ROW, LABOR_COL+1));
  for (int i=0; i<NUM_LABOR; i++) {
    model.LABOR_TYPES.addRow();
    model.LABOR_TYPES.setString(i, 0, reader.getString(LABOR_ROW+1+i, LABOR_COL));
    model.LABOR_TYPES.setFloat(i, 1, reader.getFloat(LABOR_ROW+1+i, LABOR_COL+1));
  }

  // Read System: GMS Build Types
  for (int i=0; i<NUM_GMS_BUILDS; i++) {
    model.GMS_BUILDS.add(new Build());
    model.GMS_BUILDS.get(i).name         = "Build #" + (i+1);
    model.GMS_BUILDS.get(i).capacity     = reader.getFloat(GMS_ROW, GMS_COL + i);
    model.GMS_BUILDS.get(i).buildCost    = buildCost(model.GMS_BUILDS.get(i).capacity);
    model.GMS_BUILDS.get(i).buildTime    = buildTime(model.GMS_BUILDS.get(i).capacity);
    model.GMS_BUILDS.get(i).repurpCost   = 1000000 * reader.getFloat(GMS_ROW + 3, GMS_COL + i);
    model.GMS_BUILDS.get(i).repurpTime   = reader.getFloat(GMS_ROW + 4, GMS_COL + i);
    
    // Read System: GMS Build Labor
    for (int j=0; j<NUM_LABOR; j++) {
      int num = reader.getInt(GMS_ROW + 5 + 3*j, GMS_COL + i);
      for (int k=0; k<num; k++) {
        model.GMS_BUILDS.get(i).labor.add(new Person(
          model.LABOR_TYPES.getString(j, 0), // Name
          reader.getFloat(GMS_ROW + 6 + 3*j, GMS_COL + i), // #Shifts
          model.LABOR_TYPES.getFloat(j, 1) // Cost/Shift
        ));
      }
    }
  }
  
  // Read System: RND Build Types
  for (int i=0; i<NUM_RND_BUILDS; i++) {
    model.RND_BUILDS.add(new Build());
    model.RND_BUILDS.get(i).name         = "Build #" + (i+1);
    model.RND_BUILDS.get(i).capacity     = reader.getFloat(RND_ROW, RND_COL + i);
    model.RND_BUILDS.get(i).repurpCost    = 1000000 * reader.getFloat(RND_ROW + 2, RND_COL + i);
    model.RND_BUILDS.get(i).repurpTime    = reader.getFloat(RND_ROW + 1, RND_COL + i);
    
    // Read System: RND Build Labor
    for (int j=0; j<NUM_LABOR; j++) {
      int num = reader.getInt(RND_ROW + 3 + 3*j, RND_COL + i);
      for (int k=0; k<num; k++) {
        model.RND_BUILDS.get(i).labor.add(new Person(
          model.LABOR_TYPES.getString(j, 0), // Name
          reader.getFloat(RND_ROW + 4 + 3*j, RND_COL + i), // #Shifts
          model.LABOR_TYPES.getFloat(j, 1) // Cost/Shift
        ));
      }
    }
  }
  
  // Read System: Sites
  for (int i=0; i<NUM_SITES; i++) {
    model.SITES.add(new Site(
      "" + reader.getInt(SITE_ROW + i, SITE_COL),
      reader.getFloat(SITE_ROW + i, SITE_COL + 1),
      reader.getFloat(SITE_ROW + i + 2, SITE_COL + 1),
      reader.getInt(RND_LIMIT_ROW + i, RND_LIMIT_COL)
    ));
  }
  
  // Read System: MAX_SAFE_UTILIZATION
  model.MAX_SAFE_UTILIZATION = reader.getFloat(SAFE_ROW, SAFE_COL)/100.0;
  
  // Read Profile Information
  reader.openSheet(PROFILE_SHEET);
  
  // Read Profile: Attributes
  for (int i=0; i<NUM_PROFILES; i++) {
    
    // Read Profile: Basic Attributes
    model.PROFILES.add( new Profile() ); 
    model.PROFILES.get(i).name = reader.getString(PROFILE_ROW + 2 + 4*i, PROFILE_COL);
    model.PROFILES.get(i).summary = reader.getString(PROFILE_ROW + 2 + 4*i, PROFILE_COL + 1);
    if (reader.getString(PROFILE_ROW + 2 + 4*i, PROFILE_COL + 2).equals("success")) {
      model.PROFILES.get(i).success = true;
    } else {
      model.PROFILES.get(i).success = false;
    }
    model.PROFILES.get(i).timeStart = reader.getString(PROFILE_ROW + 2 + 4*i, PROFILE_COL + 6);
    
    // Read Profile: Site Costs
    for (int j=0; j<NUM_SITES; j++) {
      model.PROFILES.get(i).productionCost.add( reader.getFloat(PROFILE_ROW + 2 + 4*i, PROFILE_COL + 7 + j) );
    }
    
    // Read Profile: Demand Profile
    model.PROFILES.get(i).demandProfile.addRow(); // Time
    model.PROFILES.get(i).demandProfile.addRow(); // Demand Forecast
    model.PROFILES.get(i).demandProfile.addRow(); // Demand Actual
    model.PROFILES.get(i).demandProfile.addRow(); // Event Description
    for (int j=0; j<NUM_INTERVALS; j++) {
      model.PROFILES.get(i).demandProfile.addColumn();
      model.PROFILES.get(i).demandProfile.setFloat(0, j, reader.getFloat(PROFILE_ROW, PROFILE_COL + 10 + j) );
      model.PROFILES.get(i).demandProfile.setFloat(1, j, reader.getFloat(PROFILE_ROW + 2 + 4*i, PROFILE_COL + 10 + j) );
      model.PROFILES.get(i).demandProfile.setFloat(2, j, reader.getFloat(PROFILE_ROW + 3 + 4*i, PROFILE_COL + 10 + j) );
      model.PROFILES.get(i).demandProfile.setString(3, j, reader.getString(PROFILE_ROW + 4 + 4*i, PROFILE_COL + 10 + j) );
    }
    
    // Calculates peak forecast demand value
    model.PROFILES.get(i).peak();
  }
}
