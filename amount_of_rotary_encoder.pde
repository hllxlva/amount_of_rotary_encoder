boolean L, R;
int n = 10;
float easing = 0.05;
float x = 1450, y = 625,vx ,vy;
float theta, omega = 0;
float[][] C = {{100, 0}, //Censerの位置
               {0, 100}, 
               {-100, 0},
               {0, -100},
               {100, 0}};
float[][] Cr = new float[5][2];//Censerの極座標表示[0] = x,[1] = y
float[][] Vd = new float[5][2];//rotary_encoderの読み取れる方向ベクトルとその他の値
float[][] k  = new float[5][2];//(係数)
float[] now_v = new float[2];//now velocity
float[] now_ang_v = new float[2];//now angular velocity
void setup() {
  size(2500, 1250);
  background(0);
  for (int i = 0; i < 4; i++) {
     Cr[i][0] = sqrt(C[i][0]*C[i][0]+C[i][1]*C[i][1]);
     Cr[i][1] = i*PI/2;
  }
  for (int i = 0; i < 2; i++) {
     Cr[4][i] = Cr[0][i];
  }
}
void draw() {
  background(0);
  //計算------------------
  float targetX = mouseX;
  float targetY = mouseY;
  vx = (targetX - x) * easing;
  vy = (targetY - y) * easing;
  x = x + (targetX - x) * easing; //差の0.05分だけ近づく
  y = y + (targetY - y) * easing;

  for (int i = 0; i < 4; i++) {//各センサー部分
    Vd[i][0] = vx*sin(Cr[i][1]-theta*PI/180)+vy*cos(Cr[i][1]-theta*PI/180)+Cr[i][0]*omega*PI/180;
    Vd[i][1] = vx*cos(Cr[i][1]-theta*PI/180)-vy*sin(Cr[i][1]-theta*PI/180);
  }
  for (int i = 0; i < 2; i++) {
     Vd[4][i] = Vd[0][i];
  }
  
  
  //操作--------------------
  if(L && R){
    omega = 0;
  }else if(L){
    theta += 10;//↓°
    omega = 10;///↑は等しく
  }else if(R){
    theta -= 10;
    omega = -10;
  }else{
    omega = 0;
  }
  

  //ロボット描画------------------------------------
  fill(150);
  translate(x,y);//ロボットの中心を(0, 0)に
  rotate(theta*PI/180);//ロボットの回転数分回転
  ellipse(0, 0, 
  50, 50);//中心点
  for (int i = 0; i < 4; i++) {//各センサー部分
    rotate(-Cr[i][1]);//センサーの位置に
    translate(Cr[i][0],0);//移動する
    rect(-5,-25,10,50);//センサー描画
    //rotate(Cr[i][1]-theta*PI/180);//センサーの値(速さ)を描画
    stroke(0,255,0);
    strokeWeight(3);
    line(0,0,0,n*Vd[i][0]);
    stroke(0);
    strokeWeight(0);
    //rotate(theta*PI/180-Cr[i][1]);
    translate(-Cr[i][0],0);
    rotate(Cr[i][1]);
  }
  rotate(-theta*PI/180);
  stroke(255,0,0);
  strokeWeight(3);
  //速さの線
  line(0,0,n*vx,n*vy);//中心
  stroke(0);
  strokeWeight(0);
  translate(-x,-y);
  
  
  //センサーの値からの計算
  //センサーの値
  // C1 = (C[0][0], C[0][1]) = (C[5][0], C[5][1])
  // C2 = (C[1][0], C[1][1])
  // C3 = (C[2][0], C[2][1])
  // C4 = (C[3][0], C[3][1])
  //Cr1 = Cr[0][0] = Cr[5][0]
  //Cr2 = Cr[1][0]
  //Cr3 = Cr[2][0]
  //Cr4 = Cr[3][0]
  //Vd1 = Vd[0][0] = Vd[5][0]
  //Vd2 = Vd[1][0]
  //Vd3 = Vd[2][0]
  //Vd4 = Vd[3][0]
  
  //瞬間中心から求める
  for (int i = 0; i < 4; i++) {
     for (int j = 0; j < 2; j++) {
       k[i][j] = (Vd[i][0]*C[i+1][j]/Cr[i+1][0]-Vd[i+1][0]*C[i][j]/Cr[i][0]);//係数計算
     }
  }
  for (int i = 0; i < 2; i++) {
     k[4][i] = k[0][i];
  }
  for (int i = 0; i < 2; i++) {
     now_v[i] = (k[1][1-i]*(Vd[0][0]*Cr[1][0]-Vd[1][0]*Cr[0][0])-k[0][1-i]*(Vd[1][0]*Cr[2][0]-Vd[2][0]*Cr[1][0]))/(k[0][i]*k[1][1-i]-k[1][i]*k[0][1-i]);//now_velocity[]の中はx, y を表す
  }
  now_ang_v[0] = Cr[0][0]*Vd[0][0]/(now_v[1]*C[0][1]+now_v[0]*C[0][0]-Cr[0][0]*C[0][0]);//右クリックが＋ [rad/s]
  
  translate(x, y);
  rotate(theta*PI/180);
  //瞬間中心の線
  stroke(0,0,255);
  strokeWeight(3);
  line(0,0,now_v[0],-now_v[1]);//ここのy軸に-がついているのは縦軸が下向いているためである
  //角速度の線
  stroke(200);
  line(0,0,now_ang_v[0]*180/PI*n,0);
  stroke(0);
  strokeWeight(0);
  rotate(-theta*PI/180);
  translate(-x, -y);
}
void mousePressed(){
  switch (mouseButton) {
    case LEFT:
      L = true;
      break;
    case RIGHT:
      R = true;
      break;
  }
}
void mouseReleased(){
  switch (mouseButton) {
    case LEFT:
      L = false;
      break;
    case RIGHT:
      R = false;
      break;
  }
}