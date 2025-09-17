/*{
  "DESCRIPTION": "Bouncy Music Lines",
  "CREDIT": "8bitrick (ported from https://www.vertexshaderart.com/art/C9maC3C6dCdyKmsuH)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
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
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 275,
    "ORIGINAL_DATE": {
      "$date": 1449285675549
    }
  }
}*/

// Just a bunch of lines bouncing to music
//

// I'm still learning and "borrowing" many techniques from other shaders

// hsv2rgb borrowed from gman shaders
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
  float ROWS = 5.;
  float verts_per_row = vertexCount / ROWS;
  float row = floor(vertexId / verts_per_row);
  float row_per = row / (ROWS-1.);
  float vertex_per = mod(vertexId, verts_per_row) / verts_per_row;
  float x = vertex_per*2.0 - 1.0 + row_per * 0.5;
  float y = texture(sound,vec2(vertex_per,row_per)).r + (row_per) - 1.;
  gl_PointSize = 10.0;
  gl_Position = vec4(x,y,0,1);
  v_color = mix(vec4(hsv2rgb(vec3(0.25, fract(time+row_per), 1.)), 1.-row_per), background, row_per - 0.2);
}
