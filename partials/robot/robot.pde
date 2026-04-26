// === POZYCJA I ORIENTACJA ROBOTA ===
float robotX = 0;
float robotY = -50;
float robotZ = 0;
float robotRotation = 0;
float robotRadius = 25;

// === ANIMACJA ROBOTA ===
float armSwing = 0;
float legSwing = 0;
float headRotation = 0;
float headTargetRotation = 0; 
float antennaHeight = 0;
float bodyBob = 0;
float energyPulse = 0;

// === KOLIZJE I STATUS ===
boolean collisionDetected = false;
int collisionTimer = 0;
boolean robotDamaged = false;
int damageTimer = 0;

// === OŚWIETLENIE ===
int lightMode = 0;
float lightX = 0;
float lightY = -100;
float lightZ = 100;
float ambientIntensity = 60;
float directionalIntensity = 120;
float pointLightIntensity = 255;
color pointLightColor;

// === KAMERA ===
int cameraMode = 0;
float cameraAngleX = -0.3;
float cameraAngleY = 0;
float cameraDistance = 250;

// === RUCH CIĄGŁY ===
boolean wPressed = false, aPressed = false, sPressed = false, dPressed = false;
boolean qPressed = false, ePressed = false;
float moveSpeed = 3.5;
float rotateSpeed = 0.08;

// === PRZESZKODY ===
ArrayList<Obstacle> obstacles;

// === KOLORY ===
color robotColor;
color damageColor;

// === INTERFEJS ===
boolean showUI = true;

void setup() {
  size(1200, 800, P3D);
  
  // Inicjalizacja kolorów
  robotColor = color(69, 255, 160);
  damageColor = color(200, 50, 50);
  pointLightColor = color(255, 200, 150);
  
  // Inicjalizacja przeszkód
  obstacles = new ArrayList<Obstacle>();
  createObstacles();

  
  println("=== ROBOT 3D ===");
  println("W - ruch do przodu");
  println("S - ruch do tyłu");
  println("A - ruch w lewo");
  println("D - ruch w prawo");
  println("QE - obrót");
  println("C - tryb kamery (Śledzenie/Góra)");
  println("L - tryb oświetlenia");
  println("R - reset pozycji");
  println("H - interfejs on/off");
}

void draw() {
  // Proste tło
  background(20, 25, 35);
  
  // Obsługa ruchu
  handleMovement();
  
  // Oświetlenie
  updateLighting();
  setupLighting();
  
  // Kamera
  setupCamera();
  
  // Podłoga
  drawFloor();
  
  // Przeszkody
  drawObstacles();
  
  // Kolizje
  checkCollisions();
  
  // Aktualizacja obrotu głowy w kierunku światła - ZAWSZE
  updateHeadTracking();
  
  // Robot
  pushMatrix();
  translate(robotX, robotY, robotZ);
  rotateY(robotRotation);
  drawRobot();
  popMatrix();
  
  // Animacja
  updateAnimation();
  updateTimers();
  
  // Interfejs
  if (showUI) {
    drawUI();
  }
}

void updateHeadTracking() {
  // Oblicz kierunek do światła względem pozycji robota
  float deltaX = lightX - robotX;
  float deltaZ = lightZ - robotZ;
  
  // Oblicz kąt do światła w przestrzeni świata
  float angleToLight = atan2(deltaX, deltaZ);
  
  // Dostosuj kąt względem orientacji robota
  headTargetRotation = angleToLight - robotRotation;
  
  // Normalizuj kąt do zakresu -PI do PI ***
  while (headTargetRotation > PI) headTargetRotation -= TWO_PI;
  while (headTargetRotation < -PI) headTargetRotation += TWO_PI;
  
  // Ogranicz obrót głowy do realistycznego zakresu (-90 do 90 stopni)
  headTargetRotation = constrain(headTargetRotation, -PI/2, PI/2);
  
  // Płynne przejście do docelowego kąta - zwiększona szybkość śledzenia
  float rotationDiff = headTargetRotation - headRotation;
  
  // Normalizuj różnicę kątów ***
  while (rotationDiff > PI) rotationDiff -= TWO_PI;
  while (rotationDiff < -PI) rotationDiff += TWO_PI;
  
  // Płynne przejście - głowa zawsze śledzi światło, niezależnie od stanu robota
  headRotation += rotationDiff * 0.05; 
  
  // Upewnij się, że headRotation jest w odpowiednim zakresie ***
  headRotation = constrain(headRotation, -PI/2, PI/2);
}

