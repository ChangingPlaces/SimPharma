void setup(){
println( javaVersionName );
println( System.getProperty("java.home")  + "\n" );
 
println( System.getProperty("os.arch") );
println( System.getProperty("os.name") );
println( System.getProperty("os.version") + "\n" );
 
println( System.getProperty("user.home") );
println( System.getProperty("user.dir")   + "\n" );
 
println( sketchPath );
println( dataPath("") );
 
exit();
}

void draw(){}
