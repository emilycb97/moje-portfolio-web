// Interaktywny Generator Fraktali 2D
// Sterowanie: 
// - Lewy klik myszy przełącza między fraktalami
// - Kółko myszy lub klawisze GÓRA/DÓŁ zmieniają głębokość rekursji
// - Naciśnij 'a' aby przełączyć animację
// - Naciśnij 's' aby zapisać obraz do pliku
// - Naciśnij 'c' aby przełączyć tryb kolorowania
// - Strzałki LEWO/PRAWO - zmiana kąta gałęzi drzewa

// ===== ZMIENNE GLOBALNE =====

// Główne zmienne kontrolujące fraktal
int currentFractal = 0; // 0 = drzewo fraktalne, 1 = trójkąt Sierpińskiego
int maxDepth = 8; // Maksymalna dozwolona głębokość rekursji
int targetDepth = 8; // Docelowa głębokość do której animujemy
float currentDepthFloat = 8.0; // Obecna głębokość jako liczba zmiennoprzecinkowa dla płynnej interpolacji
boolean animateDepth = false; // Czy animacja głębokości jest włączona
boolean colorByDepth = true; // Czy kolorować gałęzie/trójkąty według poziomu rekursji
float animationSpeed = 0.02; // Prędkość automatycznych animacji

// Parametry specyficzne dla drzewa
float treeAngle = PI / 6; // Obecny kąt gałęzi (30 stopni)
float targetTreeAngle = PI / 6; // Docelowy kąt do którego interpolujemy
float currentTreeAngle = PI / 6; // Obecny interpolowany kąt
float treeLengthRatio = 0.67; // Stosunek o który każda gałąź się skraca
float minTreeAngle = 0.0; // Minimalny kąt - całkowicie zamknięte drzewo
float maxTreeAngle = PI / 2; // Maksymalny kąt - 90 stopni

// System kolorów
color[] depthColors; // Tablica kolorów dla różnych poziomów rekursji
  
int maxAngleChangeLevel = 3; // Maksymalny poziom na którym można zmieniać kąt
boolean lockAngleAfterLevel = true; // Czy blokować zmianę kąta po określonym poziomie
float lockedAngle = PI / 8; // Kąt używany po zablokowaniu (domyślnie 22.5°)

/**
 * Funkcja setup - uruchamia się raz na początku programu
 * Inicjalizuje okno, tło i system kolorów
 */
void setup() {
  size(1200, 900); // Ustaw rozmiar okna na 1200x900 pikseli
  surface.setResizable(true); // Pozwól na zmianę rozmiaru okna
  background(20, 20, 30); // Ustaw ciemne niebiesko-szare tło
  
  // Inicjalizuj paletę kolorów dla różnych głębokości rekursji
  initializeColors();
}

/**
 * Główna pętla draw - uruchamia się ciągle aby renderować każdą klatkę
 * Obsługuje aktualizacje animacji, renderowanie interfejsu i rysowanie fraktali
 */
void draw() {
  background(20, 20, 30); // Wyczyść ekran ciemnym tłem
  
  // Aktualizuj wszystkie płynne animacje i interpolacje
  updateAnimations();
  
  // Narysuj nakładkę interfejsu użytkownika
  drawUI();
  
  // Narysuj aktualnie wybrany fraktal
  if (currentFractal == 0) {
    drawFractalTree(); // Narysuj fraktal drzewa binarnego
  } else {
    drawSierpinskiTriangle(); // Narysuj trójkąt Sierpińskiego
  }
}

/**
 * Inicjalizuj paletę kolorów dla kolorowania według głębokości
 * Tworzy gradient tęczowy w przestrzeni kolorów HSB
 */
void initializeColors() {
  depthColors = new color[15]; // Utwórz tablicę dla maksymalnie 15 poziomów głębokości
  
  // Wygeneruj kolory przez całe spektrum odcieni
  for (int i = 0; i < depthColors.length; i++) {
    float hue = map(i, 0, depthColors.length - 1, 0, 360); // Mapuj indeks na odcień (0-360)
    colorMode(HSB, 360, 100, 100); // Przełącz na tryb kolorów HSB
    depthColors[i] = color(hue, 80, 90); // Utwórz kolor z wysoką saturacją i jasnością
    colorMode(RGB, 255); // Przełącz z powrotem na tryb RGB
  }
}

/**
 * Aktualizuj wszystkie parametry animacji używając płynnej interpolacji
 * Obsługuje automatyczną animację głębokości i płynne przejścia parametrów
 */
