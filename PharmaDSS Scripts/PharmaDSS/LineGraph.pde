ArrayList<ArrayList<Float>>lineList = new ArrayList<ArrayList<Float>>();

class LineGraph{
  float minx, miny, h, w;
  int num_intervals;
  ArrayList<ArrayList<Float>> Values = new ArrayList<ArrayList<Float>>();

  color[] colarray = new color[5];

  
  LineGraph( ArrayList<ArrayList<Float>> _Values, float _x, float _y, float _w, float _h, int _num_intervals){
      Values = _Values;
  
      minx = _x;
      h = _h;
      miny = _y + _h;
   
      w = _w;
      num_intervals = _num_intervals;
    
      //Making a color array of different colors. 
      colarray[0] = color(33, 139, 204);
      colarray[1]=  color(103, 84, 153);
      colarray[2]=  color(67, 255, 226);
      colarray[3]=  color(255, 136, 116);
      colarray[4]=  color(204, 40, 41);
  }
  
  void draw(){
    float posx, posy, posx2, posy2 = 0;
    
    //Implement try catch in case of memory leak of array
    try{
    for(int i = 0; i<Values.size(); i++){
      
       //draws legend
       noStroke();
       fill(colarray[i]);
       rect(minx + i*w/4.5 , miny - h - 10, 10, 10);
       fill(textColor);
       textAlign(LEFT);
       textSize(textSize-1);
       text(kpi.names.get(i), minx + i*w/4.5 + 12, miny - h );
       
      for(int j = 0; j<19; j++){

         posx  = j*(w/num_intervals) + minx; 
         posy = map(Values.get(i).get(j), 0, 100, miny - h + 30, miny - 10);
        
         posx2  = posx + (w/num_intervals);
         posy2 = map(Values.get(i).get(j+1), 0, 100, miny - h + 30, miny - 10);

         //set colors with the appropriate profile
         fill(colarray[i]);
         strokeWeight(2);
         stroke(colarray[i], 150);
         
         ellipse(posx, posy, 2, 2);
         line(posx, posy, posx2, posy2);
         
      }
    }
  }
  catch(Exception e){}
  
  //Axes
  stroke(textColor);
  line(minx, miny, minx + w, miny);
  line(minx, miny, minx, miny - h + 20);
  
  //Labels
  fill(textColor);
  textSize(textSize);
  textAlign(CENTER);
  float canH = height - 2.8*MARGIN;
  float bottomAxisY = canH*.4 - 20 + 2.2*MARGIN + 20 + canH*.6 - 10;
  text("Year", minx + w/2, bottomAxisY);
  float x = minx - 20;
  float y = miny - h/2;
  
  pushMatrix();
  translate(x,y);
  rotate(-HALF_PI);
  translate(-x,-y);
  text("Score", x,y);
  popMatrix();
}
}

