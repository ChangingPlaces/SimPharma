
class LineGraph{
  float minx, miny, h, w;
  int num_intervals;
  ArrayList<ArrayList<Float>> Values = new ArrayList<ArrayList<Float>>();

  color[] colarray = new color[5];

  
  LineGraph( ArrayList<ArrayList<Float>> _Values, float _x, float _y, float _w, float _h, int _num_intervals){
    Values = _Values;

    minx = _x;
    h = _h/2;
    miny = _y + _h;
 
    w = _w;
    num_intervals = _num_intervals;
      colarray[0] = color(255, 0, 0);
      colarray[1]=  color(0, 255, 0);
      colarray[2]=  color(0, 255, 255);
      colarray[3]=  color(0, 0, 255);
      colarray[4]=  color(200, 0, 255);
  }
  
  void draw(){
    float posx, posy, posx2, posy2;
    try{
  //  for(int i = 0; i<Values.size(); i++){
    for(int i = 0; i<5; i++){
        noStroke();
       fill(colarray[i]);
       rect(minx + i*w/4.5 + 10, miny - h - 50, 10, 10);
       fill(textColor);
       textAlign(LEFT);
       textSize(textSize-1);
       text(kpi.names.get(i), minx + i*w/4.5 + 22, miny - h - 40);
      for(int j = 0; j<19; j++){
        
         posx  = j*(w/num_intervals) + minx; 
         posy = map(Values.get(i).get(j), 100, 1000, miny, miny - h - 20);
        
         posx2  =  (j+1)*(w/num_intervals) +  minx;
         posy2 = map(Values.get(i).get(j+1), 100, 1000,  miny, miny - h - 20); 

         fill(textColor);
         strokeWeight(1);
         stroke(colarray[i]);
         line(posx, posy, posx2, posy2);
         
      }
    }
  }
  
  catch(Exception e){}
  stroke(textColor);
  line(minx, miny, minx + w, miny);
  line(minx, miny, minx, miny - h + 20);
          
}
}

