void checkDrag(){
//    int numProfiles;
//    if (!gameMode) {
//      numProfiles = agileModel.PROFILES.size();
//        for(int i =0; i<numProfiles; i++){
//          if(mouseX <= agileModel.PROFILES.get(i).iconX + agileModel.PROFILES.get(i).iconW && mouseX >= agileModel.PROFILES.get(i).iconX
//          && mouseY <= agileModel.PROFILES.get(i).iconY + agileModel.PROFILES.get(i).iconH && mouseY >= agileModel.PROFILES.get(i).iconY){
//            session.setProfile(i);
//          }
//        }
//    } else {
//      numProfiles = agileModel.activeProfiles.size();
//            for(int i =0; i<numProfiles; i++){
//          if(mouseX <= agileModel.activeProfiles.get(i).iconX + agileModel.activeProfiles.get(i).iconW && mouseX >= agileModel.activeProfiles.get(i).iconX 
//          && mouseY <= agileModel.activeProfiles.get(i).iconY + agileModel.activeProfiles.get(i).iconH && mouseY >= agileModel.activeProfiles.get(i).iconY){
//            session.setProfile(i);
//            deploySelection();
//        }  
//    }
//    }
}



//float bx;
//float by;
//int bs = 20;
//boolean bover = false;
//boolean locked = false;
//float bdifx = 0.0; 
//float bdify = 0.0; 

//
//void setup() 
//
//{
//  size(200, 200);
//  bx = width/2.0;
//  by = height/2.0;
//  rectMode(CENTER);  
//
//}
//
//
//
//void draw() 
//
//{ 
//  background(0);
//
//  // Test if the cursor is over the box 
//  if (mouseX > bx-bs && mouseX < bx+bs && mouseY > by-bs && mouseY < by+bs) {
//      bover = true;  
//      if(!locked) { 
//        stroke(255); 
//        fill(153);
//      } 
//    } 
//    
//    else {
//      stroke(153);
//      fill(153);
//      bover = false;
//    }
//
//  // Draw the box
//  rect(bx, by, bs, bs);
//}
//
//
//
//void mousePressed() {
//  if(bover) { 
//    locked = true; 
//    fill(255, 255, 255);
//
//  } else {
//    locked = false;
//  }
//
//  bdifx = mouseX-bx; 
//  bdify = mouseY-by; 
//}
//
//
//
//void mouseDragged() {
//  if(locked) {
//    bx = mouseX-bdifx; 
//    by = mouseY-bdify; 
//  }
//}
//
//
//
//void mouseReleased() {
//  locked = false;
//}