void createObstacles() {
  obstacles.add(new Obstacle(150, 0, 0, 50, 95, 50, color(245, 66, 66)));
  obstacles.add(new Obstacle(-150, -20, 100, 80, 105, 80, color(66, 245, 233)));
  obstacles.add(new Obstacle(0, 0, 200, 60, 125, 60, color(142, 97, 255)));
  obstacles.add(new Obstacle(-200, -30, -100, 70, 115, 70, color(242, 255, 0)));
}

void handleMovement() {
  float newX = robotX;
  float newZ = robotZ;

  if (wPressed) { // W - ruch do przodu (w kierunku patrzenia robota)
    newX += sin(robotRotation) * moveSpeed;
    newZ += cos(robotRotation) * moveSpeed;
  }
  if (sPressed) { // S - ruch do tyłu (przeciwnie do kierunku patrzenia)
    newX -= sin(robotRotation) * moveSpeed;
    newZ -= cos(robotRotation) * moveSpeed;
  }
  if (aPressed) { // A - ruch w lewo (względem kierunku patrzenia)
    newX += cos(robotRotation) * moveSpeed;
    newZ -= sin(robotRotation) * moveSpeed;
  }
  if (dPressed) { // D - ruch w prawo (względem kierunku patrzenia)
    newX -= cos(robotRotation) * moveSpeed;
    newZ += sin(robotRotation) * moveSpeed;
  }
  
  // Sprawdź kolizje (z uwzględnieniem ramion)
  if (!checkFutureCollision(newX, robotY, newZ)) {
    robotX = newX;
    robotZ = newZ;
  }
  
  if (qPressed) robotRotation -= rotateSpeed;
  if (ePressed) robotRotation += rotateSpeed;
}

void setupCamera() {
  switch(cameraMode) {
    case 0: // Śledząca (z boku)
      camera(robotX + 200, robotY - 100, robotZ + 200,
             robotX, robotY, robotZ,
             0, 1, 0);
      break;
    case 1: // Z góry
      camera(robotX, robotY - 400, robotZ, 
             robotX, robotY, robotZ, 
             0, 0, 1);
      break;
  }
}

void updateLighting() {
  switch(lightMode) {
    case 0: // Mysz
      lightX = map(mouseX, 0, width, -400, 400);
      lightY = map(mouseY, 0, height, -300, 100);
      lightZ = 100;
      break;
    case 1: // Śledzące
      lightX = robotX + 100;
      lightY = robotY - 150;
      lightZ = robotZ + 100;
      break;
  }
}

void setupLighting() {
  ambientLight(ambientIntensity, ambientIntensity, ambientIntensity);
  
  if (lightMode <= 1) {
    pointLight(pointLightIntensity, pointLightIntensity, pointLightIntensity, 
              lightX, lightY, lightZ);
  }
}

void drawFloor() {
  fill(40, 45, 60);
  stroke(65, 70, 85);
  strokeWeight(1);
  
  pushMatrix();
  translate(0, 50, 0);
  rotateX(PI/2);
  noStroke();
  fill(40, 45, 60);
  rect(-500, -500, 1000, 1000);
  popMatrix();
  
  stroke(65, 70, 85);
  for (int i = -300; i <= 300; i += 100) {
    line(i, 50, -300, i, 50, 300);
    line(-300, 50, i, 300, 50, i);
  }
}

