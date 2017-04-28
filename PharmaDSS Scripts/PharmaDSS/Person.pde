// A human being involved in the production process
class Person {
  
  // Name of Role (i.e. "Operator")
  String name;
  
  float shifts; // per time
  
  float cost; // per shift
  
  // Basic Constructor
  Person() {}
  
  // The Class Constructor
  Person(String name, float shifts, float cost) {
    this.name = name;
    this.shifts = shifts;
    this.cost = cost;
  }
}
