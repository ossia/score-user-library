/*{
  "DESCRIPTION": "Grid - https://www.youtube.com/watch?v=mOEbXQWtP3M",
  "CREDIT": "adrian (ported from https://www.vertexshaderart.com/art/sEkj67PRA2wdoH6n2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 16384,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.2549019607843137,
    0.2627450980392157,
    0.4627450980392157,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1596443691119
    }
  }
}*/


void main() {

  float across = 10.0;

  // vertexId = 0, 1, 2, 3, 4, ..., 10, 11, 12, ...

  // float x = vertexId / 10.0;
  // x = 0.0, 0.1, 0.2, 0.3, 0.4, ..., 1.0, 1.1, 1.2, ...

  // float x = mod(vertexId, 10.0);
  // x = 0, 1, 2, 3, 4, ..., 0, 1, 2, ...

  // float y = floor(vertexId / 10.0);
  // when vertexId is in [0,9], y = 0;
  // when vertexId is in [10, 19], y = 1;
  // when vertexId is in [20, 29], y = 2;
  // ...

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  // u = 0.0, 0.1, 0.2, 0.3, 0.4, ... 0.0, 0.1, 0.2, ...
  float u = x / across;
  float v = y / across;

  // move u and v to center
  float ux = u * 2.0 - 1.0;
  float vy = v * 2.0 - 1.0;

  gl_Position = vec4(ux,vy,0,1);

  gl_PointSize = 10.0;

  v_color = vec4(1,0,0,1);
}