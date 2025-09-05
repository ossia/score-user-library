/*{
  "DESCRIPTION": "WIP - GLSL Vertex Shader for first show",
  "CREDIT": "zach (ported from https://www.vertexshaderart.com/art/xDh7mGTSuEc3dohm4)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1634920744666
    }
  }
}*/

void main() {

  int numShapes = 3;

  // Shape 1
  float a1 = 1.0;
  float b1 = 2.0;
  float c1 = 4.36;
  float d1 = -3.0;

  // Shape 2
  float a2 = 2.53;
  float b2 = 1.67;
  float c2 = 1.26;
  float d2 = 2.24;

  // Shape 3
  float a3 = -1.54;
  float b3 = 4.21;
  float c3 = 1.53;
  float d3 = 1.04;

  float s = texture(sound, vec2(3./5., 1./ 5.)).r;

  // Spread between the bands. KEEP BETWEEN 0-1
  float spread = mix(0., 1., mouse.y);

  float cycleTime = 3.;
  float stage = mod(time/20., cycleTime);

  float a, b, c, d;

  // Mix between first and second shape.
  if(stage < (cycleTime / float(numShapes))) {
    a = mix(a1, a2, stage);
    b = mix(b1, b2, stage);
    c = mix(c1, c2, stage);
    d = mix(d1, d2, stage);
  } else if (stage < 2. * (cycleTime / float(numShapes))) {
    a = mix(a2, a3, mod(stage, (cycleTime / float(numShapes))));
    b = mix(b2, b3, mod(stage, (cycleTime / float(numShapes))));
    c = mix(c2, c3, mod(stage, (cycleTime / float(numShapes))));
    d = mix(d2, d3, mod(stage, (cycleTime / float(numShapes))));
  } else {
    a = mix(a3, a1, mod(stage, (cycleTime / float(numShapes))));
    b = mix(b3, b1, mod(stage, (cycleTime / float(numShapes))));
    c = mix(c3, c1, mod(stage, (cycleTime / float(numShapes))));
    d = mix(d3, d1, mod(stage, (cycleTime / float(numShapes))));
  }

  gl_PointSize = 0.5;

  // Find pixel coordinates
  float x = mod(vertexId, 25.);
  float y = floor(vertexId/ 25.);

  // Used in calculating future point
  float tmpX;
  float tmpY;

  for (int i = 0; i < 5; i++) {
    tmpX = x; tmpY = y;
    x = (sin(a * tmpY) - cos(b * tmpX));
    y = (sin(c * tmpX) - cos(d * tmpY));
  }

  int band = int(mod(vertexId, 3.));

  if(band == 0) {
    v_color = vec4(1.0, 0.0, 0.0, 1.0);
    gl_Position = vec4(x / 5., y / 5. - (0.1 * spread), 0., 0.7);
  } else if(band == 1) {
    v_color = vec4(0.0, 1.0, 0.0, 1.0);
   gl_Position = vec4(x / 5., y / 5., 0., 0.7);
  } else {
    v_color = vec4(0.0, 0.0, 1.0, 1.0);
   gl_Position = vec4(x / 5., y / 5. + (0.1 * spread), 0., 0.7);
  }

  //gl_Position = vec4(x / 5., y / 5., 0., 0.7);
}