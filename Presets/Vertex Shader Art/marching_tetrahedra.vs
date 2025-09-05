/*{
  "DESCRIPTION": "marching tetrahedra",
  "CREDIT": "abjeni (ported from https://www.vertexshaderart.com/art/mLtQNvFM6AJhHKbYq)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 237,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1600598115185
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 21.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)

#define NUM_CUBES (SIZE*SIZE*SIZE)
#define NUM_TRIANGLES (NUM_CUBES*18)
#define NUM_VERTICES (NUM_TRIANGLES*6)

#define STEP 5.0

#define ipol(corners,values,id1, id2) mix(corners[id1].xyz,corners[id2].xyz,values[id1]/(values[id1]-values[id2]))

//https://www.shadertoy.com/view/4ttGDH
vec3 camPath(float t){

    //return vec3(0, 0, t); // Straight path.
    //return vec3(-sin(t/2.), sin(t/2.)*.5 + 1.57, t); // Windy path.

    //float s = sin(t/24.)*cos(t/12.);
    //return vec3(s*12., 0., t);

    float a = sin(t * 0.11);
    float b = cos(t * 0.14);
    return vec3(a*4. -b*1.5, b*1.7 + a*1.5, t);

}

//https://www.shadertoy.com/view/4ttGDH
float map(vec3 p){

    p.xy -= camPath(p.z).xy; // Perturb the object around the camera path.

    p *= 0.4;

 p = cos(p*.315*1.25 + sin(p.zxy*.875*1.25)); // 3D sinusoidal mutation.

    float n = length(p); // Spherize. The result is some mutated, spherical blob-like shapes.

    return n-1.0;

}

void main() {

  float speed = 10.0;

  vec3 wpos = vec3(0);

  vec3 pos = camPath(time*speed);

  vec3 lookat = camPath(time*speed+2.0);
  vec3 forward = normalize(lookat-pos);
  vec3 left = normalize(cross(vec3(camPath(time*speed+1.0).xy,0),forward));
  vec3 up = cross(forward,left);

  float cid = floor(vertexId/30.0);
  int tid = int(floor(vertexId/6.0)-cid*5.0);
  int vid = int(mod(vertexId,6.0));

  float size = floor(pow(vertexCount/30.0,1.0/3.0));

  vec3 cpos = vec3(
    mod(floor(cid),size),
    mod(floor(cid/size),size),
        floor(cid/size/size))
    -vec2(floor(size*0.5),0).xxy+floor(pos);

  mat4 corners = mat4(
    0,0,0,0,
    0,1,1,0,
    1,0,1,0,
    1,1,0,0
  );

  bool flip = tid == 4;
  if (!flip) {
    if (tid == 0) corners[0].xyz = 1.0-corners[0].xyz;
    if (tid == 1) corners[1].xyz = 1.0-corners[1].xyz;
    if (tid == 2) corners[2].xyz = 1.0-corners[2].xyz;
    if (tid == 3) corners[3].xyz = 1.0-corners[3].xyz;
  }

  if (mod(dot(cpos,vec3(1)),2.0) < 0.5) {
    flip = !flip;
    corners = 1.0-corners;
  }

  corners[0].xyz += cpos;
  corners[1].xyz += cpos;
  corners[2].xyz += cpos;
  corners[3].xyz += cpos;

  vec4 values = vec4(
    map(corners[0].xyz),
    map(corners[1].xyz),
    map(corners[2].xyz),
    map(corners[3].xyz)
  );

  int id = 0;
  if (values[0] > 0.0) id+=1;
  if (values[1] > 0.0) id+=2;
  if (values[2] > 0.0) id+=4;
  if (values[3] > 0.0) id+=8;

  gl_Position = vec4(0);
  vec3 vpos = vec3(0);

  if (id == 15 || id == 0) {
    return;
  }

  if (id < 8) {
    flip = !flip;
  }

  if (flip) {
        if (vid == 0) vid = 1;
    else if (vid == 1) vid = 0;
    else if (vid == 3) vid = 4;
    else if (vid == 4) vid = 3;
  }

  if (id == 1 || id == 14) {
        if (vid == 0) vpos = ipol(corners,values,0,1);
    else if (vid == 1) vpos = ipol(corners,values,0,2);
    else if (vid == 2) vpos = ipol(corners,values,0,3);
    else return;
  }

  if (id == 2 || id == 13) {
        if (vid == 0) vpos = ipol(corners,values,1,0);
    else if (vid == 1) vpos = ipol(corners,values,1,3);
    else if (vid == 2) vpos = ipol(corners,values,1,2);
    else return;
  }

  else if (id == 4 || id == 11) {
        if (vid == 0) vpos = ipol(corners,values,2,0);
    else if (vid == 1) vpos = ipol(corners,values,2,1);
    else if (vid == 2) vpos = ipol(corners,values,2,3);
    else return;
  }

  else if (id == 8 || id == 7) {
        if (vid == 0) vpos = ipol(corners,values,3,0);
    else if (vid == 1) vpos = ipol(corners,values,3,1);
    else if (vid == 2) vpos = ipol(corners,values,3,2);
    else return;
  }

  else if (id == 3 || id == 12) {
        if (vid == 0) vpos = ipol(corners,values,0,2);
    else if (vid == 1) vpos = ipol(corners,values,0,3);
    else if (vid == 2) vpos = ipol(corners,values,1,2);
    else if (vid == 3) vpos = ipol(corners,values,1,3);
    else if (vid == 4) vpos = ipol(corners,values,1,2);
    else if (vid == 5) vpos = ipol(corners,values,0,3);
  }

  else if (id == 5 || id == 10) {
        if (vid == 0) vpos = ipol(corners,values,0,3);
    else if (vid == 1) vpos = ipol(corners,values,0,1);
    else if (vid == 2) vpos = ipol(corners,values,2,1);
    else if (vid == 3) vpos = ipol(corners,values,2,1);
    else if (vid == 4) vpos = ipol(corners,values,2,3);
    else if (vid == 5) vpos = ipol(corners,values,0,3);
  }

  else if (id == 6 || id == 9) {
        if (vid == 0) vpos = ipol(corners,values,1,0);
    else if (vid == 1) vpos = ipol(corners,values,1,3);
    else if (vid == 2) vpos = ipol(corners,values,2,0);
    else if (vid == 3) vpos = ipol(corners,values,2,3);
    else if (vid == 4) vpos = ipol(corners,values,2,0);
    else if (vid == 5) vpos = ipol(corners,values,1,3);
  }

  vec3 p = vpos-pos;

  p = vec3(-dot(p,left),dot(p,up),dot(p,forward));

  p.x *= resolution.y/resolution.x;

  gl_Position = vec4(p.xy, p.z*p.z*0.01, p.z);

  v_color = vec4(fract(vpos*0.3),1);
}