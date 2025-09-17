/*{
  "DESCRIPTION": "Experiment002",
  "CREDIT": "thetuesday night machines (ported from https://www.vertexshaderart.com/art/S3xrtQ73jjKSYCofF)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5000,
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
    "ORIGINAL_VIEWS": 121,
    "ORIGINAL_DATE": {
      "$date": 1546121470172
    }
  }
}*/


void main() {

  float x = vertexId/100.-1.;
  float y = tan(time/4.+vertexId)/20.;

  gl_Position = vec4(x, y, 0, 1);
  gl_PointSize = (sin(time*2.+vertexId-1.)*20.)+(cos(time*1.)*10.+20.);

  v_color = vec4(sin(time*2.+vertexId),y+.3,.5,0.) ;

}