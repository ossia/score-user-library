/*{
  "DESCRIPTION": "fov_border",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/dyCMb2QsTKKjPQptu)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 210,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 73,
    "ORIGINAL_DATE": {
      "$date": 1505300386016
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
  float t2 = floor(time*10.);
  float tr = rand(vec2(t2,t2));
  float x = vertexId - 20.0*floor(vertexId / 20.);
  float y = floor(vertexId / 20.)*1.0;

  float cx = 1. * cos(vertexId*0.03) + rand(vec2(x+tr, y))*0.03;
  float cy = 1. * sin(vertexId*0.03) + rand(vec2(y+tr, x))*0.07;
  //gl_Position = vec4(0.01*x, 0.01*y, 0, 0.5);
  gl_Position = vec4(cx, cy*0.3, 0, 2);

  v_color = vec4(1, 0, 0, 0);
}