void drawObstacles() {
  for (Obstacle obs : obstacles) {
    obs.draw();
  }
}

void checkCollisions() {
  boolean currentCollision = false;
  
  for (Obstacle obs : obstacles) {
    // Sprawdź kolizję głównego ciała robota
    if (obs.checkCollision(robotX, robotY, robotZ, robotRadius)) {
       currentCollision = true;
      if (!robotDamaged) {
        robotDamaged = true;
        damageTimer = millis();
      }
      break;
    }
    
    // Sprawdź kolizję ramion (dokładne pozycje ramion)
    if (checkArmCollision(obs)) {
      currentCollision = true;
      if (!robotDamaged) {
        robotDamaged = true;
        damageTimer = millis();
      }
      break;
    }
  }
  
  if (currentCollision) {
    collisionDetected = true;
    collisionTimer = millis();
  }
}

boolean checkArmCollision(Obstacle obs) {
  // Pozycje ramion względem robota (uwzględniając rotację)
  float armHeight = robotY - 10; // Wysokość ramion
  float armReach = 32; // Zasięg ramion od środka robota
  
  // Lewe ramię
  float leftArmX = robotX - cos(robotRotation) * armReach;
  float leftArmZ = robotZ + sin(robotRotation) * armReach;
  
  // Prawe ramię
  float rightArmX = robotX + cos(robotRotation) * armReach;
  float rightArmZ = robotZ - sin(robotRotation) * armReach;
  
  // Sprawdź kolizję lewego ramienia
  if (obs.checkCollision(leftArmX, armHeight, leftArmZ, 15)) {
    return true;
  }
  
  // Sprawdź kolizję prawego ramienia
  if (obs.checkCollision(rightArmX, armHeight, rightArmZ, 15)) {
    return true;
  }
  
  return false;
}

boolean checkFutureCollision(float x, float y, float z) {
  // Sprawdź kolizję głównego ciała
  for (Obstacle obs : obstacles) {
    if (obs.checkCollision(x, y, z, robotRadius)) {
      return true;
    }
  }
  
  // Sprawdź kolizję ramion w nowej pozycji
  float armHeight = y - 10; // Wysokość ramion
  float armReach = 32; // Zasięg ramion od środka robota
  
  // Lewe ramię (względem nowej pozycji i orientacji robota)
  float leftArmX = x - cos(robotRotation) * armReach;
  float leftArmZ = z + sin(robotRotation) * armReach;
  
  // Prawe ramię (względem nowej pozycji i orientacji robota)
  float rightArmX = x + cos(robotRotation) * armReach;
  float rightArmZ = z - sin(robotRotation) * armReach;
  
  for (Obstacle obs : obstacles) {
    if (obs.checkCollision(leftArmX, armHeight, leftArmZ, 15) ||
        obs.checkCollision(rightArmX, armHeight, rightArmZ, 15)) {
      return true;
    }
  }
  
  return false;
}

