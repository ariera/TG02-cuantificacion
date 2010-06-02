/********************************************************
*                                                       *
*  15/02/2010                                           *
*  TÉCNICAS GRAFICAS - Ejercicio 2: Cuantificacion      *
*                                                       *
*  Alejandro Riera Mainar                               *
*  NºMat: 010381                                        *
*  ariera@gmail.com                                     *
*                                                       *
********************************************************/
float I0 = 0.02;
String FICHERO_IMAGEN = "gradiente.jpg"; // gradiente.jpg  -  lena.jpg  -  leonbn.jpg


/***** NO TOCAR ESTOS VALORES ******/
boolean intervalosLogaritmicos = false;
int niveles = 256; // Hasta un maximo de 256 y minimo de 2
int MAX = 256;
PImage img;
PImage output;
boolean LOGARITMICO=true;
boolean LINEAL=false;
//el primer indice referencia la potencia de 2 de los niveles de gris
//así paleta[3] devolverá la paleta para 16 niveles de gris [ 2^(3+1) = 16 ]
int[][] paletaLineal, paletaLogaritmica;

void setup() {
  img = loadImage(FICHERO_IMAGEN);
  size(2*img.width,img.height + 100);
  image(img,0,0);
  colorMode(HSB, MAX-1);
  output = createImage(img.width, img.height, HSB);
  inicializarPaletas();
  textFont(createFont("Helvetica", 18));
  fill(color(0));
  text("Pulse '+' y '-' para manejar el numero de niveles de gris\nESPACIO alterna entre Logaritmico y Lineal" , 10, img.height + 20);

}



void draw() {
  img.loadPixels();
  output.loadPixels();
  cuantificar(img, output);
  output.updatePixels();
  image(output,img.width,0);
  fill(color(0));
  rect(img.width, 0, 140, 20);
  fill(color(255));
  text((intervalosLogaritmicos ? "logartimico " : "    lineal ") + niveles, img.width+10, 17);

}

void cuantificar(PImage src, PImage dest){
  int loc=0;
  for (int y = 0; y < src.height; y++) {   
    for (int x = 0; x < src.width; x++) {
      loc = x + y*src.width;
      dest.pixels[loc] = calcularColor(src.pixels[loc]);
    }
  }
}


color calcularColor(color pixel){
  int[][] paleta;
  int intensidad = (int)brightness(pixel);
  if (intervalosLogaritmicos)
    paleta = paletaLogaritmica;
  else
    paleta = paletaLineal;
  return color(paleta[log2(niveles)-1][intensidad]);

}





/************** INICIALIZACION DE LAS PALETAS ***********************/
void inicializarPaletas(){
  paletaLineal = new int[8][];
  for(int i=0; i< paletaLineal.length; i++)
    paletaLineal[i]= calcularPaleta((int)pow(2,i+1), LINEAL);

  paletaLogaritmica = new int[8][];
  for(int i=0; i< paletaLogaritmica.length; i++)
    paletaLogaritmica[i]= calcularPaleta((int)pow(2,i+1), LOGARITMICO);
}

int log2(int x){
  return (int)(Math.log(x)/Math.log(2));
}


/***        calculo de una paleta              **********************/
int[] calcularPaleta(int niveles, boolean es_logaritimica){
  int j = 0;
  int[] intervalos = es_logaritimica ? calcularIntervalosLogaritmicos(niveles) : calcularIntervalosLineal(niveles);

  int[] colorIntervalos = calcularColorIntervalos(intervalos);
  int[] paleta = new int[MAX];


  for(int i=0; i<MAX; i++){
    if (j < niveles-1)
      if (i > intervalos[j+1])
        j++;
    paleta[i] = colorIntervalos[j];
  }
  return paleta;
}


int[] calcularIntervalosLogaritmicos(int niveles){
  int[] intervalos = new int[niveles];
  float[] intervalosNormalizados = new float[niveles];
  float k = 1 / I0;
  k = pow(k,1.0/(float)niveles);

  intervalosNormalizados[0]= I0;
  intervalos[0]= 0;
  for (int i = 1; i < niveles; i++) {   
    intervalosNormalizados[i]=intervalosNormalizados[i-1]*k;
    intervalos[i] = (int)(intervalosNormalizados[i] * (float)MAX);
  }  
  return intervalos;
}




int[] calcularIntervalosLineal(int niveles){
  int inc = MAX / niveles;
  int[] intervalos = new int[niveles];
  intervalos[0]=0;
  for (int i = 1; i < niveles; i++) {   
    intervalos[i]=intervalos[i-1]+inc;
  }
  return intervalos;
} 


int[] calcularColorIntervalos(int[] intervalos){
  int niveles = intervalos.length;
  int[] colorIntervalos = new int[niveles];
  for (int i = 0; i < niveles-1; i++) {   
    colorIntervalos[i]=intervalos[i+1];
  }
  colorIntervalos[niveles-1]=255;
  return colorIntervalos;
} 




/************** EVENTOS ********************/
void mousePressed(){
  niveles = niveles / 2;
  if (niveles == 1)
    niveles = MAX;
}

void keyPressed(){
  if (key == '+')
    niveles = niveles == MAX ? 2 : niveles*2;
  else if (key == '-')
    niveles = niveles == 2 ? MAX : niveles/2;
  else
    intervalosLogaritmicos = !intervalosLogaritmicos;
}














