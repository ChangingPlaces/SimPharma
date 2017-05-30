
class LineGraph{
  float minx, miny, h, w;
  int num_intervals;
  ArrayList<ArrayList<Float>> Values = new ArrayList<ArrayList<Float>>();

  color[] colarray;
    
  
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
    try{
  //  for(int i = 0; i<Values.size(); i++){
    for(int i = 0; i<5; i++){
      int k = 0; 
      for(int j = 0; j<19; j++){
        
         posx  = j*(w/num_intervals) + minx; 
         posy = map(Values.get(i).get(j), 100, 1000, miny, miny - h - 20);
        
         posx2  =  (j+1)*(w/num_intervals) +  minx;
         posy2 = map(Values.get(i).get(j+1), 100, 1000,  miny, miny - h - 20); 

         fill(textColor);
         strokeWeight(1);
         stroke(textColor);
         line(posx, posy, posx2, posy2);
         stroke(textColor);
      }
    }
  }
  
  catch(Exception e){}
  stroke(textColor);
  line(minx, miny, minx + w, miny);
  line(minx, miny, minx, miny - h + 20);
          
}
}

