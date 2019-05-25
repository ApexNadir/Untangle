class Point{
  float x,y;
  Point(){
    x=y=0;
  }
  Point(float x1,float y1){
    x=x1;
    y=y1;
  }
}


class Line{
  float m,c;
  boolean isVert=false;
  boolean isPoint=false;
  float isPointx,isPointy;
  Line(){
    m=0;
    c=0;
  }
  Line(float nm,float nc){
    m=nm;
    c=nc;
  }
  Line(Point p1,Point p2){
    genLine(p1,p2);
  }
  private void genLine(Point p1,Point p2){
    isPoint=false;
    isVert=false;
    if(p1.x==p2.x && p1.y == p2.y){
      isPoint = true;
      isPointx=p1.x;
      isPointy=p1.y;
      return;
    }
    float dy,dx;
    dy=(p2.y-p1.y);
    dx=(p2.x-p1.x);
    if(dx==0){
      isVert=true;
      c=p1.x;
      return;
    }
    m=dy/dx;
    c=p1.y-p1.x*m;
  }
  Point intersect(Line l2){
    if(isPoint||l2.isPoint){
      if(isPoint&&l2.isPoint){
        //println("WEIRD1");
        return null;
      }
      Line p, l;
      if(isPoint){
        p=this;
        l=l2;
      }else{
        p=l2;
        l=this;
      }
      if(p.isPointy==l.m*p.isPointx+l.c){
        return new Point(p.isPointx,p.isPointy);
      }else{
        //println("WEIRD2");
        return null;
      }
    }
    if(m==l2.m){
        //println("WEIRD3");
      return null;
    }
    if(isVert||l2.isVert){
      Line v,l;
      if(isVert){
        v=this;
        l=l2;
      }else{
        v=l2;
        l=this;
      }
      Point out = new Point();
      out.x=v.c; 
      out.y=l.m*out.x+l.c;
       // println("WEIRD4");
      return out;
    }
    //println("here");
    Point out = new Point();
    //println(m + "x + " + c + " = " + l2.m + "x + " + l2.c);
    out.x=(c-l2.c)/(l2.m-m);
    out.y=m*out.x+c;
    return out;
  }
}



class Node extends Point{
  int ID;
  ArrayList<Edge> edges=new ArrayList<Edge>();
  Node(){
    x=y=0;
  }
  Node(float x1,float y1){
    x=x1;
    y=y1;
  }
  void drawN(){
    strokeWeight(2);
    stroke(0);
    int r=30;
    ellipse(x,y,r,r);
    fill(0);
    //text(ID,x,y-10);
    fill(255);
  }
  
}

class Edge extends Line{
  int ID;
  boolean intercepts=false;
  boolean bad=false; ////                      ---debug
  Point interbad;
  Edge interedge;
  Node n1,n2;
  Edge(Node n1n,Node n2n){
    n1=n1n;
    n2=n2n;
    super.genLine(n1,n2);
  }
  void updatePos(){
    super.genLine(n1,n2);
  }
  void drawE(){
    strokeWeight(3);
    stroke(50);
    if(bad){stroke(255,0,0);}
    if(!intercepts){stroke(0,255,0);}
    if(N.solved){
      stroke(255,225,0);
    }
    line(n1.x,n1.y,n2.x,n2.y);
    if(bad){
      //ellipse(interbad.x,interbad.y,20,20);
      
      //stroke(0,0,255);
      //text(n1.ID,interbad.x,interbad.y);
      //interedge.drawE();
    
    }
    stroke(0);
  }
  
  boolean commonNode(Edge e2){
    if(n1.ID==e2.n1.ID || n1.ID==e2.n2.ID || n2.ID==e2.n1.ID || n2.ID==e2.n2.ID){
      return true;
    }else{
      return false;
    }
  }
}

class NodeSet{
  int nodeCount;
  boolean scored=false;
  boolean solved=false;
  boolean cheated=false;
  ArrayList<Node> nodeList;
  ArrayList<Edge> edgeList;
  Point[] originalNodePos;
  
