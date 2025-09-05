/*{
  "DESCRIPTION": "residuallines - Li Yuchun\u674e\u5b87\u6625",
  "CREDIT": "markus (ported from https://www.vertexshaderart.com/art/4rzpKJ43tFQEsLBkP)",
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
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 63,
    "ORIGINAL_DATE": {
      "$date": 1598624281809
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
  float osc = sin(200.0*time+u*250.0);
  v+= 15.0*pow(texture(sound,vec2(u,0.0)).r,5.0);
  float vold = 1.0*pow(texture(sound,vec2(u,0.81)).r,10.0);
  float x = (u*10.0)-1.0;
  float y = 0.0;//((v + vold)*0.5);//*osc;
  gl_PointSize = 300.0;
  gl_Position = vec4(x,y,0,1);
  float lum = floor(v *10.0 + 0.7)/30.0;
  //float lum = floor(v *30.0 + 0.9)/5.0;
  //v_color = vec4(lum*0.5,0.0,0.0,v);
  //v_color = vec4(lum*0.6,lum*0.5,lum*1.0,v);
  /*vec2 soundTexCoords = vec2(0, 0);
  float r = texture(sound, soundTexCoords).r;
  r = r * 1.3;
  r = pow(r, 4.);
*/
  v_color = vec4(v*lum*0.6,lum*0.2,lum*1.0,1);
  //v_color = vec4(v * 2. - 0.1, 0, 1, 1);

}