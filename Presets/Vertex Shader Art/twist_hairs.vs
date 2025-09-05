/*{
  "DESCRIPTION": "twist hairs",
  "CREDIT": "seb (ported from https://www.vertexshaderart.com/art/JvvtkuvxB6iKmfBQa)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3907,
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
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1679653573811
    }
  }
}*/

#define COUNT_PER_LINE 100.

void main() {

  gl_PointSize=2.;
  vec2 baseP = vec2(mod(vertexId,COUNT_PER_LINE)*.2+.1*sin(vertexId*.2),
        floor(vertexId/COUNT_PER_LINE))*.05;
  vec2 hairId = vec2(mod(vertexId,COUNT_PER_LINE),
        floor(vertexId/COUNT_PER_LINE));
  vec2 offse = vec2(.02+0.05*sin(vertexId), 0.5*sin(vertexId*.2+time)*.05+.1);
  vec2 position = baseP + mod(vertexId, 2.0)*offse;
gl_Position = vec4((position-.5)*2., 0., 1);
 vec3 rgb = mix(vec3(0.816,0.165,0.996),
        vec3(0.180,0.494,1.000)*.3,
        sin(vertexId)*.5+.5);
 rgb = mix(vec3(0.), rgb, mod(vertexId, 2.0));
  v_color = vec4(rgb,1.);
}