  void generatePuzzle(int nodeCount2, int maxEdgesPerNode){
    cheated=false;
    solved=false;
    scored=false;
    nodeCount=nodeCount2;
    nodeList = new ArrayList<Node>();
    edgeList = new ArrayList<Edge>();
    
    for(int n=0;n<nodeCount;n++){//for every new node
      Node nn=new Node(random(0,width),random(0,height));
      assignID(nn);
      nodeList.add(nn); //make node
      for(int n2=0;n2<nodeList.size()-1;n2++){//for every other node 
        Edge newEdge = new Edge(nn,nodeList.get(n2)); //compare new node and other nodes edges
        boolean goodEdge=true;
        for(int e=0;e<edgeList.size();e++){
          if(intersects(newEdge,edgeList.get(e))){
            goodEdge=false;
            break;
          }
        }
        if(goodEdge){
          assignID(newEdge);
          edgeList.add(newEdge);
        }else{///REMOVE ELSE, DONT ADD EDGE THAT INTERCEPTS ---- ADDED FOR DEBUG
          //newEdge.bad=true;
          //edgeList.add(newEdge);
        }
      }
    }
    reduceEdges(maxEdgesPerNode);
    
    originalNodePos= new Point[nodeList.size()];
    for(int i=0;i<nodeList.size();i++){
      originalNodePos[i] = new Point(nodeList.get(i).x, nodeList.get(i).y);
    }
    randomise();
    if(solved){generatePuzzle(nodeCount,maxEdgesPerNode);}
  }
  
  void reduceEdges(int maxEdges){
    Edge worstEdge=getWorstEdge(maxEdges);
    while(worstEdge!=null){
      edgeList.remove(worstEdge);
      worstEdge=getWorstEdge(maxEdges);
    }
  }
  Edge getWorstEdge(int maxEdges){
    Edge worst=null;
    float score=0;
    for(Edge e:edgeList){
      int n1s,n2s;
      n1s = getEdgesForNode(e.n1).size();
      n2s = getEdgesForNode(e.n2).size();
      int temp=min(n1s,n2s);
      n1s=max(n1s,n2s);
      n2s=temp;
      if(n1s>maxEdges && n2s>2){
        float tscore=n1s+n2s+0.1*n1s*n2s;
        if(tscore>score){
          worst=e;
          score=tscore;
        }
      }
    }
    
    return worst;
  }
  
  void randomise(){
    float r = min(height,width)/2-50;
    for(int i=0;i<nodeList.size();i++){
      Node n = nodeList.get(i);
      n.x = round(width/2 + r*cos(((float)i/nodeList.size())*2*PI));
      n.y = round(height/2 + r*sin(((float)i/nodeList.size())*2*PI));
    }
    updateEdges();
  }
  void updateEdges(){
    updateEdgesPos();
    solved=true;
    for(Edge e : edgeList){
      //println(e.ID + " intercept checked");
      e.intercepts=doesEdgeInterceptOthers(e);
      if(e.intercepts){
        solved=false;
      }
    }
  }
  void updateEdgesPos(){
    for(Edge e : edgeList){
      e.updatePos();
      //println(e.ID + " pos checked");
    }
  }
  
  void solve(){
    cheated=true;
    for(int n=0;n<nodeList.size();n++){
      Node node=nodeList.get(n);
      node.x=originalNodePos[n].x;
      node.y=originalNodePos[n].y;
      updateEdges();
    }
  }
  
  void assignID(Node n){
    int newID=-1;
    boolean uniqueID=false;
    while(uniqueID==false){
      newID++;
      uniqueID=true;
      for(int i=0;i<nodeList.size();i++){
        if(newID==nodeList.get(i).ID){
          uniqueID=false;
          break;
        }
      }
    }
    n.ID=newID;
  }
  void assignID(Edge n){
    int newID=-1;
    boolean uniqueID=false;
    while(uniqueID==false){
      newID++;
      uniqueID=true;
      for(int i=0;i<edgeList.size();i++){
        if(newID==edgeList.get(i).ID){
          uniqueID=false;
          break;
        }
      }
    }
    n.ID=newID;
  }
  
