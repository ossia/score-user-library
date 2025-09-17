/*{
  "DESCRIPTION": "Wifi Symbol ;)",
  "CREDIT": "dertrackererpro (ported from https://www.vertexshaderart.com/art/KvFyruyQSz6mfh8jg)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3677,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 91,
    "ORIGINAL_DATE": {
      "$date": 1540822253451
    }
  }
}*/

mat2 Rotate2D(float x) {
  float a=sin(x), b=cos(x);
  return mat2(b, -a, a, b);
}

void main () {
  vec3 pos = vec3(vertexId/vertexCount, 0.0, 0.0);
  pos.xy*= Rotate2D(sin(time+vertexId*0.1));
  pos.xy*= Rotate2D(3.14159/2.0);
  pos.y -= 0.3;
  vec3 clr = vec3(pos.x-0.2, pos.y-1.0, -pos.x)+0.5;

  gl_PointSize = 6.0; /* if points avaible */
  gl_Position = vec4(pos.xy, pos.z, 1.0);
  v_color = vec4(clr, 1.0);
}