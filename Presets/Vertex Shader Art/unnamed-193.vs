/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/zNMwxDHLmvHRPQBpm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1,
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
    "ORIGINAL_VIEWS": 101,
    "ORIGINAL_DATE": {
      "$date": 1534536265831
    }
  }
}*/

attribute vec3 a_position;
varying vec3 v_pos;
varying float v_alpha;
uniform mat4 u_modelViewMatrix;
uniform mat4 u_projectionMatrix;
uniform vec2 u_resolution;
uniform float u_amount;
uniform float u_time;
uniform float u_twirl;
uniform float u_noise_time;
//
// Description : Array and textureless GLSL 2D simplex noise function.
// Author : Ian McEwan, Ashima Arts.
// Maintainer : ijm
// Lastmod : 20110822 (ijm)
// License : Copyright (C) 2011 Ashima Arts. All rights reserved.
// Distributed under the MIT License. See LICENSE file.
// https://github.com/ashima/webgl-noise
//

vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec3 permute(vec3 x) {
    return mod289(((x*34.0)+1.0)*x);
}
float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187, // (3.0-sqrt(3.0))/6.0
    0.366025403784439, // 0.5*(sqrt(3.0)-1.0)
    -0.577350269189626, // -1.0 + 2.0 * C.x
    0.024390243902439);
    // 1.0 / 41.0
    // First corner
    vec2 i = floor(v + dot(v, C.yy) );
    vec2 x0 = v - i + dot(i, C.xx);
    // Other corners
    vec2 i1;
    //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
    //i1.y = 1.0 - i1.x;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    // x0 = x0 - 0.0 + 0.0 * C.xx ;
    // x1 = x0 - i1 + 1.0 * C.xx ;
    // x2 = x0 - 1.0 + 2.0 * C.xx ;
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    // Permutations
    i = mod289(i);
    // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
    + i.x + vec3(0.0, i1.x, 1.0 ));
    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt( a0*a0 + h*h )[[[semicolonReplacementKey]]]
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    // Compute final noise value at P
    vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}
float clampNorm(float val, float min, float max) {
    return clamp((val - min) / (max - min), 0.0, 1.0);
}
const float PI = 3.14159265358979323846264;

void main(void) {
    gl_PointSize = 2.0;
    vec3 pos = a_position;
    float index = pos.z;
    pos.z = 0.0;
    v_alpha = 1.0;
    // 9 groups
    float group = mod(floor(index / 360.0), 9.0);
    float angle = index / 180.0 * PI;
    float radius = 300.0 + floor(index / 360.0) * 3.0;
    float toCenter = clamp(radius / 600.0, 0.0, 1.0);
    vec3 basePos = pos;
    basePos.x = sin(angle) * radius;
    basePos.y = cos(angle) * radius;
    angle += u_time * (1.0 + group * .1) * 0.015;
    angle += u_twirl * pow(sin(angle * (1.0 - u_twirl * 0.01)), 3.0) * 0.7;
    pos.x = sin(angle) * radius;
    pos.y = cos(angle) * radius;
    vec3 finalPos = pos;
    finalPos.x = pos.x + snoise(basePos.xy * 1. + u_noise_time * .03 ) * 50.0;
    finalPos.y = pos.y + snoise(basePos.xy * 1. + u_noise_time * .03 + 3.0 ) * 50.0;
    v_alpha = toCenter - (sin(pow(toCenter, 1.2) * 60.0) + 1.0) / 2.0 * 0.5;
    finalPos.x /= u_resolution.x;
    finalPos.y /= u_resolution.y;
    v_pos = finalPos;
    gl_Position = u_projectionMatrix * u_modelViewMatrix * vec4(finalPos, 1.0);
}