  boolean intersects(Edge e1, Edge e2){
    if(e1.m==e2.m){//parallel doesnt intersect
      return false;
    }
    if(e1.commonNode(e2)){//if they share a node they dont intersect
      //println("Edge 1: " + e1.n1.ID + " , " +  e1.n2.ID);
      //println("Edge 2: " + e2.n1.ID + " , " +  e2.n2.ID);
      return false;
    }
    //println(e1.n1.ID + " to " + e1.n2.ID + " comparing to " + e2.n1.ID + " to " + e2.n2.ID);
    float x1,y1,x2,y2;
    x1=min(e1.n1.x,e1.n2.x)-0.01;
    x2=max(e1.n1.x,e1.n2.x)+0.01;
    y1=min(e1.n1.y,e1.n2.y)-0.01;
    y2=max(e1.n1.y,e1.n2.y)+0.01;
    float x12,y12,x22,y22;
    x12=min(e2.n1.x,e2.n2.x)-0.01;
    x22=max(e2.n1.x,e2.n2.x)+0.01;
    y12=min(e2.n1.y,e2.n2.y)-0.01;
    y22=max(e2.n1.y,e2.n2.y)+0.01;
    Point lineIntersect = e1.intersect(e2);
    if(lineIntersect==null){
      return false;
    }
    float x,y;
    x=lineIntersect.x;
    y=lineIntersect.y;
    if(e1.m==0||e2.m==0){
      //println(x + ", " + y);
    }
    //println(x + ", " + y);
    if(x>=x1 && x<=x2 && y>=y1 && y<=y2 && x>=x12 && x<=x22 && y>=y12 && y<=y22){
      //e1.interbad = lineIntersect;
      //e1.interedge = e2;
      //println("^ BAD");
      return true;
    }else{
      return false;
    }
  }
  ArrayList<Edge> getEdgesForNode(Node n){
    int nodeID = n.ID;
    ArrayList<Edge> out=new ArrayList<Edge>();
    for(int e=0;e<edgeList.size();e++){
      Edge curEdge = edgeList.get(e);
      if(curEdge.n1.ID==nodeID||curEdge.n2.ID==nodeID){
        out.add(curEdge);
      }
    }
    return out;
  }
  
  boolean doesEdgeInterceptOthers(Edge edge){
    boolean goodEdge=true;
    for(int e=0;e<edgeList.size();e++){
      if(intersects(edge,edgeList.get(e))){
        //println("Intercepts");
        goodEdge=false;
        break;
      }
    }
    return !goodEdge;
  }
  void updateEdgesOnNode(Node n){
    ArrayList<Edge> edges=getEdgesForNode(n);
    for(Edge e : edges){
      e.updatePos();
    }
    for(Edge e : edges){
      e.intercepts=doesEdgeInterceptOthers(e);
      //println(e.ID);
    }
  }
  
  int attachedNodeIndex=-1;
  
  void drawN(){
    if(attachedNodeIndex!=-1){
      nodeList.get(attachedNodeIndex).x=mouseX;
      nodeList.get(attachedNodeIndex).y=mouseY;
      nodeList.get(attachedNodeIndex).x=min(width-15,nodeList.get(attachedNodeIndex).x);
      nodeList.get(attachedNodeIndex).x=max(15,nodeList.get(attachedNodeIndex).x);
      nodeList.get(attachedNodeIndex).y=min(height-15,nodeList.get(attachedNodeIndex).y);
      nodeList.get(attachedNodeIndex).y=max(15,nodeList.get(attachedNodeIndex).y);
      //updateEdgesOnNode(nodeList.get(attachedNodeIndex));
      updateEdges();
    }
    if(edgeList==null){return;}
    for(int e=0;e<edgeList.size();e++){
      edgeList.get(e).drawE();
    }
    for(int n=0;n<nodeList.size();n++){
      nodeList.get(n).drawN();
    }
  }
  void attachNodeToMouse(){
    if(edgeList==null){return;}
    int bestNodeIndex=-1;
    float distance=height+width;
    for(int n=0;n<nodeList.size();n++){
      Node node = nodeList.get(n);
      if(dist(node.x,node.y,mouseX,mouseY)<distance){
        distance = dist(node.x,node.y,mouseX,mouseY);
        bestNodeIndex=n;
      }
    }
    if(distance<40){
      attachedNodeIndex= bestNodeIndex;
    }
  }
  
