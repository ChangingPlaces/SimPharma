class LineGraph{
  float minx, miny, h, w;
  int num_intervals;
  ArrayList<ArrayList<Float>> Values = new ArrayList<ArrayList<Float>>();
  LineGraph( ArrayList<ArrayList<Float>> _Values, float _x, float _y, float _w, float _h, int _num_intervals){
    Values = _Values;
    minx = _x;
    miny = _y + _h ;
    h = _h;
    w = _w;
    num_intervals = _num_intervals;
  }
  
  void draw(){
    float posx, posy, posx2, posy2;
    for(int i = 0; i<Values.size(); i++){
        println(Values.get(i).size());
      int k = 0;
      for(int j = 0; j<Values.get(i).size()-1; j++){
        
         posx  = k + k*(w/num_intervals) + minx;
         posy = map(Values.get(i).get(j), 0, 1000, miny, miny - h - 20);
         k+=1;
         posx2  = k + 1 +k*(w/num_intervals) + minx;
         posy2 = map(Values.get(i).get(j+1), 0, 1000,  miny, miny - h - 20);
//         println(posx, posy);
         fill(textColor);
         ellipse(posx, posy, 5, 5);
         ellipse(posx2, posy2, 5, 5);
         
         stroke(textColor);
         strokeWeight(1);
         line(posx, posy, posx2, posy2);
         
         line(minx, miny, minx + w, miny);
         ellipse(minx, miny, 5, 5);
         line(minx, miny, minx, miny - h + 20);
          
      }
    }
    
  }
}
 
