/*{
  "DESCRIPTION": "Straight Lines",
  "CREDIT": "markus (ported from https://www.vertexshaderart.com/art/GG222nK5QwLhaPBqp)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 80976,
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
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1589922530622
    }
  }
}*/

#define K 1.0594630943592952645618

vec4 hueRamp(vec4 col)
{
  vec4 black = vec4(0.0,0.,0.0,1.0);
  vec4 main = vec4(0.3,0.1,0.8,1.0);
  vec4 result = mix(black,main,col.a*10.0-0.5);
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

  v_color = vec4(pow(texture(sound,vec2(uScaled,vScaled)).r,5.0));
  v_color = hueRamp(v_color);

  float x = v*-2.0 + 1.0;
  float y;
  y = u*2.0 - 0.8;
  gl_PointSize = 12.0;
  gl_Position = vec4(x,y,0,1);
}