void updateAnimations() {
  // Automatyczna animacja głębokości używając fali sinusoidalnej
  if (animateDepth) {
    // Utwórz oscylującą głębokość między 5 a 9 na podstawie czasu
    targetDepth = (int)(5 + 7 * sin(millis() * 0.001));
  }
  
  // Płynna interpolacja obecnej głębokości w kierunku docelowej
  // lerp() tworzy płynne przejścia zamiast skoków
  currentDepthFloat = lerp(currentDepthFloat, targetDepth, 0.1);
  
  // Płynna interpolacja kąta drzewa w kierunku docelowego
  currentTreeAngle = lerp(currentTreeAngle, targetTreeAngle, 0.05);
  
  // Automatyczna animacja kąta drzewa gdy animacja głębokości jest włączona
  if (animateDepth && currentFractal == 0) {
    // Utwórz oscylujący kąt między PI/8 a PI/4 (22.5° do 45°)
    targetTreeAngle = PI/8 + PI/8 * sin(millis() * 0.0005);
  }
}

/**
 * Narysuj nakładkę interfejsu użytkownika z aktualnymi ustawieniami i kontrolami
 * Wyświetla informacje o fraktalu, parametry i instrukcje sterowania
 */
void drawUI() {
  fill(255, 200); // Biały tekst z pewną przezroczystością
  textAlign(LEFT); // Wyrównaj tekst do lewej
  textSize(16); // Ustaw główny rozmiar tekstu
  
  // Wyświetl aktualny typ fraktala
  String fractalName = (currentFractal == 0) ? "Drzewo Fraktalne" : "Trójkąt Sierpińskiego";
  text("Aktualny fraktal: " + fractalName, 20, 30);
  
  // Wyświetl aktualne parametry
  text("Głębokość rekursji: " + (int)currentDepthFloat, 20, 50);
  text("Animacja: " + (animateDepth ? "WŁĄCZONA" : "WYŁĄCZONA"), 20, 70);
  text("Kolorowanie: " + (colorByDepth ? "WŁĄCZONE" : "WYŁĄCZONE"), 20, 90);
  
  // Informacje specyficzne dla drzewa
  if (currentFractal == 0) {
    text("Kąt gałęzi: " + int(degrees(currentTreeAngle)) + "°", 20, 110);
    // Specjalna wiadomość gdy drzewo jest całkowicie zamknięte
    if (currentTreeAngle <= 0.01) {
      text("DRZEWO ZAMKNIĘTE", 20, 130);
    }
  }
  
   if (lockAngleAfterLevel) {
    text("Blokada kąta po poziomie: " + maxAngleChangeLevel, 20, 130);
    text("Zablokowany kąt: " + int(degrees(lockedAngle)) + "°", 20, 150);
  } else {
    text("Blokada kąta: WYŁĄCZONA", 20, 130);  
  }
  
  // Instrukcje sterowania z mniejszym, przyciemnionym tekstem
  fill(255, 150); // Przyciemniony biały dla instrukcji
  textSize(12); // Mniejszy rozmiar tekstu
  text("Sterowanie:", 20, 160);
  text("• Klik - przełącz fraktal", 20, 180);
  text("• Kółko myszy / ↑↓ - głębokość", 20, 200);
  text("• ←→ - kąt gałęzi drzewa (ruch myszką)", 20, 220);
  text("• 'A' - przełącz animację", 20, 240);
  text("• 'C' - przełącz kolorowanie", 20, 260);
  text("• 'S' - zapisz obraz", 20, 280);
  text("• 'L' - przełącz blokadę kąta", 20, 300);
  text("• +/- - poziom blokady", 20, 320); 
  
  // Pozycja myszy wpływa na kąt drzewa (tylko gdy nie animujemy)
  if (currentFractal == 0 && !animateDepth) {
    // Mapuj pozycję X myszy na zakres kątów
    float mouseInfluence = map(mouseX, 0, width, minTreeAngle, maxTreeAngle);
 
    // Aktualizuj tylko jeśli mysz jest w granicach okna
    if (mouseX >= 0 && mouseX <= width) {
      targetTreeAngle = mouseInfluence;
    }
  }
}

/**
 * Narysuj drzewo fraktalne używając rekurencyjnego rozgałęziania
 * Tworzy strukturę drzewa binarnego z konfigurowalnymi kątami i głębokością
 */
