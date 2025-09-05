/*{
  "DESCRIPTION": "circuloColores",
  "CREDIT": "jonaced (ported from https://www.vertexshaderart.com/art/dh3DHrafWfekY5Q5d)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 362,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1553129767421
    }
  }
}*/

void main() {
  float tamCirculo = 360.0;
  if (vertexId == 0.0) {
    gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
  } else {
    float angle = vertexId / tamCirculo * radians(360.0);
    float radius = 1.0;
    float u = radius * cos(angle) ;
    float v = radius * sin(angle) ;
    gl_Position = vec4(u, v, 0.0, 1.0);
    float absU = abs(u);
    float absV = abs(v);
    vec3 colVec = vec3((absU + absV) * cos(angle/2.0) * cos(angle/2.0), (absU + absV) * sin(angle/3.0) * cos(angle/3.0), (absU + absV) * sin(angle));
    v_color = vec4(colVec, 1.0);
  }
}

/*
void main() {
  float tamCirculo = 360.0;
  if (vertexId == 0.0) {
    gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
  } else {
    float angle = vertexId / tamCirculo * radians(360.0);
    float radius = 1.0;
    float u = radius * cos(angle) ;
    float v = radius * sin(angle) ;
    gl_Position = vec4(u, v, 0.0, 1.0);
    float absU = abs(u);
    float absV = abs(v);
    v_color = vec4((u + absV)/1.6, (absU + v)/1.6, (absU + absV)/3.0, 1.0);
  }
}

vec3 colVec = vec3(absU / abs(1.0 - u), (absU + v) / 2.0, (absU + absV) * cos(angle));
vec3 colVec = vec3(absU * abs(0.5 - u), absV * abs(0.5 - v), ((absU * 0.9) + (absV * 0.5)) * cos(angle));
vec3 colVec = vec3(absU * abs(0.5 - u), absV * abs(0.5 - v), (absU + absV) * cos(angle));
*/