/****************************************************************************/
/*  MESNARD Emmanuel                                              ISIMA     */
/*                                                                          */
/*          Exemple 4 : Gestion d'une Webcam                                */
/*                      Mise en evidence du point le plus vert sur l'image  */
/*                                                                          */
/* Exemple_4_WebCam_Point_Vert.pde                       Processing 3.0     */
/****************************************************************************/

// Importation des librairies
import processing.video.*; // Bibliotheque de controle camera
import processing.sound.*;

import beads.*;
import org.jaudiolibs.beads.*;

// Parametres de taille de la capture video
final int widthCapture=640;  // largeur capture
final int heightCapture=480; // hauteur capture
final int numPixels=widthCapture*heightCapture; // nombre de pixels d'une image video
final int fpsCapture=30;     // taux d’images/secondes

// Quelques couleurs...
final int rouge = color(255, 0, 0);  
final int vert  = color(0, 255, 0); 
final int bleu  = color(0, 0, 255);
final int noir  = color(0, 0, 0); 
final int blanc = color(255, 255, 255);

// Declaration des variables globales
String[] cameras;    // Liste des cameras dispos
Capture webCam;      // Declaration de la Capture par Camera
PImage imagePrecedente = null;
PImage imageActuelle = null;
PImage differenceDesDeuxImages;
SoundFile alarme;

float precisionDePresence;

boolean flagZic = true;


// Fonction d'initialisation de l'application - executee une seule fois
void setup() {
  // Initialisation des parametres graphiques utilises
  size(640, 480); // Ouverture en mode normal 640 * 480
  surface.setTitle("Exemple 4 - La WebCam - E. Mesnard / ISIMA");
  colorMode(RGB, 255, 255, 255); // fixe format couleur R G B pour fill, stroke, etc...
  noFill(); // pas de remplissage
  stroke(rouge); // couleur pourtour RGB - noStroke() si pas de pourtour
  background(noir); // couleur fond fenetre

  differenceDesDeuxImages = new PImage(widthCapture, heightCapture);
  
  precisionDePresence = 0.20;
  
  alarme = new SoundFile(this, "alarme.mp3");
  // Recherche d'une webcam 
  cameras = Capture.list();
  if (cameras.length == 0) {
    println("Pas de Webcam sur cet ordinateur !");
    exit();
  } else {
    // Initialisation de la webcam Video par defaut
    //webCam = new Capture(this, widthCapture, heightCapture, cameras[0], fpsCapture);
    webCam = new Capture(this, widthCapture, heightCapture, "QuickCam for Notebooks Deluxe", fpsCapture);
    webCam.start(); // Mise en marche de la webCam
  }
} // Fin de Setup


// Fonction de re-tracage de la fenetre - executee en boucle
void draw() {  
  color currColorPrece, currColorActu; // Couleur du pixel courant...
  int Rprece, Gprece, Bprece, Ractu, Gactu, Bactu; // equivalente a cette forme sous 3 composantes couleurs
  
  int erreur = 50;
  
  int compteurPresence = 0;

  if (webCam.available() == true) { // Verification de presence d'une nouvelle frame
    webCam.read(); // Lecture du flux sur la camera... lecture d'une frame
    

    imageActuelle = webCam.get();
    
    imageMirroir(imageActuelle);
    
    if (imagePrecedente !=null) {

      // Analyse de l'image
      for (int i=0; i<heightCapture * widthCapture; i++) {
        currColorPrece = imagePrecedente.pixels[i]; // ... recuperation couleur
        // separation des composantes R, G et B
        Rprece = (int) red(currColorPrece);
        Gprece = (int) green(currColorPrece);
        Bprece = (int) blue(currColorPrece);

        currColorActu = imageActuelle.pixels[i]; // ... recuperation couleur
        // separation des composantes R, G et B
        Ractu = (int) red(currColorActu);
        Gactu = (int) green(currColorActu);
        Bactu = (int) blue(currColorActu);

        differenceDesDeuxImages.loadPixels();
        
        if ((Rprece - erreur <= Ractu && Ractu <= Rprece + erreur) && (Gprece - erreur <= Gactu && Gactu <= Gprece + erreur) && (Bprece - erreur <= Bactu && Bactu <= Bprece + erreur)) {
          differenceDesDeuxImages.pixels[i] = color(Ractu, Gactu, Bactu);
        }
        else {
          differenceDesDeuxImages.pixels[i] = color(rouge);
          compteurPresence++;
        }
        differenceDesDeuxImages.updatePixels();
        
      }
      imagePrecedente = imageActuelle.get();
      image(differenceDesDeuxImages, 0, 0); // Restitution de l'image captee sur la webCam
      if(compteurPresence/(float)(widthCapture*heightCapture)>=precisionDePresence && flagZic){
         alarme.play();
         flagZic = false;
         println(compteurPresence/(float)(widthCapture*heightCapture));
      }
    }
    else { // Première fois dans la boucle, l'image précédente n'est pas initialisée donc on refait un tour de boucle
      imagePrecedente = webCam.get();
      imageMirroir(imagePrecedente);
    }
  }
}

void imageMirroir(PImage image) {
  int h, w, ligne;
  h = image.height;
  w = image.width;
  
  color sauvegardePixel;
  
  for(int y=0; y<h; y++){
     ligne = y * w; 
     for(int x=0; x<w/2; x++){
       if(y!=0){
         sauvegardePixel = image.pixels[ligne + x];
         image.loadPixels();
         image.pixels[ligne + x] = image.pixels[ligne - 1 - x];
         image.pixels[ligne - 1 - x] = sauvegardePixel;
         image.updatePixels();
       }
       else {
         image.loadPixels();
         sauvegardePixel = image.pixels[x];
         image.pixels[x] = image.pixels[w - 1 - x];
         image.pixels[w - 1 - x] = sauvegardePixel;
         image.updatePixels();
       }
     }
  }
}