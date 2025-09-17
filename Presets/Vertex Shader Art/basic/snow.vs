/*{
  "DESCRIPTION": "snow",
  "CREDIT": "gerrygoo (ported from https://www.vertexshaderart.com/art/Ljd8Z84mCFeiRwfuy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10,
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1554512862974
    }
  }
}*/

// 1m x 1m

#define G = 9.8

float rand(float x) {
 return fract(sin(x)*10000000.0);
}

void main() {

  float
    i = vertexId,
    // r = rand(),

    origin_x = -1.0,
    origin_y = 1.0,

    x_i_offset = 2.0 * rand(i),
    y_i_offset = 0.0,

    starting_x = origin_x,
    starting_y = origin_y,

   fall_distance = - (mod(time, 2.0) * 0.5) * mod(time, 2.0),

   wiggle_x_offset = 0.01 * sin(time*10.0),

    x = starting_x + wiggle_x_offset + x_i_offset,
    y = starting_y + fall_distance //+ y_i_offset;

    ;

  gl_Position = vec4(x, y, 0, 1);

  gl_PointSize = 10.0;
  v_color = vec4(0, 0.8, 1, 1);

}