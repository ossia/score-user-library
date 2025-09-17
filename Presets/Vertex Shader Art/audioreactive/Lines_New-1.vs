/*{
  "DESCRIPTION": "Lines New - Li Yuchun\u674e\u5b87\u6625",
  "CREDIT": "markus (ported from https://www.vertexshaderart.com/art/cjTYyd8z2yEWqYFeg)",
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
      "$date": 1605109030736
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

  v+= 10.0*pow(texture(sound,vec2(u,0.0)).r,5.0);

  float x = (u*200.0)-10.0;
  float y = 0.0;
  gl_PointSize = 100.0;
  gl_Position = vec4(x,y,0,1);

  float lum = floor(v *10.0 + 1.9)/10.0;
  //float lum = 1.0;
  v_color = vec4(v*lum*0.4,lum*0.2,lum*1.0,1);

}