/*{
  "DESCRIPTION": "sphere",
  "CREDIT": "leithba (ported from https://www.vertexshaderart.com/art/FtWQZjoHxqMK8dS5s)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 17442,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 168,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1638523574247
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0
#define phi PI * (3. - sqrt(5.))

// Simplex 4D Noise
// by Ian McEwan, Ashima Arts
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
float permute(float x){return floor(mod(((x*34.0)+1.0)*x, 289.0));}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
float taylorInvSqrt(float r){return 1.79284291400159 - 0.85373472095314 * r;}

vec4 grad4(float j, vec4 ip){
  const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
  vec4 p,s;

  p.xyz = floor( fract (vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
  s = vec4(lessThan(p, vec4(0.0)));
  p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www;

  return p;
}

float snoise(vec4 v){
  const vec2 C = vec2( 0.138196601125010504, // (5 - sqrt(5))/20 G4
        0.309016994374947451); // (sqrt(5) - 1)/4 F4
// First corner
  vec4 i = floor(v + dot(v, C.yyyy) );
  vec4 x0 = v - i + dot(i, C.xxxx);

// Other corners

// Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
  vec4 i0;

  vec3 isX = step( x0.yzw, x0.xxx );
  vec3 isYZ = step( x0.zww, x0.yyz );
// i0.x = dot( isX, vec3( 1.0 ) );
  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;

// i0.y += dot( isYZ.xy, vec2( 1.0 ) );
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;

  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;

  // i0 now contains the unique values 0,1,2,3 in each channel
  vec4 i3 = clamp( i0, 0.0, 1.0 );
  vec4 i2 = clamp( i0-1.0, 0.0, 1.0 );
  vec4 i1 = clamp( i0-2.0, 0.0, 1.0 );

  // x0 = x0 - 0.0 + 0.0 * C
  vec4 x1 = x0 - i1 + 1.0 * C.xxxx;
  vec4 x2 = x0 - i2 + 2.0 * C.xxxx;
  vec4 x3 = x0 - i3 + 3.0 * C.xxxx;
  vec4 x4 = x0 - 1.0 + 4.0 * C.xxxx;

// Permutations
  i = mod(i, 289.0);
  float j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
  vec4 j1 = permute( permute( permute( permute (
        i.w + vec4(i1.w, i2.w, i3.w, 1.0 ))
        + i.z + vec4(i1.z, i2.z, i3.z, 1.0 ))
        + i.y + vec4(i1.y, i2.y, i3.y, 1.0 ))
        + i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));
// Gradients
// ( 7*7*6 points uniformly over a cube, mapped onto a 4-octahedron.)
// 7*7*6 = 294, which is close to the ring size 17*17 = 289.

  vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;

  vec4 p0 = grad4(j0, ip);
  vec4 p1 = grad4(j1.x, ip);
  vec4 p2 = grad4(j1.y, ip);
  vec4 p3 = grad4(j1.z, ip);
  vec4 p4 = grad4(j1.w, ip);

// Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  p4 *= taylorInvSqrt(dot(p4,p4));

// Mix contributions from the five corners
  vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4) ), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * ( dot(m0*m0, vec3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 )))
        + dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;

}

vec3 snoiseVec3( vec4 x ){
  float s = snoise(vec4( x ));
  float s1 = snoise(vec4( x.y - 19.1 , x.z + 33.4 , x.x + 47.2, x.w ));
  float s2 = snoise(vec4( x.z + 74.2 , x.x - 124.5 , x.y + 99.4, x.w ));
  vec3 c = vec3( s , s1 , s2 );
  return c;

}

vec3 curlNoise( vec4 p ){

  const float e = .1;
  vec3 dx = vec3( e , 0.0 , 0.0 );
  vec3 dy = vec3( 0.0 , e , 0.0 );
  vec3 dz = vec3( 0.0 , 0.0 , e );

  vec3 p_x0 = snoiseVec3( vec4(p.xyz - dx, p.w) );
  vec3 p_x1 = snoiseVec3( vec4(p.xyz + dx, p.w) );
  vec3 p_y0 = snoiseVec3( vec4(p.xyz - dy, p.w) );
  vec3 p_y1 = snoiseVec3( vec4(p.xyz + dy, p.w) );
  vec3 p_z0 = snoiseVec3( vec4(p.xyz - dz, p.w) );
  vec3 p_z1 = snoiseVec3( vec4(p.xyz + dz, p.w) );

  float x = p_y1.z - p_y0.z - p_z1.y + p_z0.y;
  float y = p_z1.x - p_z0.x - p_x1.z + p_x0.z;
  float z = p_x1.y - p_x0.y - p_y1.x + p_y0.x;

  const float divisor = 1.0 / ( 2.0 * e );
  return normalize( vec3( x , y , z ) * divisor );

}

float radius = 0.5;

void main() {
  float y = 1. - (vertexId / float(vertexCount - 1.)) * 2.;
  float r = sqrt(1. - y * y) * resolution.y/resolution.x * radius;
  y *= radius;

  float theta = phi * vertexId;

  float x = cos(theta) * r;
  float z = sin(theta) * r;

  vec3 pos = vec3(x,y,z);
  vec3 n = curlNoise(vec4(pos, time* 0.5));
  float n1 = snoise(vec4(n, time*0.5));
  pos += pow(n, vec3(10.))*0.1;
  pos *= 1.+n1*.2;
  gl_Position = vec4(pos, 1.);
  v_color = vec4(vec3(sqrt(-pos.z)*(1.+n1)), 0.1);
}