void drawFractalTree() {
  pushMatrix(); // Zapisz aktualną macierz transformacji
  
  // Umieść drzewo na dole środka ekranu z małym marginesem
  translate(width/2, height - height * 0.05);
  
  // Ustaw kolor i grubość dla pnia - uwzględnij przełączanie kolorowania
  if (colorByDepth && 0 < depthColors.length) {
    stroke(depthColors[0]);
  } else {
    stroke(255); // Biały kolor gdy kolorowanie wyłączone
  }
  
  // Narysuj główny pień z zwiększoną grubością
  strokeWeight(5); // Gruby pień
  float trunkHeight = height * 0.15; // Wysokość pnia jako procent ekranu
  line(0, 0, 0, -trunkHeight); // Narysuj pionową linię pnia
  
  // Jeśli głębokość to 1, rysuj tylko pień (bez gałęzi)
  if ((int)currentDepthFloat <= 1) {
    popMatrix(); // Przywróć macierz transformacji
    return;
  }
  
  // Przenieś do góry pnia i rozpocznij rekurencyjne rozgałęzianie
  translate(0, -trunkHeight);
  // Rozpocznij rekursję z dużą początkową długością gałęzi
  // Zmniejszamy głębokość o 1, bo pień już narysowaliśmy
  drawBranch(height * 0.12, currentTreeAngle, (int)currentDepthFloat - 1, 1);
  
  popMatrix(); // Przywróć macierz transformacji
}

/**
 * Funkcja rekurencyjna do rysowania gałęzi drzewa
 * @param len Aktualna długość gałęzi
 * @param angle Kąt między gałęziami
 * @param depth Pozostała głębokość rekursji
 * @param currentLevel Aktualny poziom rekursji (do kolorowania)
 */
void drawBranch(float len, float angle, int depth, int currentLevel) {
  // Przypadek bazowy: zatrzymaj rekursję jeśli głębokość wyczerpana lub gałąź za mała
  if (depth <= 0 || len < 2) return;
  
  // Ustaw kolor i grubość na podstawie poziomu rekursji - PRZED rysowaniem
  color branchColor;
  float branchWeight;
  
  float angleToUse = angle;
  if (lockAngleAfterLevel && currentLevel > maxAngleChangeLevel) {
    angleToUse = lockedAngle; // Użyj zablokowanego kąta
  } 
  
  if (colorByDepth && currentLevel < depthColors.length) {
    branchColor = depthColors[currentLevel];
  } else {
    branchColor = color(255); // Biały jeśli kolorowanie wyłączone
  }
  
   // Zmniejszaj grubość obrysu z głębokością dla naturalnego wyglądu
  branchWeight = max(1, 6 - currentLevel * 0.4);
  
  // Narysuj obie gałęzie w pętli
  for (int direction = -1; direction <= 1; direction += 2) { // -1, potem 1
    pushMatrix();
    rotate(angleToUse * direction); // Obróć w odpowiednią stronę
    
    // Ustaw kolor i grubość dla tej gałęzi
    stroke(branchColor);
    strokeWeight(branchWeight);
    line(0, 0, 0, -len); // Narysuj linię gałęzi w górę
    
    translate(0, -len); // Przenieś do końca gałęzi
    // Rekurencyjnie narysuj mniejsze gałęzie
    drawBranch(len * treeLengthRatio, angle, depth - 1, currentLevel + 1);
    popMatrix();
  }
}

/**
 * Narysuj fraktal trójkąta Sierpińskiego
 * Tworzy klasyczny wzór trójkąta-w-trójkącie
 */
void drawSierpinskiTriangle() {
  // Oblicz główne wierzchołki trójkąta wyśrodkowane na ekranie
  float triangleSize = min(width, height) * 0.6; // Rozmiar jako procent mniejszego wymiaru ekranu
  
  // Zdefiniuj trzy wierzchołki trójkąta równobocznego
  PVector p1 = new PVector(width/2, height/2 - triangleSize/2); // Górny wierzchołek
  PVector p2 = new PVector(width/2 - triangleSize/2, height/2 + triangleSize/2); // Dolny lewy
  PVector p3 = new PVector(width/2 + triangleSize/2, height/2 + triangleSize/2); // Dolny prawy
  
  // Rozpocznij rekurencyjne podziały trójkąta
  drawSierpinskiRecursive(p1, p2, p3, (int)currentDepthFloat, 0);
}

/**
 * Funkcja rekurencyjna do rysowania podziału trójkąta Sierpińskiego
 * @param p1 Pierwszy wierzchołek aktualnego trójkąta
 * @param p2 Drugi wierzchołek aktualnego trójkąta  
 * @param p3 Trzeci wierzchołek aktualnego trójkąta
 * @param depth Pozostała głębokość rekursji
 * @param level Aktualny poziom rekursji (do kolorowania)
 */
