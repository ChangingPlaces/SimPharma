class Logger {
  Table log;
  String port1, port2, port3;
  
  // Time when Logger is Initialized
  //
  int HOUR = hour();
  int MINUTE = minute();
  int SECOND = second();
  
  Logger() {
    log = new Table();
    log.addColumn("Time");
    log.addColumn("Action");
    log.addColumn("Mouse X");
    log.addColumn("Mouse Y");
    log.addColumn("Screen Width");
    log.addColumn("Screen Height");
    
    log.addColumn("Input");
    
    //XY AXIS
    log.addColumn("X_AXIS");
    log.addColumn("Y_AXIS");
    
    // Turn Year
    log.addColumn("Year");
    
    //SCORES ("-ILITIES")
    for(String n: performance.name) {
      
      String[] parts = split(n, "\n");
      String name = "";
      for (int j=0; j<parts.length; j++) {
        name += parts[j];
        if (j != parts.length-1) name += " ";
      }
        
      log.addColumn(name);
    }
  }
  
  void addLog(String action) {
    TableRow row = log.addRow();
    row.setString("Time", hour() + ":" + minute() + ":" + second());
    row.setString("Action", action);
    row.setInt("Mouse X", mouseX);
    row.setInt("Mouse Y", mouseY);
    row.setInt("Screen Width",  width);
    row.setInt("Screen Height", height);
    
    //Faux Input
    row.setString("Input", "TRUE");
    
    //XY AXIS
    row.setString("X_AXIS", "CAPEX Efficiency");
    row.setString("Y_AXIS", "Cost of Goods");
    
    // Turn Year
    row.setInt("Year", agileModel.YEAR_0 + session.current.TURN);
    
    //SCORES
    for(int i=0; i<performance.name.length; i++) {
      float score;
      if (performance.scores.size() > 0) {
        score = performance.scores.get(session.current.TURN-1)[i];
        String[] parts = split(performance.name[i], "\n");
        String name = "";
        for (int j=0; j<parts.length; j++) {
          name += parts[j];
          if (j != parts.length-1) name += " ";
        }
        row.setFloat(name, score);
      }  
    }
    
    save();
  }
  
  void save() {
    String user_name = System.getProperty("user.name");
    String home_directory = System.getProperty("user.home");
    String file_seperator = System.getProperty("file.separator");
    String fileName = home_directory + file_seperator + "pharma_logs" + file_seperator;
    fileName += user_name + "_" + HOUR + "_" + MINUTE + "_" + SECOND + "_log.csv";
    saveTable(log, fileName);
  }
}
