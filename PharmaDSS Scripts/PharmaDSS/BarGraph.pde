class BarGraph{
    int w, h, x, y;
     float timeLead, timeEnd, scalerW, scalerH;
     Profile profile;
    boolean axis, detail, selected, isProfileGraph;
    int numBars;  

    BarGraph(int _w, int _h, int _x, int _y, boolean _axis, boolean _detail, int _numBars){
      w = _w;
      h = _h;
      x = _x;
      y = _y;
      axis = _axis;
      detail = _detail;
      numBars = _numBars;
    }
    
    
    void drawProfileGraph(){
       float forecastScalerH = 2.0; // leaves room for actual demand to overshoot forecast
      //draw appropriate rectangles
    //Time Bar
    if (!detail) {
      fill(#CCCCCC, 80);
      float unit = 5000;
      float begin = max(0, profile.timeLead);
      float end = max(0, profile.timeEnd);
     
      scalerH = h/(forecastScalerH*profile.demandPeak_F);
      scalerW = float(w)/numBars;
      if (!gameMode) {
        rect(x + scalerW * begin, y - h, scalerW * (min(end, numBars) - begin), h);
      } else {
        rect(x + scalerW * begin, y - h, scalerW * (min(min(end, numBars), session.current.TURN) - begin), h);
      }
    }
      
    // Draw Profile Selection
      if (selected) {
        fill(HIGHLIGHT, 40);
        noStroke(); 
        rect(x - 15, y - h - 7, w + 30, h+18, 5);
        noStroke();
      }
    
        noStroke();
 
for (int i=0; i<numBars; i++) {
      float barF, barA, cap, capLast, globalCap;
      barF = scalerH * profile.demandProfile.getFloat(1, i); // Forecast Demand
      barA = scalerH * profile.demandProfile.getFloat(2, i); // Actual Demand
      cap = scalerH * profile.capacityProfile.getFloat(1, i); // Actual Global Production Capacity
      globalCap = scalerH * profile.globalProductionLimit; // Actual Global Production Capacity
      if (i==0) {
        capLast = 0;
      } else {
        capLast = scalerH * profile.capacityProfile.getFloat(1, i-1); 
      }
      noStroke();
      
      //Draw forecast and actual bars
      if(background == 255){
      fill(120);
      }
      else{
      fill(180);
      }
      rect(x + scalerW * i +1, y - barF, scalerW - 1, barF);

      // If game is on, only shows actual demand bars for finished turns
      if (!gameMode || session.current.TURN > i) {
        fill(THEME, 150);
        rect(x + scalerW * i + 1, y - barA, scalerW - 1, barA);
      }
      
      // Draw Peak Forcast
      if (profile.peakTime_F == profile.demandProfile.getFloat(0, i)) {
        fill(textColor);
        ellipse(x + scalerW * (0.5+i), y - barF, 3, 3);
        fill(textColor);
        textAlign(CENTER);
         textSize(textSize);
        text(int(profile.demandPeak_F/100)/10.0 + agileModel.WEIGHT_UNITS, x + scalerW * (0.5+i) + 1, y - barF - 5);
      }
      
      // Draw Details such as axis
      fill(textColor);
      textAlign(CENTER);
      if (detail && (i==0 || (i+1)%5 == 0)) {
        stroke(textColor);
        strokeWeight(1);
        line(x + scalerW * i + 0.5*scalerW, y, x + scalerW * i + 0.5*scalerW, y+3);
        noStroke();
        text((agileModel.YEAR_0+i), x + scalerW * (i+.5) + 1, y + 15);
      }

      
      // Draw Global Manufacturing Capacity
      if (gameMode) {
        noFill();
        if (i <= session.current.TURN) {
          stroke(textColor);
        } else {
          stroke(abs(textColor-100));
          cap = globalCap;
          capLast = globalCap;
        }
        strokeWeight(1.5);
        // Draw Vertical line
        line(x + scalerW * (i-0), y - cap, x + scalerW * (i-0), y - capLast);
        // Draw Horizontal line
        line(x + scalerW * (i-0), y - cap, x + scalerW * (i-0) + scalerW, y - cap);
        noStroke();
      }
       // Draw Time Details
    
}

if (gameMode) {
      float barA = 0;
      float cap = 0;
      if (session.current.TURN > 0) {
        cap = profile.demandProfile.getFloat(2, session.current.TURN-1);
        barA = scalerH * cap;
      }
      fill(abs(textColor - 50));
      float X, Y;
      if (detail) {
        Y = y - barA;
      } else {
        Y = y - h;
      }
      X = x + scalerW * (min(numBars, session.current.TURN)) - 3;
      if (detail) {
        rect(X, Y, 4, max(3, barA) );
      } else {
        fill(FISCAL);
       if (session.current.TURN != timeLead) rect(X, Y, 3, h ); //this is the game moving rectangle
      }
      if (detail) {
        fill(abs(textColor - 150));
        rect(X+1, y, 2, 35);
        fill(textColor);
        textAlign(LEFT);
        text(int(cap/100)/10.0 + agileModel.WEIGHT_UNITS, X, Y-5);
        textAlign(CENTER);
        text((agileModel.YEAR_0 + session.current.TURN), X, y + MARGIN);
      }
    }
    
    // Y-Axis for Large-scale graphic
    if (detail) {
      float unit = profile.demandPeak_F/3;
      stroke(textColor, 20);
      strokeWeight(1);
      for (int i=0; i<=int(forecastScalerH*profile.demandPeak_F/unit); i++) {
        line(x, y - scalerH*i*unit, x+w, y - scalerH*i*unit);
        fill(textColor, 50);
        textAlign(RIGHT);
        text(i*int(unit/100)/10.0 + agileModel.WEIGHT_UNITS, x + w + 35, y - scalerH*(i-0.25)*unit);
      }
    }

    }
   
   void mouseClicked(){
     if(isOver()){
       selected = !selected;
     }
   }
    
    boolean isOver(){
        if(mouseX >= x  && mouseY >= y - h/2 && mouseX <= x + w && mouseY <= y + h/2){
      return true;
    } else {
      return false;
    }
    }


}

