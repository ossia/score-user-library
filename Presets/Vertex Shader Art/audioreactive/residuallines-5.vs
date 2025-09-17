/*{
  "DESCRIPTION": "residuallines",
  "CREDIT": "spotline (ported from https://www.vertexshaderart.com/art/ZTAvJzo5HJdr2FsZK)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 3000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0.00784313725490196,
    0.09019607843137255,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 455,
    "ORIGINAL_LIKES": 4,
    "ORIGINAL_DATE": {
      "$date": 1447022075702
    }
  }
}*/

#define NUM_POINTS 5000.0
#define K 1.059463094359295264561825294946
#define FIT_VERTICAL

void main()
{

  float u = vertexId/IMG_SIZE(sound).x;
  float v = 0.0;
  float osc = sin(200.0*time+u*250.0);
  v+= 2.0*pow(texture(sound,vec2(u,0.0)).r,6.0);
  float vold = 1.0*pow(texture(sound,vec2(u,0.51)).r,10.0);
  float x = (u*10.0)-0.8;
  float y = 0.0;//((v + vold)*0.5);//*osc;
  gl_PointSize = 800.0;
  gl_Position = vec4(x,y,0,1);
  float lum = floor(v *20.0 + 0.7)/10.0;
  v_color = vec4(lum*0.6,lum*0.6,lum*1.0,v);
}