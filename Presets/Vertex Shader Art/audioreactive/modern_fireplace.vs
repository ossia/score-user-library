/*{
  "DESCRIPTION": "modern_fireplace",
  "CREDIT": "spotline (ported from https://www.vertexshaderart.com/art/PmRwSpR6jxkbJgsE4)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles",
    "Nature"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 718,
    "ORIGINAL_LIKES": 5,
    "ORIGINAL_DATE": {
      "$date": 1447264518163
    }
  }
}*/

#define K 1.0594630943592952645618

vec4 hueRamp(vec4 col)
{
  vec4 blu = vec4(0.1,0.05,0.1,1.0);
  vec4 red = vec4(0.5,0.1,0.1,1.0);
  vec4 result = mix(blu,red,col.a*60.0-0.1);
  return result;
}

void main()
{
  float W = 400.0;
  float H = 250.0;
  float u = 0.0;
  float v = 0.0;
  u = mod(vertexId/W,1.0);
  v = floor(vertexId/W)/H;
  float uScaled = pow(2.0,u*0.17)-1.0;
  float vScaled = pow(abs(v-0.5)*1.0,1.3);

  v_color = vec4(pow(texture(sound,vec2(uScaled,vScaled)).r,8.0));
  v_color = hueRamp(v_color);

  float x = v*-2.0 + 1.0;
  float y;
  y = u*2.0 - 0.8 + 0.5*pow(x,2.0);
  gl_PointSize = 12.0;
  gl_Position = vec4(x,y,0,1);
}