void drawSierpinskiRecursive(PVector p1, PVector p2, PVector p3, int depth, int level) {
  // Przypadek bazowy: zatrzymaj rekursję gdy głębokość wyczerpana
  if (depth <= 0) return;
  
  // Ustaw kolory wypełnienia i obrysu na podstawie poziomu rekursji
  if (colorByDepth && level < depthColors.length) {
    fill(depthColors[level]);
    stroke(depthColors[level]);
  } else {
    // Domyślny niebieski kolor z przezroczystością
    fill(100, 150, 255, 150);
    stroke(100, 150, 255);
  }
  
  strokeWeight(1); // Cienkie linie dla obrysów trójkątów
  
  // Na najgłębszym poziomie narysuj rzeczywisty trójkąt
  if (depth == 1) {
    triangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
    return;
  }
  
  // Oblicz punkty środkowe każdej krawędzi
  PVector m1 = PVector.lerp(p1, p2, 0.5); // Punkt środkowy krawędzi p1-p2
  PVector m2 = PVector.lerp(p2, p3, 0.5); // Punkt środkowy krawędzi p2-p3
  PVector m3 = PVector.lerp(p3, p1, 0.5); // Punkt środkowy krawędzi p3-p1
  
  // Rekurencyjnie narysuj trzy mniejsze trójkąty utworzone przez połączenie punktów środkowych
  drawSierpinskiRecursive(p1, m1, m3, depth - 1, level + 1); // Górny trójkąt
  drawSierpinskiRecursive(m1, p2, m2, depth - 1, level + 1); // Dolny lewy trójkąt
  drawSierpinskiRecursive(m3, m2, p3, depth - 1, level + 1); // Dolny prawy trójkąt
  // Środkowy trójkąt pozostaje pusty, tworząc charakterystyczny wzór Sierpińskiego
}

/**
 * Obsłuż wejście z klawiatury do kontrolowania parametrów fraktala
 * Reaguje na różne klawisze dla różnych funkcji
 */
void keyPressed() {
  switch(key) {
    case 'a':
    case 'A':
      // Przełącz automatyczną animację głębokości i kąta drzewa
      animateDepth = !animateDepth;
      break;
      
    case 'c':
    case 'C':
      // Przełącz między kolorowaniem według głębokości a monochromatycznym
      colorByDepth = !colorByDepth;
      break;
      
    case 's':
    case 'S':
      // Zapisz aktualną klatkę jako obraz PNG z znacznikiem czasu
      String filename = "fractal_" + year() + month() + day() + "_" + hour() + minute() + second() + ".png";
      save(filename);
      println("Obraz zapisany jako: " + filename);
      break;
      
    case 'l':
    case 'L':
      // Przełącz blokadę kąta
      lockAngleAfterLevel = !lockAngleAfterLevel;
      break;
      
    case '+':
    case '=':
      // Zwiększ poziom blokady
      maxAngleChangeLevel = min(10, maxAngleChangeLevel + 1);
      break;
      
    case '-':
    case '_':
      // Zmniejsz poziom blokady
      maxAngleChangeLevel = max(1, maxAngleChangeLevel - 1);
      break; 
  }
  
  // Obsłuż klawisze strzałek do kontroli głębokości
  if (keyCode == UP) {
    // Zwiększ głębokość rekursji (maks 12 aby uniknąć problemów z wydajnością)
    targetDepth = min(12, targetDepth + 1);
    animateDepth = false; // Wyłącz animację przy ręcznym sterowaniu
  } else if (keyCode == DOWN) {
    // Zmniejsz głębokość rekursji (min 1 aby zachować jakąś strukturę)
    targetDepth = max(1, targetDepth - 1);
    animateDepth = false; // Wyłącz animację przy ręcznym sterowaniu
  }
}

/**
 * Obsłuż zdarzenia kliknięcia myszy
 * Lewy klik przełącza między różnymi typami fraktali
 */
void mousePressed() {
  if (mouseButton == LEFT) {
    // Przełączaj między dostępnymi fraktalami (obecnie 2: drzewo i Sierpiński)
    currentFractal = (currentFractal + 1) % 2;
    
    // Zresetuj parametry przy przełączaniu fraktali
    if (currentFractal == 0) {
      // Zresetuj kąt drzewa do domyślnego przy przełączaniu na drzewo
      targetTreeAngle = PI / 6; // 30 stopni
    }
  }
}

/**
 * Obsłuż przewijanie kółkiem myszy do kontroli głębokości
 * Zapewnia intuicyjną kontrolę podobną do zoomu nad głębokością rekursji
 * @param event MouseEvent zawierający informację o kierunku przewijania
 */
void mouseWheel(MouseEvent event) {
  float e = event.getCount(); // Pobierz kierunek przewijania (-1 dla góry, +1 dla dołu)
  
  if (e < 0) {
    // Przewiń w górę: zwiększ głębokość (więcej szczegółów)
    targetDepth = min(12, targetDepth + 1);
  } else {
    // Przewiń w dół: zmniejsz głębokość (mniej szczegółów)
    targetDepth = max(1, targetDepth - 1);
  }
  
  // Wyłącz automatyczną animację gdy użytkownik ręczne kontroluje głębokość
  animateDepth = false;
}
