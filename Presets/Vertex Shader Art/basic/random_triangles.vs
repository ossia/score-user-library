/*{
  "DESCRIPTION": "random_triangles",
  "CREDIT": "gonnavis (ported from https://www.vertexshaderart.com/art/F6MddBx2WQCrGct9a)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 9,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1604486118155
    }
  }
}*/


vec3 hash3( float n ){
  // http://glslsandbox.com/e#61476.1
  return fract(sin(vec3(n,n+1.0,n+2.0))*vec3(43758.5453123,22578.1459123,19642.3490423));
}

void main() {
  gl_Position=vec4(hash3(vertexId+time*.0001)-.5,1);
  v_color = vec4(1,0,0,1);
}