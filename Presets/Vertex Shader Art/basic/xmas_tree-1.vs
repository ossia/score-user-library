/*{
  "DESCRIPTION": "xmas tree",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/zSahx3yerpFqrYbQM)",
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
    "ORIGINAL_VIEWS": 125,
    "ORIGINAL_DATE": {
      "$date": 1451229445500
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)

// simple xmas tree
// just customize with some presents!

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  if (vertexId < 90000.) {
    float needleId = floor(vertexId/6.);
    float subId = vertexId - needleId*6.;
    float branch = floor(sqrt(needleId+0.5));
    needleId -= branch*branch;

    float y = .9-branch*.01-needleId*.005 - (1.-abs(mod(subId,3.)-1.))*.06;
    float l = needleId*.003+mod(subId,3.)*.005;
    float a = branch * 3.88 + time + (1.-abs(mod(subId,3.)-1.))*.05/l * sign(subId-2.5);

    vec3 p = vec3(cos(a)*l, y, sin(a)*l);

    gl_Position = vec4(p.xy, p.z+.5, 1);

    v_color = vec4(vec3(.3,.8,.2)*(sin(needleId*.07)*.5+2.)*.2,1);
  } else if (vertexId < 90090.) {
    float id = vertexId - 90000.;
    float needleId = floor(id/3.);
    float subId = id - needleId*3.;

    float y = .9- abs(mod(subId,3.)-1.)*1.9;
    float l = abs(mod(subId,3.)-1.)*.03;
    float a = time + (needleId + floor(subId*.5))*.21;

    vec3 p = vec3(cos(a)*l, y, sin(a)*l);

    gl_Position = vec4(p.xy, p.z+.5, 1);

    v_color = vec4(vec3(.5,.2,0.)*(sin(needleId*.7)*.5+2.)*.2,1);

  } else {
    float id = vertexId - 90090.;
    float sphereId = floor(id/300.);
    float subId = id - sphereId*300.;

    float y = sqrt(sqrt((sin(sphereId)+1.)*.5));
    float l = (sin(sphereId*3.7)*.1+1.)*y*.45;
    float a = y*100.+l*312. + time;

    y = .85-y*1.5;

    vec3 p = vec3(cos(a)*l, y, sin(a)*l);
    p += vec3(cos(subId*2.3)*.6,sin(subId*2.3)-.9,0)*.08*exp(subId*subId*-.00008)+vec3(0,0,subId*-.0001);

    gl_Position = vec4(p.xy, p.z+.5, 1);

    float v = vertexId*.002;
    vec3 vc = vec3(cos(v),cos(v+2.1),cos(v-2.1))*.2+.5+subId*subId*.00002;

    v_color = vec4(vc*vc,1.);

  }
}