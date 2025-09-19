/*{
  "DESCRIPTION": "circles",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/Bt5C5fTXArXh3hvqh)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10093,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 80,
    "ORIGINAL_DATE": {
      "$date": 1583379410920
    }
  }
}*/

#define PI radians(180.)
#define NUM_POINTS 180.
#define GRID 10.
#define NUM_ITEMS 5.

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float bezier(float A, float B, float C, float D, float t) {
  float E = mix(A, B, t);
  float F = mix(B, C, t);
  float G = mix(C, D, t);

  float H = mix(E, F, t);
  float I = mix(F, G, t);

  return mix(H, I, t);
}

vec2 circle(float eid) {
 float vid = floor(eid/2.);
 float edge = floor(mod(eid,2.));
    float angle = mod(vid+edge, NUM_POINTS*2.)/NUM_POINTS*2.*PI*2.;
   return vec2(cos(angle),sin(angle));
}

vec2 circle(float eid, float start, float arclen) {
 float vid = floor(eid/2.);
 float edge = floor(mod(eid,2.));
    float angle = start + (mod(vid+edge, NUM_POINTS*2.)/NUM_POINTS*2.*arclen);
   return vec2(cos(angle),sin(angle));
}

void main() {
   float layerVid = mod(vertexId,NUM_POINTS*NUM_ITEMS*NUM_ITEMS);
   float layer = floor(vertexId/(NUM_POINTS*NUM_ITEMS*NUM_ITEMS));
   float instance = floor(layerVid / NUM_POINTS);
    float instanceVid = floor( mod(vertexId,NUM_POINTS) );
   float even = mod(instance,2.);
   float odd = 1.-even;
   float edge = floor(mod(instanceVid,4.)/2.);//1.;//cos(mod(layerVid,4.));
    vec2 aspect = vec2(1, resolution.x / resolution.y);
   vec2 offs = vec2( mod(instance,NUM_ITEMS)-2.2, floor(instance/NUM_ITEMS)-2. )*vec2(0.4,0.39);
 vec2 xy;

  if (layer == 1.) {
 xy = offs+circle(instanceVid) * (0.2 + even*0.04);
// float alpha = instanceVid/NUM_POINTS;
// xy = vec2(alpha,bezier(0.,1.,0.,1.,alpha))*0.2;//*2.-1.,bezier(.8,0.,0.,.8,alpha)*0.1);

    v_color = vec4(0.5*edge,0.5*edge,0.5*edge,1);
    //v_color = vec4(1,0,0,1);
  } else {

    float angle = mod(time + instance,PI*2.);
    float speed = 1.+floor(even);

    float arcStart = mod(angle*speed+PI*even+0.8,PI*2.);
 float arcPart = arcStart/(PI*2.);
    float arcSeg = mod(arcPart,0.25);
    arcPart = bezier(0.,1.,0.,1.,arcSeg/0.25)*0.25 + arcPart - arcSeg;

    arcStart = arcPart * PI * 2.;

    xy = offs+circle(instanceVid,arcStart,PI*0.5/*1.6*/) * (0.2 + even*0.04);
    v_color = vec4(0.,0.2+clamp(even*cos(arcStart-0.5),0.,1.) + clamp(odd*sin(arcStart+PI),0.,1.),0,1);
  }

   gl_Position = vec4(xy * aspect, 0, 1);

}

  /*
float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float offset = count * 0.02;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = 0.2;
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = count * 0.01;
  float oC = cos(orbitAngle + time * count * 0.01) * sin(orbitAngle);
  float oS = sin(orbitAngle + time * count * 0.01) * sin(orbitAngle);

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s);
   // float hue = (time * 0.01 + instance * 1.001);
  //v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);

*/
