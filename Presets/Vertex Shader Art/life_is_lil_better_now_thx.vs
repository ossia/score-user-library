/*{
  "DESCRIPTION": "life is lil' better now thx",
  "CREDIT": "lambmeow (ported from https://www.vertexshaderart.com/art/5YGSiNrquYpFi3Ggo)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 94,
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
    "ORIGINAL_VIEWS": 142,
    "ORIGINAL_DATE": {
      "$date": 1496286112655
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float rand(float p){
   return fract(sin(p*10000./time));
}

float noise(vec2 p)
{
  return rand((p.x + p.y) * 1000.00);
}

void main() {
   float samp = texture(sound,vec2(0.34,0.)).r + texture(sound,vec2(0.0,0.)).r;
  samp /=2.;
  vec2 uv = vec2(sin(time+ vertexId + time),tan(time + vertexId ));
  uv *= samp + .5;
  gl_Position = vec4(uv,0,1);
  gl_PointSize = 100.;

  v_color = vec4(1);
  v_color.a*= noise(uv *time);
  vec3 gdlw = vec3(texture(sound, vec2(0.05,0.)).r * sin(time + vertexId) ,texture(sound,vec2(50.*0.005,0.)).r *cos(time * vertexId) , (sin(vertexId - time)));
  v_color.rgb *= gdlw;
  }