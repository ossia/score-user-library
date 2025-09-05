/*{
  "DESCRIPTION": "triangle tunnel",
  "CREDIT": "leon (ported from https://www.vertexshaderart.com/art/5y8GykbHCskE8dzPd)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 609,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1640257980828
    }
  }
}*/


const float pi = 3.1415;
const float tau = 6.283;
#define ss(a,b,t) (smoothstep(a,b,t))
#define wr(a) (a*.5+.5)
mat2 rot(float a) { float c=cos(a), s=sin(a); return mat2(c,-s,s,c); }

void main()
{
  // element indices
  float i = floor(vertexId/3.) / vertexCount * 3.;
  float layers = 14.;
  float ii = floor(i*layers);
  float il = ii/layers;
  i = i*layers;
  float ia = i * tau;
  vec2 circle = vec2(cos(ia),sin(ia));

  // triangle indices
  float tri = fract(vertexId/3.);
  float tria = tri * tau;
  float top = step(mod(vertexId, 3.), 0.5);

  // parameters
  float speed = 0.5;
  float size = 0.05;
  float radius = 0.5;
  float height = 0.1;

  // fade size
  float anim = fract(time*speed-il);
  size *= sin(anim*pi);
  height *= sin(anim*pi);

  // triangle shape
  vec2 uv = vec2(cos(tria + ia),sin(tria + ia));
  vec3 pos = vec3(0);
  pos.xy += uv * size * (1.-top);
  pos.z -= top * height;

  // translate
  pos.z -= ((anim)*2.-1.)*.5;

  // circle distribution
  pos.xy += circle*radius;

  // camera rotation
  pos.xz *= rot(sin(time*speed)*.3);
  pos.yz *= rot(cos(time*speed)*.3);

  // origin offset
  pos.z += 1.;

  // perspective
  pos.xy = pos.xy / max(0.01,pos.z);
  pos.x *= resolution.y/resolution.x;

  // result
  gl_Position = vec4(pos.xy, 0, 1);
  v_color = vec4(1.-top);
}