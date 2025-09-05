/*{
  "DESCRIPTION": "sillage",
  "CREDIT": "spotline (ported from https://www.vertexshaderart.com/art/5ppKAhtsPPS3xfam7)",
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
    0.12941176470588237,
    0.27058823529411763,
    0.8470588235294118,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 196,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1446311700357
    }
  }
}*/

#define NUM_POINTS 5000.0
//#define FIT_VERTICA

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
  float u = (float(vertexId)/NUM_POINTS) * 2.0 - 1.0;
  float v = 0.0;
  float ucoor = log((abs(u)*.5 + 1.0));
  v+= floor(texture(sound,vec2(ucoor,0.0)).r * 15.0)/10.0;
  float osc = 0.2*cos(1.*(1.1*time+3.0*(abs(u)+1.0)));
  float osc2 = 0.2*cos(1.*(-1.5*time+10.0*(u+1.0)));
  float x = u * 2.0;
  float y = v -0.5 + 0.5*pow(x,2.0) + osc +osc2;
  gl_Position = vec4(x,y,0,1);
  float colorfactor = pow(rand(vec2(x,y)),8.);
  gl_PointSize = v*6.0 + colorfactor*1.0;
  float r = mix(0.9,1.,colorfactor);
  float g = mix(0.9,1.,colorfactor);
  float b = 1.;

  v_color = vec4(r,g,b,colorfactor+0.5);
}