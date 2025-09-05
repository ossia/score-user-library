/*{
  "DESCRIPTION": "VM in GPU",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/uQsrjwoCeqSersLA9)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 488,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.08235294117647059,
    0.08235294117647059,
    0.08235294117647059,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 99,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1499894692765
    }
  }
}*/

#define MAX_STACK 8

// Define asembly for our vm.

#define NOP 0

#define REX 1
#define REY 2

#define SUM 3
#define MIS 4

#define MUL 5
#define DIV 6

#define SIN 7
#define COS 8

#define LFC 9

#define LNC 10
#define GCP 11

// Varibales for programm and programms length.

/*uniform */ int prog [256];
/*uniform */ int progLength;

// Precalculated constants.

/*uniform */ float consts [256];

float getConsts(int id) {
    for (int i=0; i<256; i++) {
        if (i == id) return consts[i];
    }
}

// Stack.
float stack [MAX_STACK];

float getStack(int id) {
    for (int i=0; i<MAX_STACK; i++) {
        if (i == id) return stack[i];
    }
}
void setStack(int id,float value) {
    for (int i=0; i<MAX_STACK; i++) {
        if (i == id) stack[i] = value;
    }
}

void main() {

  consts[0] = 6.28; // PI2
  consts[1] = .0;
  consts[2] = .0;

  prog[0] = LNC;
  prog[1] = LFC;
  prog[2] = 0;
  prog[3] = DIV;
  prog[4] = GCP;
  prog[5] = MUL;
  prog[6] = COS;
  prog[7] = LFC;
  prog[8] = 1;
  prog[9] = SUM;
  prog[10] = REX;

  prog[11] = LNC;
  prog[12] = LFC;
  prog[13] = 0;
  prog[14] = DIV;
  prog[15] = GCP;
  prog[16] = MUL;
  prog[17] = SIN;
  prog[18] = LFC;
  prog[19] = 2;
  prog[20] = SUM;
  prog[21] = REY;

  progLength = 22;

  int stackPtr = 0;
  bool argFlag = false;

  float a,b = 0.0;

  float x = 0.;
  float y = 0.;

  for(int pCt = 0;pCt<256;pCt++){

   if(pCt>=progLength)
    {
      break;
    }

    if(argFlag)
    {
      argFlag = false;
      continue;
    }

   if (prog[pCt]==NOP)
    {
     // Do nothing.
   } else if (prog[pCt]==REX)
    {
     x = getStack(--stackPtr);
   } else if (prog[pCt]==REY)
    {
     y = getStack(--stackPtr);
   } else
   if (prog[pCt]==SUM){
     a = getStack(--stackPtr);
        b = getStack(--stackPtr);
        setStack(stackPtr++, a+b);
   } else
   if (prog[pCt]==MIS){
     a = getStack(--stackPtr);
        b = getStack(--stackPtr);
        setStack(stackPtr++, a-b);
   } else
   if (prog[pCt]==MUL){
     a = getStack(--stackPtr);
        b = getStack(--stackPtr);
        setStack(stackPtr++, a*b);
   } else
   if (prog[pCt]==DIV){
     a = getStack(--stackPtr);
        b = getStack(--stackPtr);
        setStack(stackPtr++, a/b);
   } else
   if (prog[pCt]==SIN){
     setStack(stackPtr-1, sin(getStack(stackPtr-1)));
   } else
   if (prog[pCt]==COS){
     setStack(stackPtr-1, cos(getStack(stackPtr-1)));
   } else
   if (prog[pCt]==LFC){
     setStack(stackPtr++,getConsts(prog[pCt+1]));
       argFlag = true;
   } else
   if (prog[pCt]==LNC){
     setStack(stackPtr++,vertexCount );
   } else
   if (prog[pCt]==GCP){
     setStack(stackPtr++,vertexId );
   }

  }

  gl_Position = vec4(x,y,0,1);
  gl_PointSize = 3.;
  v_color = vec4(1, 1, 1, 1);
}