  void detachNodeToMouse(){
    attachedNodeIndex=-1;
  }
  
  void debug(){
    for(int e=0;e<edgeList.size();e++){
      for(int e2=e+1;e2<edgeList.size();e2++){
        println(e + ", " + e2 + " : "  +intersects(edgeList.get(e),edgeList.get(e2)));
      }
    }
  }
  
}


PGraphics UI;
NodeSet N;
void setup(){
  N = new NodeSet();
  //size(1600,900);
  fullScreen();
  UI = createGraphics(width,height);
  score=0;
  nodeCount=4;
}
int nodeCount;
int score;
int startTime;
int puzzleTime;
boolean gameMode=false;
void keyPressed(){
  if(key=='g'){
    gameMode=!gameMode;
    score=0;
    N.generatePuzzle(nodeCount,4);
    puzzleTime=millis();
  }
  
  
  if(key=='r'){
    if(gameMode){score=0;}
    gameMode=false;
    
    //println("======================NEW==========================");
    score=0;
    nodeCount=4;
    startTime=millis();
    puzzleTime=millis();
    N.generatePuzzle(nodeCount,4);
  }
  if(key=='='){
    if(gameMode){score=0;}
    gameMode=false;
    nodeCount++;
    N.generatePuzzle(nodeCount,4);
  }
  if(key=='-'){
    if(gameMode){score=0;}
    gameMode=false;
    nodeCount--;
    if(nodeCount<4){nodeCount++;}
      
    N.generatePuzzle(nodeCount,4);
  }
  if(key=='n'){
    if(gameMode){score=0;}
    gameMode=false;
    //println("======================NEW==========================");
    puzzleTime=millis();
    N.generatePuzzle(nodeCount,4);
  }
  if(key=='s'){
    if(gameMode){score=0;}
    gameMode=false;
    N.solve();
  }
  
  
}

int puzzleSolvedTime=0;
void draw(){
  background(150);
  if(gameMode){
    if(N.solved && !N.cheated && puzzleSolvedTime==0){
      puzzleSolvedTime=millis();
    }
    if(N.solved && !N.cheated && puzzleSolvedTime+5000<millis()){
      puzzleSolvedTime=0;
      N.generatePuzzle(nodeCount,4);
      puzzleTime=millis();
    }
  }
  N.drawN();
  if(!N.cheated && N.solved && !N.scored){
    score++;
    nodeCount++;
    N.scored=true;
  }
  //N.debug();
  UI.beginDraw();
  UI.clear();
  UI.textSize(20);
  UI.fill(100);
  if(gameMode){
    UI.rect(-5,-5,300,180);
  }else{
    UI.rect(-5,-5,300,150);
  }
  UI.stroke(0);
  UI.fill(255);
  UI.text("Nodes: " + N.nodeCount,5,20);
  UI.text("Score: " + score,5,50);
  UI.text("Total Time: " + time(millis()-startTime),5,80);
  UI.text((nodeCount-int(N.solved)) + " nodes Time: " + time(millis()-puzzleTime),5,110);
  if(gameMode){
    String txt = "";
    if(puzzleSolvedTime!=0){
      txt = ", next in " + round(5+float(+(puzzleSolvedTime-millis()))/1000) + "s";
    }
    UI.text("Game Mode On" + txt,5,140);
  }
  UI.endDraw();
  tint(255,200);
  image(UI,0,0);
}

String time(int millis){
  int seconds=millis/1000;
  int minutes=(seconds-seconds%60)/60;
  int hours=(minutes-minutes%60)/60;
  minutes-=hours*60;
  seconds-=minutes*60;
  String h,m,s;
  if(minutes<10){
    m="0"+minutes;
  }else{
    m=""+minutes;
  }
  if(seconds<10){
    s="0"+seconds;
  }else{
    s=""+seconds;
  }
  return hours+":"+m+":"+s;
  
}

boolean mouseHeld=false;
void mousePressed(){
  mouseHeld=true;
  N.attachNodeToMouse();
}

void mouseReleased(){
  mouseHeld=false;
  N.detachNodeToMouse();
}