/*{
  "DESCRIPTION": "test",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/xL2Gh9RJscrvhfwE9)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 10000,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1577084245957
    }
  }
}*/


void main() {
    gl_Position.x = floor(vertexId / 2.);
    gl_Position.y = floor(mod(vertexId, 2.));
    gl_Position.z = 0.25;
    gl_Position.w = 1.;

    gl_PointSize = 20.0;

    v_color = vec4(0,1,0,1);
}