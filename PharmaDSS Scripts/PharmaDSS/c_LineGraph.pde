class LineGraph{
  float minx, miny, h, w;
  int num_intervals;
  ArrayList<float[]> Values = new ArrayList<float[]>();
  ArrayList<float[]> pValues = new ArrayList<float[]>();

  color[] colarray = new color[5];

  
  LineGraph( ArrayList<float[]> _Values, ArrayList<float[]> _pValues, float _x, float _y, float _w, float _h){
      Values = _Values;
      pValues = _pValues;
  
      minx = _x;
      h = _h;
      miny = _y + _h;
   
      w = _w;
    
      //Making a color array of different colors. 
      colarray[0] = color(33, 139, 204);
      colarray[1]=  color(67, 255, 226);
      colarray[2]=  color(149, 75, 209);
      colarray[4]=  color(255, 136, 116);
      colarray[3]=  color(204, 40, 41);
  }
  
  void draw(){
    float posx, posy, posx2, posy2;

    //Implement try catch in case of memory leak of array
    try{
      for(int i = 0; i<performance.numScores; i++){
      
        //draws legend
        noStroke();
        fill(colarray[i]);
        rect(minx + (4-i)*w/4 - 45, miny - h - 30, 10, 10);
        fill(textColor);
        textAlign(LEFT);
        textSize(textSize);
        text(performance.name[i], minx + (4-i)*w/4 - 30, miny - h - 21 );   
        
        // Cycles through performance AND predicted
        ArrayList<float[]> drawVal;
        float alpha;
        for (int n=0; n<2; n++) {
          
          // Only show values for current and prior turns
          int intervals;
          if (gameMode && session.current.TURN > 0 && n == 0) {
            intervals = min(Values.size()-1, session.current.TURN-1);
          } else if (!gameMode || n == 1) {
            intervals = Values.size()-1;
          } else {
            intervals = 0;
          }
          
          if (n==0) {
            drawVal = Values;
            alpha = 1.0;
          } else {
            drawVal = pValues;
            alpha = 0.3;
          }
          
          for(int j = 0; j<intervals; j++){
            // Calculate x and y locations
            posx  = (j+0.5)*(w/drawVal.size()) + minx;         
            posy = map(100*drawVal.get(j)[i]/performance.max[i], 0, 100, miny - 10, miny - h + 30);
            
            posx2  = posx + (w/drawVal.size());
            posy2 = map(100*drawVal.get(j+1)[i]/performance.max[i], 0, 100, miny - 10, miny - h + 30);
             
            //set colors with the appropriate profile
            if (n == 0) {
              fill(colarray[i], alpha*255);
              noStroke();
              int dim = 2;
              ellipse(posx2, posy2, dim, dim);
            }
            stroke(colarray[i], alpha*150);
            strokeWeight(3);
            line(posx, posy, posx2, posy2);
             
            //if(mouseX <= posx2 + 5 && mouseX >= posx2 -5 && mouseY <= posy2 + 5 && mouseY >= posy2-5 || (gameMode && j == session.current.TURN-2) || (!gameMode && j == drawVal.size()-2) ){
            if(mouseX <= posx2 + 5 && mouseX >= posx2 -5 && mouseY <= posy2 + 5 && mouseY >= posy2-5 ){
              fill(colarray[i], 50);
              ellipse(posx2, posy2, 10, 10);
              
              fill(textColor);
              textAlign(CENTER);
              //int val = str(100*drawVal.get(j+1)[i]/performance.max[i]).substring(0, str(100*drawVal.get(j+1)[i]/performance.max[i]).indexOf(".")).length();
              if (i < 3) {
                text(drawVal.get(j+1)[i]/1000000.0 + " " +performance.unit[i], posx2, posy2-10);
              } else {
                text(100*drawVal.get(j+1)[i] + " " +performance.unit[i], posx2, posy2-10);
              }
            }
          }
        
          //special start and end case to begin the line from the axis
          //unsure why this isn't picking up
          if (!gameMode || session.current.TURN > 0) {   
            posx  = minx + 0.5*(w/drawVal.size()); 
            posy = map(100*drawVal.get(0)[i]/performance.max[i], 0, 100, miny - 10, miny - h + 30);
            posx2  = posx + (w/drawVal.size());
            posy2 = map(100*drawVal.get(1)[i]/performance.max[i], 0, 100, miny - 10, miny - h + 30);
            int dim = 2;
            if (session.current.TURN == 1) dim = 4;
              fill(colarray[i], alpha*255);
              noStroke();
              ellipse(posx, posy, dim, dim);
            if (!gameMode || session.current.TURN > 1) {
              fill(colarray[i]);
              strokeWeight(3);
              stroke(colarray[i], alpha*150);
              line(posx, posy, posx2, posy2);
            }
          }
          
        }
      }
    } catch(Exception e){}
      
    //Axes
    stroke(textColor);
    strokeWeight(1);
    //line(minx, miny, minx + w, miny);
    line(minx, miny, minx, miny - h + 20);
    
    //Labels
    fill(textColor);
    textSize(textSize);
    textAlign(CENTER);
    float canH = height - 2.8*MARGIN;
    float bottomAxisY = miny + textSize*2.5;
    
    //Year marks and labels
    //text("Year", minx + w/2, bottomAxisY); 
    for(int i = 0; i<Values.size()+1; i++){
      int curyear = agileModel.YEAR_0+i;
      strokeWeight(1);
      
      if((i+1) % 5 == 0 || curyear == agileModel.YEAR_0){
        line(minx + (i+0.5)*(w/Values.size()), miny + 2, minx + (i+0.5)*(w/Values.size()), miny-2);
        text("FY'" + curyear%2000, (i+0.5)*(w/Values.size()) + minx, miny + textSize + 2);
      }
    }
    
    //Score marks and labels
    //text(100, minx - 20, miny - h + 23);
    text(0, minx - 10, miny - 0.5*textSize);
    float x = minx - textSize*2;
    float y = miny - h/2;
    pushMatrix();
    translate(x,y);
    rotate(-HALF_PI);
    translate(-x,-y);
    text("Score", x,y);
    popMatrix();
    
    // Shows bar marker present time
    if (gameMode && session.current.TURN > 0) {
      float X = (session.current.TURN - 0.5)*(w/Values.size()) + minx;
      fill(NOW, 50);
      noStroke();
      rect(X, miny - h, 2, h + MARGIN - 25);
      fill(NOW);
      textAlign(LEFT);
      text("FY'" + (agileModel.YEAR_0 + session.current.TURN)%2000, X+3, miny + MARGIN - 25);
    }
    
    fill(textColor);
  }
}

