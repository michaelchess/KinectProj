import SimpleOpenNI.*;

SimpleOpenNI context;
ArrayList<Double> horizontalTheta = new ArrayList();
ArrayList<Double> verticalTheta = new ArrayList();
void setup(){
  background(175);
  size(640*3, 480*2);
  context = new SimpleOpenNI(this);
  if(context.isInit() == false){
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  context.setMirror(false);
  context.enableDepth();
  context.enableRGB();
  context.alternativeViewPointDepthToImage();
  context.setDepthColorSyncEnabled(true);
  context.depthImage().loadPixels();
  context.rgbImage().loadPixels();
  
  for(int i = 0; i < 640; i++){
    double a = 640;
    double x = i;
    double l = Math.abs((a/2)-x);
    double k = 2/a;
    double h = k*l;
    double theta = Math.atan(h);
    horizontalTheta.add(theta);
  }
  
  for(int i = 0; i < 480; i++){
    double a = 480;
    double x = i;
    double l = Math.abs((a/2)-x);
    double k = 2/a;
    double h = k*l;
    double theta = Math.atan(h);
    verticalTheta.add(theta);
  }
}
int redVal = 0;
int blueVal = 0;
int greenVal = 0;
int i;
ArrayList<Integer> locX = new ArrayList();
ArrayList<Integer> locY = new ArrayList();
ArrayList<Integer> depths = new ArrayList();
ArrayList<PVector> realWorldPoints = new ArrayList();
ArrayList<PVector> blueRealWorldPoints = new ArrayList(); 
//ArrayList<PVector> tempRWP = new ArrayList();
ArrayList<Long> times = new ArrayList();
ArrayList<Long> blueTimes = new ArrayList();
PVector tempRWPAVG = new PVector();
double tempX = 0;
double tempY = 0;
double tempD = 0;
void draw(){
  ArrayList<PVector> tempRWP = new ArrayList();
  ArrayList<PVector> blueTempRWP = new ArrayList();
  PImage  rgbImage = context.rgbImage();
  int[]   depthMap = context.depthMap();
  PVector[] realWorldMap = context.depthMapRealWorld();
  PVector realWorldPoint;
  context.update();
  context.depthImage().updatePixels();
  context.rgbImage().updatePixels();
 // for(int i = 0; i < context.rgbImage().pixels.length; i++){
  outerloop:
  for(int y=0;y < context.depthHeight();y+=1){
    for(int x=0;x < context.depthWidth();x+=1){
      i = x + y * context.depthWidth();
      redVal = (context.rgbImage().pixels[i] >> 16) & 0xFF;
      blueVal = (context.rgbImage().pixels[i] >> 8) & 0xFF;
      greenVal = context.rgbImage().pixels[i] & 0xFF;
      
      if(depthMap[i] > 0){
        if(redVal > 175 && blueVal < 100 && greenVal < 100){
        //println(redVal+" "+blueVal+" "+greenVal);
          realWorldPoint = realWorldMap[i];
          //println(frameCount+" "+realWorldPoint.x+" "+realWorldPoint.y+" "+realWorldPoint.z);
          //println(frameCount+" "+xCoord(x, depthMap[i])+" "+yCoord(y, depthMap[i])+" "+depthMap[i]);
          //println(depthMap[i]+" "+realWorldPoint.z);
          locX.add(x);
          locY.add(y);
          depths.add(depthMap[i]);
          //realWorldPoints.add(realWorldPoint);
          tempRWP.add(realWorldPoint);
          tempX += realWorldPoint.x;
          tempY += realWorldPoint.y;
          tempD += realWorldPoint.z;
          //times.add(System.currentTimeMillis());
          //point(x+1280, y);
          //println(x+" "+y+" "+depthMap[i]);
          int pigment = (2*frameCount)%255;
          stroke(pigment, 0, 0);
          fill(pigment, 0, 0);
          ellipse(x+1280, y, 5,  5);
          //break outerloop;
        }
        if(blueVal >250 && redVal < 50 && greenVal < 50){
          realWorldPoint = realWorldMap[i];
          println(frameCount+" "+realWorldPoint.x+" "+realWorldPoint.y+" "+realWorldPoint.z);
          blueTempRWP.add(realWorldPoint);
          blueTimes.add(System.currentTimeMillis());
          int pigment = (2*frameCount)%255;
          stroke(0, 0, pigment);
          fill(0, 0, pigment);
          ellipse(x+1280, y, 5,  5);
        }
      }
    }
  }
  if(tempX != 0 && tempY != 0 && tempD != 0){
    //println(frameCount+": "+tempX/tempRWP.size()+" "+(float)tempY/tempRWP.size()+" "+(float)tempD/tempRWP.size());
    tempRWPAVG.set((float)tempX/(float)tempRWP.size(), (float)tempY/(float)tempRWP.size(), (float)tempD/(float)tempRWP.size());
    //println(tempRWPAVG);
    ellipse((int)(tempX/(int)tempRWP.size())+1280, (int)tempY/(int)tempRWP.size(), (int)5, (int)5);
    realWorldPoints.add(new PVector(tempRWPAVG.x, tempRWPAVG.y, tempRWPAVG.z));
    times.add(System.currentTimeMillis());
    if(times.size() > 2){
      double deltTime = times.get(times.size()-1)-times.get(times.size()-2);
      double Dist = realWorldPoints.get(realWorldPoints.size()-1).dist(realWorldPoints.get(realWorldPoints.size()-2))/1000;
      double vel = Dist/deltTime;
      print("velocity: "+vel+" ");
      println(1000*vel);
      ellipse(4*frameCount, 960-(((float)vel)*20000), 10, 10);
      fill(175);
      stroke(175);
      rect(1450, 400, 2000, 550);
      fill(255);
      textSize(24);
      text("Avg Velocity: "+getAvgVel(), 1500, 500);
    }
    //println(realWorldPoints);
  }
  fill(255);
  text("0 m/s", 0, 940);
  text("2.4 m/s", 0, 500);
  image(context.depthImage(), 0, 0);
  image(context.rgbImage(), 640, 0);
  textSize(16);
  text("Frame rate: " + int(frameRate), 10, 20);
  
  
  
  tempX = 0;
  tempY = 0;
  tempD = 0;
}

ArrayList<Double> velocities = new ArrayList();
ArrayList<Double> rwpVelocities = new ArrayList();
int deltaX;
int deltaY;
int deltaZ;
double deltaTime;
double dPos;
double deltaPos;
double deltaLocation;
double rwpDist;
double FOV = 2*Math.toRadians(57);
double getAvgVel() {
  //saveFrame();
  println("mousePressed:"+ realWorldPoints.size());
  print(realWorldPoints);
  for(int k = 1; k < realWorldPoints.size(); k++){
    deltaTime = (double)(times.get(k)-times.get(k-1))/1000;
    dPos = posChange(locX.get(k), locX.get(k-1), locY.get(k), locY.get(k-1), depths.get(k), depths.get(k-1));
    deltaPos = dPos/1000;
    //println(deltaPos/deltaTime);
    velocities.add(deltaPos/deltaTime);
    rwpDist = realWorldPoints.get(k).dist(realWorldPoints.get(k-1))/1000;
    //println(deltaPos+" "+rwpDist);
    rwpVelocities.add(rwpDist/deltaTime);
  }
  double sumVelocities = 0;
  double sumRWPVelocities = 0;
  float tempRWPVelocity = 0;
  for(int j = 0; j < rwpVelocities.size(); j++){
    sumVelocities+=velocities.get(j);
    tempRWPVelocity = 0;
    tempRWPVelocity += rwpVelocities.get(j);
    fill(255, 0, 0);
    stroke(255, 0, 0);
    //ellipse(4*j, 960-(tempRWPVelocity*20), 10, 10);
    if(rwpVelocities.get(j) < 5){
      sumRWPVelocities+=rwpVelocities.get(j);
    }
    //println(velocities.get(j)+" "+rwpVelocities.get(j)+" ");
    //println(velocities.get(j)/r wpVelocities.get(j));
  }
  //print(velocities);
  //println((sumVelocities/velocities.size()));
  return sumRWPVelocities/rwpVelocities.size();
}
void mousePressed() {
  //saveFrame();
  println("mousePressed:"+ realWorldPoints.size());
  print(realWorldPoints);
  for(int k = 1; k < realWorldPoints.size(); k++){
    deltaTime = (double)(times.get(k)-times.get(k-1))/1000;
    dPos = posChange(locX.get(k), locX.get(k-1), locY.get(k), locY.get(k-1), depths.get(k), depths.get(k-1));
    deltaPos = dPos/1000;
    //println(deltaPos/deltaTime);
    velocities.add(deltaPos/deltaTime);
    print(k+" ");
    print(realWorldPoints.get(k));
    println(realWorldPoints.get((k-1)));
    rwpDist = realWorldPoints.get(k).dist(realWorldPoints.get(k-1))/1000;
    //println(deltaPos+" "+rwpDist);
    rwpVelocities.add(rwpDist/deltaTime);
    print(rwpDist+" ");
    println(rwpDist/deltaTime);
  }
  double sumVelocities = 0;
  double sumRWPVelocities = 0;
  float tempRWPVelocity = 0;
  for(int j = 0; j < rwpVelocities.size(); j++){
    sumVelocities+=velocities.get(j);
    tempRWPVelocity = 0;
    tempRWPVelocity += rwpVelocities.get(j);
    fill(255, 0, 0);
    stroke(255, 0, 0);
    ellipse(4*j, 960-(tempRWPVelocity*20), 10, 10);
    if(rwpVelocities.get(j) < 5){
      sumRWPVelocities+=rwpVelocities.get(j);
    }
    //println(velocities.get(j)+" "+rwpVelocities.get(j)+" ");
    //println(velocities.get(j)/r wpVelocities.get(j));
  }
  //print(velocities);
  //println((sumVelocities/velocities.size()));
  println((sumRWPVelocities/rwpVelocities.size()));//*2.23694
  println((realWorldPoints.get(realWorldPoints.size()-1).dist(realWorldPoints.get(1))/1000)/(times.get(realWorldPoints.size()-1)-times.get(1)));
  println("end mousePressed");
}

double xCoord(int x, double d){
  double ht = horizontalTheta.get(x);
  return d*Math.tan(ht);
}
double yCoord(int y, double d){
  double vt = verticalTheta.get(y);
  return d*Math.tan(vt);
}
double posChange(int x1, int x2, int y1, int y2, double d1, double d2){
  double ht1 = horizontalTheta.get(x1);
  double ht2 = horizontalTheta.get(x2);
  double vt1 = verticalTheta.get(y1);
  double vt2 = verticalTheta.get(y2);
  double dX = d1*Math.sin(ht1)-d2*Math.sin(ht2);
  double dY = d1*Math.sin(vt1)-d2*Math.sin(vt2);
  /*double dhD = d2*Math.cos(ht2)-d1*Math.cos(ht1);
  double dvD = d2*Math.cos(vt2)-d1*Math.cos(vt1);
  //double dD = (dhD+dvD)/2;
  double dD = d2-d1;
  double change = Math.sqrt((dX*dX)+(dY*dY)+(dD*dD));*/
  double change = Math.sqrt((dX*dX)+(dY*dY)+((d1-d2)*(d1-d2)));
  return change;
}

