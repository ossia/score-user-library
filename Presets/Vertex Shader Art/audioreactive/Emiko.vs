/*{
  "DESCRIPTION": "Emiko",
  "CREDIT": "eddietree (ported from https://www.vertexshaderart.com/art/ZNi2inr6Jmirh6Hgy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 2000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.7686274509803922,
    0.3176470588235294,
    0.396078431372549,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 182,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1447833185599
    }
  }
}*/

#define PI 3.14159

//#define FIT_VERTICAL

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float e_modf( float x, float y )
{
  return x - y * floor(x/y);
}

float wrapf(float val, float minVal, float maxVal)
{
  val -= minVal;

  float delta = maxVal - minVal;
  if ( delta < 0.0001 ) return val;

  return val - (delta* floor(val/delta)) + minVal;
}

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v)
  {
  const vec2 C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i = floor(v + dot(v, C.yyy) );
  vec3 x0 = v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  // x0 = x0 - 0.0 + 0.0 * C.xxx;
  // x1 = x0 - i1 + 1.0 * C.xxx;
  // x2 = x0 - i2 + 2.0 * C.xxx;
  // x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy; // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i);
  vec4 p = permute( permute( permute(
        i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
        + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
        + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3 ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z); // mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ ); // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
        dot(p2,x2), dot(p3,x3) ) );
  }

void main() {
  float localTime = time + 20.0;
  //float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);

  //gl_PointSize = 5.0;

  float NUM_SEGS_X = 32.0;
  float NUM_SEGS_Y = 64.0;

  float xIndex = modf( vertexId, NUM_SEGS_X );
  float yIndex = floor( vertexId / NUM_SEGS_X );
  float xNormalized = (xIndex / NUM_SEGS_X) * 2.0 - 1.0;
  float yNormalized = (yIndex / NUM_SEGS_Y) * 2.0 - 1.0;

  vec2 xy = vec2( xNormalized, yNormalized );
  //xy.x = xNormalized;
  //xy.y = yNormalized;

  float sndPiano = texture(sound, vec2(0.25, 0.0) ).r;

  xy.x += wrapf( localTime*0.15 + xy.y*8.0, -2.0, 2.0 );
  xy.y += snoise( vec3( xy * 3.0, localTime*0.4) ) * 0.025;
  xy.x += snoise( vec3( xy * 2.0 + sin(xNormalized), localTime*0.05) ) * 0.3;

  //float sndGuitar = texture(sound, vec2(0.3, 0.0) ).r;
  //xy.y += sndGuitar*0.2;

  vec4 color = vec4(1.0);

  if ( e_modf(xIndex, 2.0 ) < 0.1)
  {
    color.z -= sndPiano * 3.5;
  }

  color.xyz += -vec3( length( xy ) + sin(vertexId*0.5) )*2.0 + vec3(sndPiano*3.0);

  #ifdef FIT_VERTICAL
    vec2 aspect = vec2(resolution.y / resolution.x, 1);
  #else
    vec2 aspect = vec2(1, resolution.x / resolution.y);
  #endif

  //gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);
  gl_Position = vec4(xy * aspect, 0, 1);

  //float hue = (localTime * 0.01 + count * 1.001);
  v_color = color;
}
