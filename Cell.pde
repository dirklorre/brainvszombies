class Cell {
  
 
 int randomaction = 10;// Percentage of actions that are random, to stimulate learning and avoiding local min. 
 int antenna = 40; //lenght of antenna
 float r = 60;// size of cell
 color c = color(0,256, 0, 100);
 float health = 5120; //startng health of living cells
 float zombiespeed = 0.5;
 int killlimit = 2000; //inimum level of health cell need to avoid being killed. If you make it higher it speeds up the process of selection. 
 int splitlimit = 10000; // above this health limit the cell will split (if maximum allowed cells is not exceded. 
  
  
  PVector pos; // central location of the cell
  PVector m; // location of the mouth.
  PVector ant; // location of top of antenna
  float hurt; // angle betreen the mouth and the location where the cell is hurt. = 0 when not hurt
  float love; // angle tween mouth and where the cell touches an other cell. 
  int touch; // angle
  boolean l;
 

  // moving parameters 
  float direction;// int between 0 and 360 =the direction of the cell
  float actionrot = 0; //rotational change to direction
  float forebackwards = 0; // move forewards or backwards. 
  float actionx; // movement translated into x move
  float actiony;// movement translated into y move

  //Status parameters

   int maxIndex; 
  float prevhealth;
  float predicthealth;
  float learning; 
  float perform;
  int name = 0;
  int father = 0;
  float eat;
  float  beeneaten; 
  boolean toDelete ;
  boolean split;
  boolean type = false;// to make the distinction between zombies and cells;
  boolean zombietouch = false;//has the zombiecell been attacked
  
  
  //IQ measurement. rolling average of prediction accuracity in case of cell zombie interaction.
  int iqN = 100; // number of measurements.
  int iqindex = 0;
  float[] iqarray = new float [iqN];
  float iq;
  
void iqcal(){
   iq -= iqarray[iqindex];
   iqarray[iqindex] = this.error;
   iq += iqarray[iqindex];
   iqindex +=1;
   if (iqindex >= iqN) {
       iqindex =0;
   }
}

 Cell() {
    this.pos  = new PVector(random(width), random(height));
    this.m = new PVector();
    this.ant = new PVector();
    this.direction = random (0,359);
    this.name = totalborncells; 
    initialisebrain();
  }

  Cell(float[][][] newbrain,  int n){
    this.father = n;
     initialisebrain ();
    this.weights = newbrain;
    this.pos  = new PVector(random(width), random(height));
    this.m = new PVector();
    this.ant = new PVector();
    this.direction = random (0,359);
    this.name = totalborncells +1; 
  }
  
boolean clicked(int x, int y) {
    float d = dist(this.pos.x, this.pos.y, x, y);
    if (d < this.r) {
      return true;
    } else {
      return false;
    }
  }

// function to calculate the angle when cells touch each other; normally mouth, center of cell, other mouth
float angle(PVector v1, PVector v, PVector v2) { 
  float a = atan2(v2.y-v.y, v2.x-v.x) - atan2(v1.y-v.y, v1.x - v.x);
  if (a < 0) a += TWO_PI;
  return a; 
}

boolean eaten(Cell other) {
  
    //hurt is the angle between the mouth and where the cell is eaten. 
    
    float d= dist (this.pos.x,this.pos.y, other.m.x,other.m. y);
    if ( (d < r/8 + other.r/2)&&(this != other)) {
      this. hurt =  degrees (angle(this.m,this.pos,other.m));
      if (this.hurt >180) { this.hurt = this.hurt -360;}
      return true;
    }
  else {
    return false;
   }}
   
  boolean eat(Cell other) {
    
   
    float d = dist (this.m.x,this.m.y, other.pos.x,other.pos. y);
    if ( (d < r/8 + other.r/2)&&(this != other)) {
      return true;
     }
  else {
    return false;
   }    
}

boolean loved (Cell other){
   // love = cells touches each other, love is the angle of the touch.
    float l = dist (this.pos.x,this.pos.y, other.pos.x, other.pos. y);
    if (l< (this.r/2 + other.r/2)){
      this. love =  degrees (angle(this.m,this.pos,other.pos));
      return true;
      
       }
    else {
    return false;
        }    
   
}

boolean sense(Cell other) {
 
 float s = dist (this.ant.x,this.ant.y, other.pos.x,other.pos. y);
    if ( s < other.r/2)  {
  return true;
  }
  else {
    
    return false;
   }    
}
void lookatbrain (Cell hero ){
   int p = 0;
   fill(100);
   for (int i = 1; i <NN.length-1; i++) {//layers start with 1
       for (int j= 0; j <NN[i]; j++) {// for all nodes in layer i
           for (int k= 0; k <NN[i-1]; k++) {// all weights to the previous layer
               text (nfs(hero.weights[i][j][k],1,7),100, p);
               p +=10;
            }
        }
     }
 }
   
void checkdeath (){
  if (this.health <killlimit){
    this.toDelete = true;
  }
  if (this.health > splitlimit){
    this.split = true;
  }
} 
  void zombiemove(){
    this.actionrot = 0;
    if (this.zombietouch){
     this.forebackwards = zombiespeed;     
     this.actionrot =  -this.hurt%360/90; 
  }
  } 
 
  void move(){     
     this.direction = this.direction + actionrot;
     this.direction = this.direction%360;

     this.actionx =  this.forebackwards*cos (radians (direction));
     this.actiony  = this. forebackwards*sin (radians (direction));
      this.pos.x = this.pos.x + this.actionx;
     this.pos.y = this.pos.y + this.actiony;
      }
  
  void checkborder(){  //makes the cells experience no borders...   
   if ((this.pos.x) < 0 ){
      this.pos.x += width;
    }
    if ((this.pos.x) > width ){
      this.pos.x -= width;
    }
     if ((this.pos.y) < 0 ){
      this.pos.y += height;
    }
    if ((this.pos.y) > height){
      this.pos.y -= height;
    }}
  
  void show() {
    float red = (255-(this.health/2)/10);
    float green = (this.health/2)/10; 
    noStroke();
    fill(color (red, green, 0)); // color follows health, red = near death
    ellipse(this.pos.x, this.pos.y, this.r, this.r);
    this.m.x = this.pos.x + this.r * (cos (radians (direction)))/2;
    this.m.y = this.pos.y + this.r * (sin (radians (direction)))/2;
    this.ant.x = this.pos.x + (this.r + antenna) * ((cos (radians (direction)))/2);
    this.ant.y = this.pos.y + (this.r + antenna) * ((sin (radians (direction)))/2);
    if (type == true){ // if it is a living cell
    fill (150,0,150);}
    else { // if it is a zombie cell
    fill (255,255,255);}
    ellipse(this.m.x, this.m.y, this.r/4, this.r/4);
    fill (50,0,0);
    stroke (126);
    line (this.m.x,this.m.y, this.ant.x, this.ant.y);
    fill (0,0,0); 
    textSize (12);
    text ("N:" + this.name, this. pos.x -10, this.pos.y +9);
    if (type == false){ 
       text ("H:"+ (int)this.health, this.pos.x - 10,this.pos.y -15);
       text ("IQ:"+(int)this.iq, this.pos.x - 12,this.pos.y -3);
       text ("F:"+ this.father, this.pos.x -10, this.pos.y +21);
       }
     }
    
 ////////////////////////////////////////////////////////////   
 
 /*
 The agent asks the brain to calculate the health change the different moves will bring. It then takes the action with the expected highest gain of health. 
 */
void agent(){
    float [][] actions = {{1, 0},{0,0},{-1, 0}, {0,1},{0, -1}};// these are the actions, the first int is about the back and forward movement, the second about the rotation. 
    float [] evaluations = new float [actions .length];
    feedforward();
    for (int a = 0; a < actions .length; a++){
        evaluations [a] =outcomes [NN.length -1][a];}
      // calculate predicted results of all pairs of actions    
    float max = 0; 
    this. maxIndex =0;
    int a = 0;
    for(a = 0; a < actions .length; a++){
        if(max < evaluations[a]){
            max = evaluations[a];
            maxIndex = a;
        }
     }
    // Add some random behavior
    int chance = new Random().nextInt(100);
    if (chance < randomaction){
        maxIndex = new Random().nextInt(actions .length);
    }
    this.forebackwards = (actions[maxIndex][0]);     
    this. actionrot =   (actions[maxIndex][1]); 
    this.predicthealth = (float) evaluations[maxIndex];
 
   // calculate again the right inputs for the backprop
 //  feedforward(actions[maxIndex][0],actions[maxIndex][1]);
}
 
 /// Brainfunctions
 float sigmoid(float x)
{
    return (float) (1 / (1 + Math.exp(-x)));
}

// int [] NN = new int []{8, 5,5, 1,};  definiton of brainsize, Is defined globally
float cc = 1;// (learning factor)
float [][][] weights;
float [][] outcomes;
float [][] deltas;
 
void initialisebrain (){
    outcomes = new float [NN.length][];
    deltas = new float [NN.length][];
    weights = new float [NN.length][][];
    for (int i = 0; i < NN.length; i++){//for all layer
        outcomes [i] = new float [NN[i]];
        deltas [i] = new float [NN[i]];
     }
     for (int i = 1; i < NN.length; i++){//for all layers except first = input
         weights[i] = new float [NN[i]][NN[i-1]];
     }
    // weight initialisation
    for (int i = 1; i < NN.length; i++) {//layers start with 1
        for (int j= 0; j < NN[i]; j++) {// for all nodes in layer i
            for (int k= 0; k < NN[i-1]; k++) {// all weights to the previous layer
                weights[i][j][k] = random(-1,1);
            }
        }
    }
}

void   feedforward (){ // a and b are the actions chosen by the agent.
    // below is the list of information we feed the brain to predict the healthgain  of the possible moves. 
    // We could call it "inputs" but by calling it outcomes we make the feedforward formula the same for all layers. 
    outcomes [0] [0] =  (this.direction)/360;
    outcomes [0] [1] =  (this.hurt)/360;
    outcomes [0] [2] = this.eat;
    outcomes [0] [3] = this.beeneaten; 
 //   outcomes [0] [4] = a;
//    outcomes [0] [5] = b;
    outcomes [0] [4] = this.touch;//(this.love)/360;  // touch
    outcomes [0] [5] = 1; //bias
  
  
for (int i = 1; i < NN.length; i++) {//layers start with 1
    for (int j= 0; j < NN[i]; j++) {// for all nodes in layer i
        outcomes[i][j] = 0; 
        for (int k= 0; k < NN[i-1]; k++) {// all weights to the previous layer
            outcomes[i][j] += outcomes[i-1][k]*weights[i][j][k];}
            outcomes[i][j] = sigmoid (outcomes[i][j]);
            if (i != NN.length-1) { outcomes [i][0] = 0.9;}// bias but not for the last layer = the outcome. 
            }
        }
  //      return outcomes [NN.length -1][0]; //normally there is only one outcome, but we have the possibility to calculate several outcomes. 
     }
float error = 0;
void backpropagate(){ 
    // setting  the reality  
    float [] Correction = new float [NN[NN.length-1]];
    for (int k = 0; k <NN[NN.length-1]; k++){
      Correction[k] = outcomes [NN.length-1][k];}
    if (this.health >this.prevhealth) {Correction[this.maxIndex] = 1;
    }
    if (this.health <this.prevhealth) {Correction[this.maxIndex] = -1;
    }
    else {Correction[this.maxIndex] = this.outcomes[NN.length-1][maxIndex];
    }
    this.learning = (float)Correction [0];
   //}  // learning used to calculate the iq of a cell


    // calculating the error
    //outerlayer first
    this.error = 0;
    for (int k = 0; k <NN[NN.length-1]; k++){
        this.deltas[NN.length-1][k] = (this.outcomes[NN.length-1][k]-Correction [k])* this.outcomes[NN.length-1] [k]*(1-this.outcomes [NN.length-1] [k]);
        this.error += sq( outcomes[NN.length-1][k]-Correction [k])/2 ;
      if (this.health <this.prevhealth){ println (this.outcomes[NN.length-1][k]-Correction [k]);}
        
    }
    // other layers
    for (int i = NN.length -2; i >0; i--){// from the layer before the outputlayer till the first layer (zero is input)
        for (int j = 0; j < NN[i]; j++) {//for all the nodes in this layer
           float sum = 0;
            for (int k = 0; k < NN[i+1]; k++) {//for all the weights linked to these nodes
                sum = sum + this.deltas[i+1][k]*this.weights [i+1][k][j];
            }
           this.deltas [i][j] = this.outcomes [i][j]*(1- this.outcomes[i][j])* sum;
        }
    }
    // adjusting weigths
    // outer layer
   for (int k = 0; k <NN[NN.length-1]; k++){
       for (int j= 0; j < NN[NN.length-2]; j++) {
           this. weights[NN.length-1][k][j] = this.weights[NN.length-1][k][j] -cc*this.outcomes [NN.length-2][j]*this.deltas [NN.length-1][k];
        }
    } 
    //other layers
    for (int i = NN.length -2; i >0; i--){  
       for (int j = 0; j < NN[i]; j++) {
           for (int l= 0; l < NN[i-1]; l++) {
               this.weights[i][j][l] =this. weights[i][j][l] -cc*this.outcomes [i-1][l]*this.deltas [i][j];
            }
        }
     } 
   }
}
