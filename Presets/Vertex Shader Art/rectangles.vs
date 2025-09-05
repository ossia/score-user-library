/*{
  "DESCRIPTION": "rectangles",
  "CREDIT": "mol (ported from https://www.vertexshaderart.com/art/ygbdEzp2iTmLeNyu8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.19215686274509805,
    0.2,
    0.26666666666666666,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1543915341237
    }
  }
}*/

// handle points to create a rectangle
vec2 calcRect(vec2 dimensions)
{
  return vec2(
    // generate x coordinates based on which vertex this is
    mod(floor(vertexId / 2.0), 2.0) * dimensions.x,
    // generate y coordinates based on which vertex this is
    mod(floor((vertexId + 1.0) / 2.0), 2.0) * dimensions.y);
}

void main()
{
  gl_PointSize = 5.0;

  v_color = vec4(1, 0, 0, 1);

  // calculate scaling to adjust for resolution aspect ratio
  vec2 scale = min(
    vec2(resolution.y / resolution.x, 1.0), vec2(1.0, resolution.x / resolution.y));

  vec2 rect = calcRect(vec2(0.1, 0.1));

  gl_Position = vec4(
    rect.x + floor(vertexId / 4.0) * 0.2 * sin(time),
    rect.y + floor(vertexId / 4.0) * 0.2 * cos(time),
    0.0, 1.0);
  // apply aspect ratio scale
  gl_Position.xy *= scale;
}

