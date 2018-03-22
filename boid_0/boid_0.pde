
int NUMBER = 50; 
float SPEED = 1.0;
float RADIUS = 3;
int CENTER_PULL_FACTOR = 1000;
int DIST_THRESHOLD = 25;

float r1 = 1;
float r2 = 0.8;
float r3 = 0.1;

Dot[] dots = null;

void setup(){
  size(800, 600);
  background(150);
  
  smooth();
  noStroke();
  fill(150);
  
  dots = new Dot[NUMBER];
  
  float angle = TWO_PI / NUMBER;
  for(int i = 0; i < NUMBER; i++) {
    float addx = (float)Math.cos(angle*i);
    float addy = (float)Math.sin(angle*i);
    
    Dot d = new Dot(width / 2 + addx*50, height / 2 + addy*50, getRandom(-SPEED, SPEED)*addx, getRandom(-SPEED, SPEED)*addy, i, dots);
    dots[i] = d;
  }
  
  //loadPixels();
}

void draw(){
  //background(0);
  fill(150, 240);
  rect(0, 0, width, height);
  
  for(int i = 0; i < NUMBER; i++){
    dots[i].draw();
  }
  
  /*
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++ ) {
      int loc = x + y*width;
      float r,g,b;
      r = red (pixels[loc]);
      float maxdist = 50;//dist(0,0,width,height);
      float d = dist(x, y, mouseX, mouseY);
      float adjustbrightness = 255*(maxdist-d)/maxdist;
      r += adjustbrightness;
      r = constrain(r, 0, 255);
    }
  }
  updatePixels();
  */
}


float getRandom(float min, float max) {
  return (float)Math.random() * (max - min) + min;
}









class Dot{
  /*
  * @param {int} x current position
  * @param {int} y current position
  * @param {int} vx velocity
  * @param {int} vy velocity
  * @param {int} id id
  */
  float vx, vy;
  int id;
  Dot[] others;
  PVector v1, v2, v3;
  PVector pos;
  ArrayList<PVector> history = new ArrayList<PVector>();
  
  Dot(float x, float y, float vx, float vy, int id, Dot[] others){
     this.pos = new PVector(x, y);
     this.vx = vx;
     this.vy = vy;
     this.id = id;
     this.others = others;
     
     this.v1 = new PVector();
     this.v2 = new PVector();
     this.v3 = new PVector();
  }
  
  void draw(){
    clearVector();
    
    center();
    avoid();
    average();
    
    update();
    
    // historyLine
    beginShape();
    stroke(255);
    strokeWeight(1);
    noFill();
    for(PVector v:history){
      vertex(v.x, v.y);
    }
    endShape();
    
    ellipse(this.pos.x, this.pos.y, RADIUS * 2, RADIUS * 2);
    
  /*
    PVector velocity = new PVector(this.vx, this.vy);
    float theta = velocity.heading2D() + radians(90);
    fill(200, 50);
    stroke(255);
    pushMatrix();
    translate(this.x, this.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -RADIUS*2);
    vertex(-RADIUS, RADIUS*2);
    vertex(RADIUS, RADIUS*2);
    endShape();
    popMatrix();
    */
  }
  
  void update(){
    this.vx += r1*this.v1.x + r2*this.v2.x + r3*this.v3.x;
    this.vy += r1*this.v1.y + r2*this.v2.y + r3*this.v3.y;
    
    float movement = (float)Math.sqrt(this.vx * this.vx + this.vy * this.vy);
    if(movement > SPEED){
      this.vx = (this.vx / movement) * SPEED;
      this.vy = (this.vy / movement) * SPEED;
    }

    this.pos.x += this.vx;
    this.pos.y += this.vy;
    
    history.add(pos);
    if (history.size() > 100) {
      history.remove(0);
    }
    
    //collide();
    borders();
  }
  
  void collide(){
    if(this.pos.x - RADIUS <= 0){
      this.pos.x = RADIUS;
      this.vx *= -1;
    }
    if(this.pos.x + RADIUS >= width){
      this.pos.x = width - RADIUS;
      this.vx *= -1;
    }
  
    if(this.pos.y - RADIUS <= 0){
      this.pos.y = RADIUS;
      this.vy *= -1;
    }
    if(this.pos.y + RADIUS >= height){
      this.pos.y = height - RADIUS;
      this.vy *= -1;
    }
  }
  
  void borders(){
    if (this.pos.x < -RADIUS){
      this.pos.x = width + RADIUS;
      history = new ArrayList<PVector>();
    }
    if (this.pos.y < -RADIUS){
      this.pos.y = height + RADIUS;
      history = new ArrayList<PVector>();
    }
    if (this.pos.x > width + RADIUS){
      this.pos.x = -RADIUS;
      history = new ArrayList<PVector>();
    }
    if (this.pos.y > height + RADIUS){
      this.pos.y = -RADIUS;
      history = new ArrayList<PVector>();
    }
  }
  
  void clearVector(){
    this.v1.set(0, 0);
    this.v2.set(0, 0);
    this.v3.set(0, 0);
  }
  
  void center(){
    float neighborDist = 50;
    int count = 0;
    for(Dot dot : this.others){
      if(this.id == dot.id){
        continue;
      }
      if(dist(this.pos.x, this.pos.y, dot.pos.x, dot.pos.y) < neighborDist) {
        this.v1.x += dot.pos.x;
        this.v1.y += dot.pos.y;
        count++;
      }
    }
    
    if(0 < count){
      this.v1.x /= count;
      this.v1.y /= count;
      
      this.v1.x = (this.v1.x - this.pos.x) / CENTER_PULL_FACTOR;
      this.v1.y = (this.v1.y - this.pos.y) / CENTER_PULL_FACTOR;
    }
  }
  
  void avoid(){
    for(Dot dot : this.others){
      if(this.id == dot.id){
        continue;
      }
      if(dist(this.pos.x, this.pos.y, dot.pos.x, dot.pos.y) < DIST_THRESHOLD) {
        this.v2.x -= (dot.pos.x - this.pos.x);
        this.v2.y -= (dot.pos.y - this.pos.y);
      }
    }
  }
  
  void average(){
    for(Dot dot : this.others){
      if(this.id == dot.id){
        continue;
      }
      
      this.v3.x += dot.vx;
      this.v3.y += dot.vy;
    }
    
    this.v3.x /= (NUMBER - 1);
    this.v3.y /= (NUMBER - 1);
    
    this.v3.x = (this.v3.x - this.vx)/2;
    this.v3.y = (this.v3.y - this.vy)/2;
  }
  
}