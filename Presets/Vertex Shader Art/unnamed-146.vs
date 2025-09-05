/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "xurxo (ported from https://www.vertexshaderart.com/art/gkNsynXB23Y8WhASo)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 14429,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.09411764705882353,
    0.08627450980392157,
    0.5294117647058824,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1576514559998
    }
  }
}*/


void main() {
  float down = floor(sqrt(vertexCount));
  float across =floor (vertexCount/down);
  float x= mod(vertexId,across);
  float y= floor(vertexId /across);

  float u = x/(across-1.);
  float v = y/(across-1.);

  float ux = u * 2.-1.;
  float vy = v * 2.-1.;

  gl_Position = vec4(ux,vy,0,1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20./across;
  gl_PointSize *= resolution.x/600.;

  v_color = vec4(1,0,0,1);

}

