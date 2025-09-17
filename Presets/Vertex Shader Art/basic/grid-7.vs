/*{
  "DESCRIPTION": "grid",
  "CREDIT": "robsouthgate4 (ported from https://www.vertexshaderart.com/art/WXAP9xy4D98Qz6J8f)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 500,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1526166969169
    }
  }
}*/



vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
   float down = floor(sqrt(vertexCount));

    float across = floor(vertexCount / down);

   float x = mod(vertexId, across);
    float y = floor(vertexId / across);

   float u = x / (across -1.);
    float v = y / (across - 1.);

   float ux = u * 2. - 1.;
    float vy = v * 2. - 1.;

 gl_Position = vec4(ux,vy,0,1);
    gl_PointSize = 10.;
   gl_PointSize *= 20. / across;
   gl_PointSize *= resolution.x / 600.;
   v_color = vec4(1,0,0,1);
}