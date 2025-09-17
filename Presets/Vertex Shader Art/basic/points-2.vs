/*{
  "DESCRIPTION": "points",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/uaxNZMjuMEduopGWR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 16005,
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
    "ORIGINAL_VIEWS": 29,
    "ORIGINAL_DATE": {
      "$date": 1713247690599
    }
  }
}*/

#define PI radians(180.)

void main() {
  vec3 p = vec3(sin(PI/80.*vertexId),cos(PI/80.*vertexId),0);

  mat2 rot = mat2(
    cos(PI/80.*vertexId/40.),sin(PI/80.*vertexId/40.),
    -sin(PI/80.*vertexId/40.),cos(PI/80.*vertexId/40.)
  );

  p.xz = p.xz*rot;
  vec3 op = p;

  p.xz = p.xz*mat2(cos(time),sin(time),-sin(time),cos(time));
  p.xy = p.xy*mat2(cos(time*.5),sin(time*.5),-sin(time*.5),cos(time*.5));

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  p.xy*= aspect;
  gl_Position = vec4(p/(p.z+2.)*.7, 1);
  gl_PointSize = (1.-gl_Position.z)*10.;

  v_color = vec4((op*.5+.5)*max(dot(p,vec3(.5,1,-1)),0.),1);
}