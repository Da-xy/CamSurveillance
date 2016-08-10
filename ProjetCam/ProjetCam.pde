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


AudioContext ac;

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
  

  
  ac = new AudioContext();
  SamplePlayer player = new SamplePlayer(ac, SampleManager.sample("C:\\Users\\Dgeyd\\Documents\\GitHub\\camProject\\ProjetCam\\data\\alarme.mp3"));
  //SamplePlayer player = new SamplePlayer(ac, SampleManager.sample("/home/pi/git/camProject/ProjetCam/data/alarme.mp3"));
  Gain g = new Gain(ac, 2, 0.2);
  g.addInput(player);
  ac.out.addInput(g);
  
  differenceDesDeuxImages = new PImage(widthCapture, heightCapture);
  
  precisionDePresence = 0.05;
  
  // Recherche d'une webcam 
  cameras = Capture.list();
  if (cameras.length == 0) {
    println("Pas de Webcam sur cet ordinateur !");
    exit();
  } else {
    // Initialisation de la webcam Video par defaut
    webCam = new Capture(this, widthCapture, heightCapture, cameras[0], fpsCapture);
    //webCam = new Capture(this, widthCapture, heightCapture, "QuickCam for Notebooks Deluxe", fpsCapture);
    webCam.start(); // Mise en marche de la webCam
  }
} // Fin de Setup


// Fonction de re-tracage de la fenetre - executee en boucle
void draw() {  
  color currColorPrece, currColorActu; // Couleur du pixel courant...
  int Rprece, Gprece, Bprece, Ractu, Gactu, Bactu; // equivalente a cette forme sous 3 composantes couleurs
  
  int erreur = 50; // Pour éviter qu'il y ait trop d'erreurs dans l'approximation du pixel on met une erreur de 50 dans la couleur.
  
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
      if(compteurPresence/(float)(widthCapture*heightCapture)>=precisionDePresence && !ac.isRunning()){ // Test si on a une proportion de pixel changé supérieur à 5% et on vérifie que le son ne fonctionne pas déjà
         ac.start(); // Démarrage son
         println(compteurPresence/(float)(widthCapture*heightCapture));
      }
      if(ac.getTime()>=5000){ // Après 5 sec d'alarme on coupe le son et on reset.
        ac.stop();
        ac.reset();
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
       else { //<>//
         image.loadPixels();
         sauvegardePixel = image.pixels[x];
         image.pixels[x] = image.pixels[w - 1 - x];
         image.pixels[w - 1 - x] = sauvegardePixel;
         image.updatePixels();
       }
     }
  }
}