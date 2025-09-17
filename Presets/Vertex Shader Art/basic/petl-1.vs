/*{
  "DESCRIPTION": "petl",
  "CREDIT": "guilleperez (ported from https://www.vertexshaderart.com/art/mJLSnvDjL3N6wkYDR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 400,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    0.5019607843137255,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1551480308028
    }
  }
}*/

void main()
{
  float width = 10.0;
  float x = mod(vertexId, width);
  float y = floor(vertexId / width);

  float u = x /(width - 1.0);
  float v = y / (width - 1.0);

  //Desfamiento
  //desfazamiento + [x = diferente] * r
  float xOffset = cos(time + y) * 0.1;
  float yOffset = sin(time + x) * 0.1;

  //Acomodar en los cuadrantes
  float ux = u * 2.0 - 1.0 + xOffset;
  float uy = v * 2.0 - 1.0 + yOffset;

  vec2 xy = vec2(ux, uy); //se puede crear vec4 con vectores 2 -> vec4(xy, 0.0, 1.0);

  gl_Position = vec4(xy, 0.0, 1.0); //position del vec4
  v_color = vec4(1.0, 0.0, 0.0, 1.0); //color
  gl_PointSize = 20.0;
}