void drawRobot() {
  // Kolor w zależności od stanu - tylko miganie przy uszkodzeniu
  color currentColor;
  if (robotDamaged) {
    currentColor = lerpColor(damageColor, robotColor, sin(frameCount * 0.3) * 0.5 + 0.5);
  } else {
    currentColor = robotColor;
  }
  
  fill(currentColor);
  stroke(0, 100);
  strokeWeight(1);
  
  // === TUŁÓW ===
  pushMatrix();
  translate(0, 0, 0);
  box(40, 60, 30);
  
  // Panel na przodzie
  pushMatrix();
  translate(0, 0, 16);
  fill(red(currentColor) + 40, green(currentColor) + 40, blue(currentColor) + 40);
  box(28, 40, 4);
  popMatrix();
  popMatrix();
  
  // === GŁOWA ===
  pushMatrix();
  translate(0, -45, 0);
  // Obrót głowy w kierunku światła
  rotateY(headRotation);
  
  fill(red(currentColor) + 30, green(currentColor) + 30, blue(currentColor) + 30);
  box(32, 32, 32);
  
  // Oczy
  fill(150, 200, 255);
  pushMatrix();
  translate(-8, -3, 17);
  sphere(4);
  popMatrix();
  
  pushMatrix();
  translate(8, -3, 17);
  sphere(4);
  popMatrix();
  
  // Antena
  pushMatrix();
  translate(0, -22, 0); 
  
  float antennaMovement = sin(antennaHeight) * 2; 
  translate(0, antennaMovement, 0);
  
  fill(0, 163, 79);
  box(3, 18, 3);
  
  translate(0, -12, 0);
  fill(100, 237, 166);
  sphere(6);
  popMatrix();
  
  popMatrix();
  
  // === RAMIONA === 
  boolean isMovingForwardBack = wPressed || sPressed; // Ruch przód/tył powoduje bujanie ramion
  
  pushMatrix();
  translate(-32, -10, 0);
  // Bujanie w przód/tył tylko przy ruchu W/S - dla lewego ramienia
  rotateX(sin(armSwing) * (isMovingForwardBack ? 0.4 : 0.1));
  drawArm(currentColor);
  popMatrix();
  
  pushMatrix();
  translate(32, -10, 0);
  // Bujanie w przód/tył tylko przy ruchu W/S - dla prawego ramienia (przeciwnie)
  rotateX(-sin(armSwing) * (isMovingForwardBack ? 0.4 : 0.1));
  drawArm(currentColor);
  popMatrix();
  
  // === NOGI ===
  pushMatrix();
  translate(-15, 35, 0);
  rotateX(sin(legSwing) * 0.3);
  drawLeg(currentColor);
  popMatrix();
  
  pushMatrix();
  translate(15, 35, 0);
  rotateX(-sin(legSwing) * 0.3);
  drawLeg(currentColor);
  popMatrix();
}

void drawArm(color robotColor) {
  fill(robotColor);
  
  // Ramię górne
  pushMatrix();
  translate(0, 15, 0);
  box(14, 28, 14);
  
  // Przedramię
  translate(0, 20, 0);
  box(12, 24, 12);
  
  // Dłoń
  translate(0, 15, 0);
  fill(red(robotColor) + 30, green(robotColor) + 30, blue(robotColor) + 30);
  box(10, 14, 10);
  
  popMatrix();
}

void drawLeg(color robotColor) {
  fill(robotColor);
  
  // Udo
  pushMatrix();
  translate(0, 15, 0);
  box(16, 28, 16);
  
  // Golenie
  translate(0, 20, 0);
  rotateX(sin(legSwing * 1.2) * 0.25);
  box(14, 24, 14);
  
  // Stopa - na poziomie podłogi
  translate(0, 15, 0);
  fill(red(robotColor) + 30, green(robotColor) + 30, blue(robotColor) + 30);
  box(18, 8, 24);
  
  popMatrix();
}

void updateAnimation() {
  armSwing += 0.08;
  legSwing += 0.08;
  antennaHeight += 0.1;
  bodyBob += 0.06;
  energyPulse += 0.12;
  
  if (wPressed || sPressed) { 
    armSwing += 0.12; 
    legSwing += 0.15;
    antennaHeight += 0.05;
  }
}

void updateTimers() {
  if (robotDamaged && millis() - damageTimer > 2000) {
    robotDamaged = false;
  }
  
  if (millis() - collisionTimer > 100) {
    collisionDetected = false;
  }
}

