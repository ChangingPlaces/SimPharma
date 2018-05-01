// Processing 2
// Barebones script to test cross-platform compatibility 
// of saving to absolute path to bot Windows and OSX

Table data;

void setup() {
  data = new Table();
  
  data.addColumn("X");
  data.addColumn("Y");
  
  TableRow row = data.addRow();
  row.setFloat("X", random(0, 10));
  row.setFloat("Y", random(0, 10));
  
  String home_directory = System.getProperty("user.home");
  String file_seperator = System.getProperty("file.separator");
  
  String fileName = home_directory + file_seperator + "logs" + file_seperator + "log.csv";
  
  saveTable(data, fileName);
  
}
