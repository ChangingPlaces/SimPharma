
class LineGraph{
  float minx, miny, h, w;
  int num_intervals;
  ArrayList<float[]> Values = new ArrayList<float[]>();

  color[] colarray = new color[5];

  
  LineGraph( ArrayList<float[]> _Values, float _x, float _y, float _w, float _h){
      Values = _Values;
  
      minx = _x;
      h = _h;
      miny = _y + _h;
   
      w = _w;
    
      //Making a color array of different colors. 
      colarray[0] = color(33, 139, 204);
      colarray[1]=  color(149, 75, 209);
      colarray[2]=  color(67, 255, 226);
      colarray[3]=  color(255, 136, 116);
      colarray[4]=  color(204, 40, 41);
  }
  
  void draw(){
    float posx, posy, posx2, posy2, posx3, posy3= 0;
    
    
    //Implement try catch in case of memory leak of array
    try{
      
    for(int i = 0; i<NUM_OUTPUTS; i++){
       //draws legend
       noStroke();
       fill(colarray[i]);
       rect(minx + i*w/4.5 , miny - h - 10, 10, 10);
       fill(textColor);
       textAlign(LEFT);
       textSize(textSize-1);
       text(outputNames[i], minx + i*w/4.5 + 12, miny - h );
       

      for(int j = 0; j<Values.size()-1; j++){
         posx  = j*(w/Values.size()) + minx;         
         posy = map(100*Values.get(j)[i], 0, 100, miny - 10, miny - h + 30);
        
         posx2  = posx + (w/Values.size());
         posy2 = map(100*Values.get(j+1)[i], 0, 100, miny - 10, miny - h + 30);
         
         ellipse(posx2, posy2, 2, 2);
         line(posx, posy, posx2, posy2);
         
         //set colors with the appropriate profile
         fill(colarray[i]);
         strokeWeight(2);
         stroke(colarray[i], 150);
         
         if(mouseX <= posx2 + 5 && mouseX >= posx2 -5 && mouseY <= posy2 + 5 && mouseY >= posy2-5){
           fill(textColor);
           println(posy2, posy2+5, posx2);
           textAlign(CENTER);
           text(100*Values.get(j+1)[i], posx2, posy2-10);
           fill(colarray[i], 50);
           ellipse(posx2, posy2, 10, 10);
         }
      }
      
      //special start and end case to begin the line from the axis
      //unsure why this isn't picking up
         posx  = minx;         
         posy = map(100*Values.get(0)[i], 0, 100, miny - 10, miny - h + 30);
         posx2  = posx + (w/Values.size());
         posy2 = map(100*Values.get(1)[i], 0, 100, miny - 10, miny - h + 30);
         line(posx, posy, posx2, posy2);
 
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
  float bottomAxisY = miny + textSize*2.5;
  
  //Year marks and labels
  text("Year", minx + w/2, bottomAxisY); 
  for(int i = 0; i<Values.size()+1; i++){
    int curyear = 2017+i;
    strokeWeight(1);
    line(minx + i*(w/Values.size()), miny + 2, minx + i*(w/Values.size()), miny-2);
    if(i % 5 == 0){
    text(curyear, i*(w/Values.size()) + minx, miny + textSize + 2);
    }
  }
  
  //Score marks and labels
  text(100, minx - 20, miny - h + 23);
  text(0, minx - 10, miny);
  float x = minx - textSize*2;
  float y = miny - h/2;
  pushMatrix();
  translate(x,y);
  rotate(-HALF_PI);
  translate(-x,-y);
  text("Score", x,y);
  popMatrix();
}
}