void drawUI() {
  pushMatrix();
  pushStyle();
  
  camera();
  hint(DISABLE_DEPTH_TEST);
  
  fill(20, 20, 30, 180);
  noStroke();
  rect(10, 10, 120, 120);
  
  fill(255);
  textAlign(LEFT);
  textSize(14);
  text("ROBOT 3D", 20, 30);
  
  textSize(11);
  fill(robotDamaged ? color(255, 100, 100) : color(100, 255, 100));
  text("Status: " + (robotDamaged ? "USZKODZONY" : "SPRAWNY"), 20, 50);
  
  fill(200);
  text("Pozycja: X=" + int(robotX) + " Z=" + int(robotZ), 20, 70);
  text("Kamera: " + getCameraModeText(), 20, 85);
  text("Światło: " + getLightModeText(), 20, 100);
  
  if (collisionDetected) {
    fill(255, 150, 150);
    text("KOLIZJA!", 20, 115);
  }
  
  // Sterowanie
  fill(20, 20, 30, 180);
  rect(width - 200, 10, 160, 170);
  
  fill(255);
  textSize(12);
  text("STEROWANIE", width - 190, 30);
  
  textSize(10);
  text("W - Do przodu", width - 190, 50);
  text("S - Do tyłu", width - 190, 65);
  text("A - W lewo", width - 190, 80);
  text("D - W prawo", width - 190, 95);
  text("QE - Obrót", width - 190, 110);
  text("C - Kamera (śledzenie/góra)", width - 190, 125);
  text("L - Światło", width - 190, 140);
  text("R - Reset pozycji", width - 190, 155);
  text("H - Interfejs", width - 190, 170);

  
  hint(ENABLE_DEPTH_TEST);
  popStyle();
  popMatrix();
}

String getCameraModeText() {
  switch(cameraMode) {
    case 0: return "Śledząca";
    case 1: return "Z góry";
    default: return "Nieznana";
  }
}

String getLightModeText() {
  switch(lightMode) {
    case 0: return "Mysz";
    case 1: return "Śledzące";
    default: return "Podstawowe";
  }
}

// === OBSŁUGA KLAWIATURY ===
void keyPressed() {
  switch(key) {
    case 'w': case 'W': wPressed = true; break;
    case 'a': case 'A': aPressed = true; break;
    case 's': case 'S': sPressed = true; break;
    case 'd': case 'D': dPressed = true; break;
    case 'q': case 'Q': qPressed = true; break;
    case 'e': case 'E': ePressed = true; break;
    case 'c': case 'C':
      cameraMode = (cameraMode + 1) % 2; 
      break;
    case 'l': case 'L':
      lightMode = (lightMode + 1) % 2;
      break;
    case 'r': case 'R':
      robotX = robotY = robotZ = robotRotation = 0;
      robotY = -50; // Przywróć właściwą wysokość
      robotDamaged = false;
      break;
    case 'h': case 'H':
      showUI = !showUI;
      break;
  }
}

void keyReleased() {
  switch(key) {
    case 'w': case 'W': wPressed = false; break;
    case 'a': case 'A': aPressed = false; break;
    case 's': case 'S': sPressed = false; break;
    case 'd': case 'D': dPressed = false; break;
    case 'q': case 'Q': qPressed = false; break;
    case 'e': case 'E': ePressed = false; break;
  }
}

class Obstacle {
  float x, y, z, w, h, d;
  color obstacleColor;
  
  Obstacle(float x, float y, float z, float w, float h, float d, color c) {
    this.x = x; this.y = y; this.z = z;
    this.w = w; this.h = h; this.d = d;
    this.obstacleColor = c;
  }
  
  void draw() {
    pushMatrix();
    translate(x, y, z);
    fill(obstacleColor);
    stroke(0, 150);
    strokeWeight(1);
    box(w, h, d);
    popMatrix();
  }
  
  boolean checkCollision(float px, float py, float pz, float radius) {
    float closestX = constrain(px, x - w/2, x + w/2);
    float closestY = constrain(py, y - h/2, y + h/2);
    float closestZ = constrain(pz, z - d/2, z + d/2);
    
    float distance = dist(px, py, pz, closestX, closestY, closestZ);
    return distance < radius;
  }
}
