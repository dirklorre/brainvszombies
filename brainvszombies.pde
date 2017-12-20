
/*
cells with a brain fight zombie cells, or each other. They have a brain and can learn. The cells doing well can split and inherit the brain (the weights of the neural network) of the father. 
The cells can die too, giving way to birth of new cells. 
One can save the brain of a cell and eventually reintroduce it in an other game. 
For entertainment we can show the changing weights as the cells learn. 

Inspired by the "mitosis" example from Daniel Shiffman (youtube, coding train). 
*/

import java.util.Random;

    
PrintWriter output;
/*
NN defines the size of the brains, there are no limits as to the number of nodes or number of layers. 
first int defines the number of input, 
the other ints the number of nodes on each layer. 
*/
int [] NN = new int []{6,5,5,5}; //8,5,5,1 5 actions 
//Some global variables to play with:

int numberofbirths = 10; // maximum number of cells in the screen
int numberofzombies = 3; //number of zombiecells in the screen. Make 0 if you want to play with living cells only. 
float eatvalue  = 3; // the value substracted from health if eaten.
boolean celleatcell = true;// make true if you want the cells to compete with each other. Zombies always compete with cells. If you want no zombies, make numberofzombies zero.


//variables we use
  
 PFont font;
 int cycle; // is the time in our virtual brainvszombie. 
 int numberofCells; // actual number of living cells...
 int totalborncells = 0; // number of cells ever born (we use to give the cells a name)
 int totalbornzombies = 0;
 int look;

 // create the ArrayList
 
 ArrayList<Cell> cells = new ArrayList<Cell>();
 ArrayList<Cell> zombies = new ArrayList<Cell>();// the zombie cells are born, their braincells are declared, but never initialized. 
 
 // giving birth to cells up to the maximum number (numberofbirths)
void fountainoflive (){
  if (cells.size() < numberofbirths) {
     totalborncells += 1;
     cells.add(new Cell()); }
  if (zombies.size() < numberofzombies) {
     totalbornzombies += 1;
     zombies.add(new Cell());
   }
}

void setup() {
  size(700, 700);
font = createFont("Serif-48.vlw",132);
}

/* the draw loop:
- clear the screen
- give birth if necessary
- kill if necessary
- apply the agent of each cell that calculates all possible moves
- apply the movement
- checkborder to make them fit the screen 
- show the cells
- memorize previous health and put the eat, beeneaten,hurt, love and touch variables to 0
- check if the cell has eaten, been eaten, loved or touched by going trough all the zombie variables. 

*/
void draw() {
 background(200);
 fill(100);
 cycle += 1;
 numberofCells = cells.size();
 
 fountainoflive();
 
 for (Cell c : cells) {
     if (c.name == look) {
         c.lookatbrain (c);}
     c.checkdeath ();
     text (numberofCells, 100,50);
     text (cycle/100, 100,100);
     c.agent ();
     c.move();
     c.checkborder();
     c.show(); 
     c.prevhealth = c.health;
     c.eat = 0;
     c.beeneaten = 0;
     c.hurt = 0;
     c.love =0;
     c.touch = 0;
     if (celleatcell){
        for (Cell z : cells) {
           if (c.eat(z)) {
               c.health += eatvalue;
               c.eat += 1;}
           if (c.eaten(z)) { 
               c.health -= eatvalue*1.3; // if the eat and beeneaten have the same value, the cells find a local minimum by sitten on each other, eaten - beeneaten = 0
               c.beeneaten = +1;}
          if(c.sense(z)){
               c.touch = 1;}
          if (c.loved (z))
             {c.l = true;}
          else {
             c.l = false;}
       }
     }
    for (Cell z : zombies) {
       if (c.eat(z)) {
          c.health += eatvalue;
          c.eat += 1;}
      if (c.eaten(z)) { 
          c.health -= eatvalue*1.3; // if the eat and beeneaten have the same value, the cells find a local minimum by sitten on each other, eaten - beeneaten = 0
          c.beeneaten = +1;}
      if (c.sense(z)){
          c.touch = 1;}    
    }
  }
  //check the zombie cells
  for (Cell z : zombies){ 
     z.health = 0;
     z.type = true;
     z.zombietouch = false;
     for (Cell c: cells) 
         {if (z.eaten (c)){
             z.zombietouch = true;}
          }
   z.zombiemove();
   z.move();
   z.checkborder();
   z.show();  
  }
 // the learning loop and measuring performance
 for (Cell c : cells) {
   c.backpropagate ();
   if ((c.eat > 0 ) || (c.beeneaten>0)  || (c.touch> 0)|| (c.l)  ){//
      c.iqcal();}
  }
    
 // killer and splitting loop, backwards because indexes change. 
    for (int i = cells.size()-1; i >= 0; i--) {
        Cell d = cells.get(i);
        if (d.toDelete) {
            cells.remove(i);
        }
        if (d.split && (cells.size() < numberofbirths)){
            d.split = false;
            d.health = d.health/2;
            float [][][] braintemp = d.weights.clone();// make a copy of fathers brain. 
            int tempname = 0;
            if (d.father == 0) {tempname = d.name;}
            else {tempname = d.father;}
            cells.add(new Cell(braintemp, tempname));     
        }
     }
 }


void mousePressed() {// to save the weights of a cell.
   
  for (int l = cells.size()-1; l >= 0; l--) {
    Cell c = cells.get(l);
    if (c.clicked(mouseX, mouseY)) {
      if (key == 's') {
    String n = str(c.name);
      output = createWriter(n+".txt");
     for (int i = 1; i <NN.length; i++) {//layers start with 1
     for (int j= 0; j <NN[i]; j++) {// for all nodes in layer i
         for (int k= 0; k <NN[i-1]; k++) {// all weights to the previous layer
          output.print(c.weights[i][j][k]);
          output.print (",");
         }}}
          output.close();
     
    }
   if (key == 'l') {
   look  = c.name;}
    }
  }
}

void keyPressed() {  
  // If the return key is pressed, save the String and clear it  
  if (key == 'h') { /// Introducing a hero with a well known brain. 


  float [] data ;
  float [][][] braintemp = new float [NN.length][][];
  for (int i = 1; i < NN.length; i++){
  braintemp[i] = new float [NN[i]][NN[i-1]];}
  // Load text file as a String
  String[] stuff = loadStrings("herobrain.txt");
  // Convert string into an array of integers using ',' as a delimiter
  data = float(split(stuff[0], ','));
//  for (int l = 0; l < data.length; l++) {
 
  int index = 0;
  for (int i = 1; i <NN.length; i++) {//layers start with 1
     for (int j= 0; j <NN[i]; j++) {// for all nodes in layer i
         for (int k= 0; k <NN[i-1]; k++) {// all weights to the previous layer
          braintemp[i][j][k] = data [index];
          index +=1;}}}
      cells.add(new Cell(braintemp, 99)); 
}
}
