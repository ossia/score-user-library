/*{
  "DESCRIPTION": "Motion donga.choi",
  "CREDIT": "donga.choi (ported from https://www.vertexshaderart.com/art/3yMooDSsPRwxpbiuL)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 2986,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.07058823529411765,
    0.07058823529411765,
    0.07058823529411765,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1652943780504
    }
  }
}*/

//Dong-A Choi
//CS250
//Motion exercise
//2022 spring

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across-1.);
  float v = y / (across-1.);

  float xoff = floor(sin(time + y * 0.2) * 0.1);
  float yoff = sin(time + x * 0.3) * 0.2 ;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux +0.5, vy) * 1.3;

  gl_Position = vec4(xy,0,1);

  float soff = sin(time+x*y*0.02) * 5.;

  gl_PointSize = 10.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float timeV = sin(time);

   v_color = vec4(1,sin(time),cos(time),1);

}

