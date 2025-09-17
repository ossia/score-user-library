/*{
  "DESCRIPTION": "Test2",
  "CREDIT": "bene2002 (ported from https://www.vertexshaderart.com/art/fAnatQu5aZpC5Dmby)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 2995,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.25098039215686274,
    0.6823529411764706,
    0.788235294117647,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1597532733779
    }
  }
}*/

void main() {
  float numY = floor(sqrt(vertexCount));
  float numX = floor(vertexCount/numY);

  float x = mod(vertexId, numX);
  float y = floor(vertexId / numX);

  float u = x / (numX - 1.);
  float v = y / (numY - 1.);

  gl_Position = vec4(-1.+u*2.,1.-v*2.,0,1);

  gl_PointSize = 10.0;
  gl_PointSize = gl_PointSize * 20. / numX;
  gl_PointSize = gl_PointSize * resolution.x / 600.;

  v_color = vec4(1, 0, 0, 1);
}