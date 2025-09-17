/*{
  "DESCRIPTION": "Oklab Color Space - [https://bottosson.github.io/posts/oklab/](https://bottosson.github.io/posts/oklab/)",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/cznhWtArrLFqxJgAf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Particles"
  ],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1608842208340
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

float cbrt(float n) {
  float x = 1.0;
  for (int i = 0; i < 10; ++i) {
    x = (2.0 * x + n / (x * x)) / 3.0;
  }
  return x;
}

vec3 rgb2oklab(vec3 c)
{
    float l = dot(c, vec3(0.4121656120, 0.5362752080, 0.0514575653));
    float m = dot(c, vec3(0.2118591070, 0.6807189584, 0.1074065790));
    float s = dot(c, vec3(0.0883097947, 0.2818474174, 0.6302613616));

    float l_ = cbrt(l);
    float m_ = cbrt(m);
    float s_ = cbrt(s);

    return vec3(
        0.2104542553*l_ + 0.7936177850*m_ - 0.0040720468*s_,
        1.9779984951*l_ - 2.4285922050*m_ + 0.4505937099*s_,
        0.0259040371*l_ + 0.7827717662*m_ - 0.8086757660*s_);
}

vec3 oklab2rgb(vec3 c)
{
    float l_ = c.x + 0.3963377774 * c.y + 0.2158037573 * c.z;
    float m_ = c.x - 0.1055613458 * c.y - 0.0638541728 * c.z;
    float s_ = c.x - 0.0894841775 * c.y - 1.2914855480 * c.z;

    float l = l_*l_*l_;
    float m = m_*m_*m_;
    float s = s_*s_*s_;

    return vec3(
        + 4.0767245293*l - 3.3072168827*m + 0.2307590544*s,
        - 1.2681437731*l + 2.6093323231*m - 0.3411344290*s,
        - 0.0041119885*l - 0.7034763098*m + 1.7068625689*s);
}

vec3 hsl2rgb(vec3 c) {
  float C = c.y;
  float h = c.x;
  float a = C * cos(h * PI * 2.0);
  float b = C * sin(h * PI * 2.0);
  float L = c.z;
  return oklab2rgb(vec3(L,a,b));
}

void main() {
  float across = floor(sqrt(vertexCount));
  float down = floor(vertexCount / across);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (down - 1.0);

  float xu = u * 2.0 - 1.0;
  float yv = v * 2.0 - 1.0;

  gl_Position = vec4(xu, yv, 0, 1);
  gl_PointSize = 10.0;

  v_color= vec4(hsl2rgb(vec3(u, 0.2, 1.)), 1);

}