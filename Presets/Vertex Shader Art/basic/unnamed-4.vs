/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/2xJgNnQY5FLgHt6qW)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 3,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 41,
    "ORIGINAL_DATE": {
      "$date": 1529252652377
    }
  }
}*/



void main() {
 gl_PointSize = 10.0;
   vec3 xy = vec3(vertexId / 3.0, 0.0 - vertexId, 0.0);
   gl_Position = vec4(xy,1.0);
   v_color = vec4(1.0,0.0,0.0,1.0);
}