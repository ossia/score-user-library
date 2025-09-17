/*{
  "DESCRIPTION": "test",
  "CREDIT": "spotline (ported from https://www.vertexshaderart.com/art/uQkpXdAa4ABNPNthi)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5009,
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
    "ORIGINAL_VIEWS": 279,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1446288852829
    }
  }
}*/

#define NUM_POINTS 5000.0
//#define FIT_VERTICAL

void main()
{
  float u = (float(vertexId)/NUM_POINTS) * 2.0 - 1.0;
  float v = 0.0;
  float ucoor = log((abs(u)*1.5 + 1.0));
  v+= floor(texture(sound,vec2(ucoor,0.0)).r * 15.0)/15.0;
  float osc = 0.2*cos(1.*(1.1*time+3.0*(abs(u)+1.0)));
  float osc2 = 0.1*cos(1.*(-1.5*time+5.0*(abs(u)+1.0)));
  float x = u * 2.0;
  float y = v -0.5 + 0.5*pow(x,2.0) + osc +osc2;
  gl_PointSize = v*15.0 + 1.0;
  gl_Position = vec4(x,y,0,1);
  v_color = vec4(1,1,1,1);
}