// This is my Cars script

int numCars = 50;

Car[] fleet;

// setup() is a method/function that runs once when Cars is first compiled
void setup() {
  size(300, 300); // 300px x 300px canvas;
  
  fleet = new Car[numCars];
  
  
  int randX, randY;
  for (int i=0; i<numCars; i++) {
    
    colorMode(HSB);
    int tempColor = color( 255.0*(float(i)/numCars), 255, 255);
    colorMode(RGB);
    
    fleet[i] = new Car("Car " + (i+1), tempColor);
    randX = int(random(0, width));
    randY = int(random(0, height));
    fleet[i].setLocation(randX, randY);
  }
  
}

// draw() is a method/function that runs infinity in a loop after setup()
void draw() {
  background(0); // 0 = black; 255 = white
  
  // Set the color of the next items you draw
  for (int i=0; i<fleet.length; i++) {
    
    if (i==13) {
      fleet[i].jitter();
    }
    fill(fleet[i].col);
    ellipse(fleet[i].x, fleet[i].y, 10, 10);
    text(fleet[i].name, fleet[i].x + 20, fleet[i].y);
  }
}

class Car {
  String name;
  int col;
  int x, y;
  
  Car(String name, int col) {
    this.name = name;
    this.col = col;
    x = 0;
    y = 0;
  }
  
  void setLocation(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  void jitter() {
    x += random(-3,3);
    y += random(-3,3);
  }
}
