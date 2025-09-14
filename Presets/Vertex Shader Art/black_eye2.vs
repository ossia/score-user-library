/*{
  "DESCRIPTION": "black eye2",
  "CREDIT": "trip-les-ix (ported from https://www.vertexshaderart.com/art/LDxR3x6bY8ujTYt3M)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
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
  "INPUTS": [ { "LABEL": "Volume", "NAME": "volume", "TYPE": "audioFloatHistogram" }, { "LABEL": "Sound", "NAME": "floatSound", "TYPE": "audioFloatHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 123,
    "ORIGINAL_DATE": {
      "$date": 1644479629422
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 1.0)
#define STEP 2.0

float radius = 0.15;
float amount = 100.;
float len = vertexCount / amount;

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, .0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + .02);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (2.0 - d.y);
}

void main() {
  float ratio = resolution.x / resolution.y;
  float seg = floor(vertexId/len);
  float segId = mod(vertexId,len);
  float v = texture(volume, vec2(1., (2.-seg)/amount*2.)).a;
  float s = texture(floatSound, vec2(1., (1.+segId)/len*240.)).a;
  vec3 p = vec3(vertexId * 0.005, seg, time*0.1 - segId*0.001);
  float n = noise(p);
  float x = cos(vertexId/vertexCount * PI * 2.)*(v*radius+segId*0.001);
  float y = sin(vertexId/vertexCount * PI * 2.)*ratio*(v*radius+segId*0.0001);

  x += cos(n * PI*4.) * segId * 0.000002 * s;
  y += sin(n * PI*4.) * segId * 0.0000015 * s * ratio;

  gl_Position = vec4(x/v-x/s, y/v, y-0.1, 1);

  float b = 2.3 / mod(vertexId/len,21.3);
  v_color = vec4(vec3(b), 1.915);
}