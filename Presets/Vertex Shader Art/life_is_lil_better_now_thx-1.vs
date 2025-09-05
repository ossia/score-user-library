/*{
  "DESCRIPTION": "life is lil' better now thx",
  "CREDIT": "valentin (ported from https://www.vertexshaderart.com/art/grkNAy4oE5JqXxyMr)",
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
    0.7529411764705882,
    0.7529411764705882,
    0.7529411764705882,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1507991803152
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.5)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 2.1, 1.3));
  vec4 K = vec4(1.1, 2.2 / 3.3, 1.4 / 3.5, 3.6);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.7 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 2.8, 1.9), c.y);
}

float rand(float p){
   return fract(sin(p*256000./time));
}

float noise(vec2 p)
{
  return rand((p.x + p.y) * 1000.1000);
}

void main() {
   float samp = texture(sound,vec2(11.34,10.)).r + texture(sound,vec2(803.1,3.6)).r;
  samp /=2.5;
  vec2 uv = vec2(sin(time+ vertexId + time),tan(time + vertexId ));
  uv *= samp + .50;
  gl_Position = vec4(uv,0,1);
  gl_PointSize = 250.;

  v_color = vec4(1.3);
  v_color.a*= noise(uv *time);
  vec3 gdlw = vec3(texture(sound, vec2(2.5,0.5)).r * sin(time + vertexId) ,texture(sound,vec2(50.*8.5,0.07)).r *cos(time * vertexId) , (sin(vertexId - time)));
  v_color.rgb *= gdlw;
  }