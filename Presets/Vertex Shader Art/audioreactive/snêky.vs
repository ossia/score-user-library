/*{
  "DESCRIPTION": "sn\u00eaky",
  "CREDIT": "kolargon (ported from https://www.vertexshaderart.com/art/78PSuMWSJy9qmzeCm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
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
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 152,
    "ORIGINAL_DATE": {
      "$date": 1518901129127
    }
  }
}*/

//In progress. Based on http://glslsandbox.com/e#29475.0

#define RESOLUTION_MIN min(resolution.x, resolution.y)
#define ASPECT (resolution.xy/RESOLUTION_MIN)

vec2 project(vec2 position, vec2 a, vec2 b);
float bound(vec2 position, vec2 normal, float translation);
float sphere(vec2 position, float radius);
float torus(vec2 position, vec2 radius);
float cube(vec2 position, vec2 scale);
float simplex(vec2 position, float scale);
float segment(vec2 position, vec2 a, vec2 b);

float contour(float x);
float point(vec2 position, float radius);
float point(vec2 position);
float circle(vec2 position, float radius);
float line(vec2 p, vec2 a, vec2 b);
float box(vec2 position, vec2 scale);
float triangle(vec2 position, vec2 scale);
mat2 rmat(float t);

void main ()
{
   float finalDesiredPointSize = 4.;
   float maxFinalSquareSideSize = floor(sqrt(vertexCount));
   float finalMaxVertexCount = maxFinalSquareSideSize*maxFinalSquareSideSize;

  //first the number of elements in a line
  float across = floor(maxFinalSquareSideSize *resolution.x/resolution.y);
  //finalDesiredPointSize = resolution.x/across;
  //we want to keep the resolution >> across/down must be the same as resolution.x/resolution.y
  //across = across*resolution.x/resolution.y;

  //then the number of possible lines with the given vertexCount
  float down = floor(finalMaxVertexCount / across);

  //we can now calculate the final number of elements
  float finalVertexCount = across*down;

  //and the consequent finalVertexId
  float finalVertexId = mod(vertexId,finalVertexCount);

  //Now we calculate the position of the elements based on their finalVertexId
  float x = mod(finalVertexId, across);
  float y = floor(finalVertexId / across);

  float u = (x /across);
  float v = (y /down);

  float u0 = (u * (across*finalDesiredPointSize/resolution.x));
  float v0 = (v * (across*finalDesiredPointSize/resolution.x ));

  float ux = u0 - 0.5*(across*finalDesiredPointSize/resolution.x);
  float vy = v0- 0.5*(across*finalDesiredPointSize/resolution.x);;

   if(u>0.5)
    u = 1.-u;

  float udnd = u;
  if(u>0.5)
    udnd = 1.-u;

  float snd = texture(sound, vec2(0., udnd)).r;

    //apply fragment logic

 vec2 fragcoord = vec2(x,y);
    vec2 newResolution = vec2(across, down);

   vec2 uv = vec2(u,v);//fragcoord.xy/resolution.xy;
 vec2 p = uv - .5;
 p *= ASPECT;
 //p = normalize(vec3(p, 1.-length(p))).xy;

 vec2 m = vec2(2.*sin(time*.004), cos(time*.003)) - .5;
 m *= ASPECT;
 m *= 2.;
 float c = 0.;
 float b = 0.;
 float t = 0.;

 vec2 d = normalize(m-p);

 mat2 rm = rmat(m.x*(8.*atan(1.)));
 for(int i = 0; i < 48; i++)
 {
  p = abs(p)-.5;
  p *= rm;
 // p = p/dot(p,p);
  c += circle(p, .25);
  b += box(p, vec2(.5));
  t += triangle(p, vec2(.5));
  p *= 1. + 32.*fract(.001);

 }

 vec4 result = vec4(0.);

 result.x += c;
 result.z += t;
 result.y += b;

 result.w = 1.;

 //gl_FragColor = result;

  gl_Position = vec4(ux, vy*snd, 0, 1);

  gl_PointSize = finalDesiredPointSize;

  v_color = result;

}

float contour(float x)
{
 return 1.-clamp(.6 * x * RESOLUTION_MIN, 0., 1.);
}

vec2 project(vec2 position, vec2 a, vec2 b)
{
 vec2 q = b - a;
 float u = dot(position - a, q)/dot(q, q);
 u = clamp(u, 0., 1.);
 return mix(a, b, u);
}

float bound(vec2 position, vec2 normal, float translation)
{
  return dot(position, normal) + translation;
}

float sphere(vec2 position, float radius)
{
 return length(position)-radius;
}

float torus(vec2 position, vec2 radius)
{

 return abs(abs(length(position)-radius.x)-radius.y);
}

float cube(vec2 position, vec2 scale)
{
 vec2 vertex = abs(position) - scale;
 vec2 edge = max(vertex, 0.);
 float interior = max(vertex.x, vertex.y);
 return min(interior, 0.) + length(edge);
}

float simplex(vec2 position, float scale)
{
 const float r3 = 1.73205080757;//sqrt(3.);

 position.y /= r3;

 vec3 edge = vec3(0.);
 edge.x = position.y + position.x;
 edge.y = position.x - position.y;
 edge.z = position.y + position.y;
 edge *= .86602540358; //cos(pi/6.);

 return max(edge.x, max(-edge.y, -edge.z))-scale/r3;
}

float segment(vec2 position, vec2 a, vec2 b)
{
 return distance(position, project(position, a, b));
}

float point(vec2 position, float radius)
{
 return contour(sphere(position*RESOLUTION_MIN, radius));
}

float point(vec2 position)
{
 return point(position, 3.);
}

float circle(vec2 position, float radius)
{
 return contour(torus(position, vec2(radius,0.)));
}

float line(vec2 p, vec2 a, vec2 b)
{
 return contour(segment(p, a, b));
}

float box(vec2 position, vec2 scale)
{
 return contour(abs(cube(position, scale)));
}

float triangle(vec2 position, vec2 scale)
{
 return contour(abs(simplex(position, scale.x)));
}

mat2 rmat(float t)
{
 float c = cos(t);
 float s = sin(t);
 return mat2(c, s, -s, c);
}
