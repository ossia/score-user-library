/*{
  "DESCRIPTION": "Lines Explained",
  "CREDIT": "markus (ported from https://www.vertexshaderart.com/art/opSgihs7RaD5mY8E3)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 3000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 19,
    "ORIGINAL_DATE": {
      "$date": 1605596191956
    }
  }
}*/

#define NUM_POINTS 500.0
#define K 1.059463094359295264561825294946
#define FIT_VERTICAL

void main()
{

  float u = vertexId/IMG_SIZE(sound).x;
  float v = 0.0;

  v+= 10.0*pow(texture(sound,vec2(u,0.0)).r,5.0); // last value for overall peak of color

  float x = (u*10.0)-1.0;
  float y = 0.0;
  gl_PointSize = 40.0;
  gl_Position = vec4(x,y,0,0.1); // change last value for resolution

  float lum = floor(v *10.0 + 1.9)/20.0;
  //float lum = 1.0; // tester
  v_color = vec4(v*lum*0.4,lum*0.2,lum*1.0,1); // v * lum * R, lum * G, lum * B, ?

}