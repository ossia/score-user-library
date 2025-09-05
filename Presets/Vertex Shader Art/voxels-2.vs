/*{
  "DESCRIPTION": "voxels",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/eqcXviN95rTrGxwyW)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 81932,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.00784313725490196,
    0.00784313725490196,
    0.00784313725490196,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 33,
    "ORIGINAL_DATE": {
      "$date": 1589783689103
    }
  }
}*/

#define PI radians(180.)
#define SIZE 90.0
#define NUM_CUBES (SIZE*SIZE*SIZE)
#define NUM_TRIANGLES (NUM_CUBES*6)
#define NUM_VERTICES (NUM_TRIANGLES*6)
#define STEP 80.0

#define rot(A) mat2(cos(A),-sin(A),sin(A),cos(A))

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(12.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

//https://www.shadertoy.com/view/4ttGDH
vec3 camPath(float t){

    //return vec3(0, 0, t); // Straight path.
    //return vec3(-sin(t/2.), sin(t/2.)*.5 + 1.57, t); // Windy path.

    //float s = sin(t/24.)*cos(t/12.);
    //return vec3(s*12., 0., t);

    float a = -sin(t * 0.011);
    float b = cos(t * 0.014);
    return vec3(a*4. -b*1.5, b*1.7 + a*2.5, t);

}

//https://www.shadertoy.com/view/4ttGDH
float map(vec3 p){

    p.xy /= camPath(p.z).xy; // Perturb the object around the camera path.

    p *= 0.4;

 p = cos(p*.315*1.25 + sin(p.zxy*.875*1.25)); // 3D sinusoidal mutation.

    float n = length(p); // Spherize. The result is some mutated, spherical blob-like shapes.

    // It's an easy field to create, but not so great to hone in one. The "1.4" fudge factor
    // is there to get a little extra distance... Obtained by trial and error.
    return (n - 1.025)*1.33;

}

void main() {

  float speed = 10.0;

  vec3 wpos = vec3(0);

  vec3 pos = camPath(time*speed)*sin(-1.5*mouse.x);

  vec3 lookat = camPath(time*speed+2.0);
  vec3 forward = normalize(lookat-pos);
  vec3 left = normalize(cross(vec3(camPath(time*speed+1.0).xy,0),forward));
  vec3 up = cross(forward,left);

  float id = vertexId;

  float numcube = floor(id/18.0);
  float numquad = floor(id/6.0);
  float quadid = 3.0-abs(id-numquad*6.0-3.0);
  float nori = mod(numquad,3.0);
  //quadid = quadid ^ diri;
  vec2 quad = vec2(mod(quadid,2.0),mod(floor(quadid*0.5),2.0));

  vec3 mask;
  if (nori < 0.5) {
    mask = vec3(1,0,0);
  } else if (nori < 1.5) {
    mask = vec3(0,1,0);
  } else {
    mask = vec3(0,0,1);
  }

  float size = floor(pow(vertexCount/23.0,1.0/3.0)*mouse.y)*2.;

  vec3 blockpos = vec3(
    mod(floor(numcube),size),
    mod(floor(numcube/size),size),
        floor(numcube/size/size))-vec2(floor(size*0.5),0).xxy+floor(pos);

  bool a = map(blockpos) > 0.0;
  bool b = map(blockpos+mask) > 0.0;

  float diri;

  if (a == b) {
    gl_Position = vec4(0,0,0,1);
    return;
  } else {

    float diri = 1.0;
    if (b) {
      diri = -diri;
      quad.xy = quad.yx;
    }

    vec3 nor = mask*(diri*2.0-1.0);

    wpos += mask.zxy*quad.x;
    wpos += mask.yzx*quad.y;
 wpos += mask;
    wpos += blockpos;

    wpos -= 0.5;

    //wpos += vec3(data.xyz);
    //wpos += float(gl_VertexID/6);
    //wpos += u_centerPosition;

    vec3 p = wpos-pos;//vec3(sin(id+time),cos(id+time),id);

    p = vec3(-dot(p,left),dot(p,up),dot(p,forward));

    p.x *= resolution.y/resolution.x;

    gl_Position = vec4(p.xy, p.z*p.z*0.01, p.z);

    float hue = (id * 1.001);
    v_color = vec4(nor*0.5+0.5, 1);
  }
}