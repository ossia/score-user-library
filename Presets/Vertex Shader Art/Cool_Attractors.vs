/*{
  "DESCRIPTION": "Cool Attractors",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/kpxXuKKj3zwRaQ23J)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 45000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.1803921568627451,
    0.2627450980392157,
    0.25098039215686274,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 105,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1687283122795
    }
  }
}*/

#define pi 3.14159
#define Dir(a) vec2(cos(a), sin(a))

void main() {
  float vc = vertexCount;
  float svc = sqrt(vertexCount);
  float id = vertexId;
  id /= vc;

  float t = 0.3 * time;

  vec2 uv = vec2(mod(vertexId, svc), floor(vertexId / svc)) / svc - 0.5;

  float d = 0.;
  const float n = 12.;
  for (float i = 0.; i < n; i++) {
   float a = atan(uv.y, uv.x);
   vec2 dir = 0.1 * sin(2.*a + t) * Dir(8.*pi*uv.x)
        + 0.1 * cos(2.*a + t) * Dir(8.*pi*uv.y);
   d += length(dir);
   uv += dir;
  }

  gl_Position = vec4(uv, 0, 1);
  gl_PointSize = 3.*(1.-exp(-0.5*d*d));
  v_color = vec4(4. * exp(-d*d));
}
