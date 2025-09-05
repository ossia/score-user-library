/*{
  "DESCRIPTION": "It's So In Vogue To Be Dead",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/WYLzRpCTKdWsrCPkZ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 14800,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 72,
    "ORIGINAL_DATE": {
      "$date": 1518813201466
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

mat4 scale(float s)
{
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
}

void main() {
  float segmentsPerCircle = 850.;
  float vertsPerSegment = 25.;

  // set base vert pos
  float bx = mod(vertexId, 2.) + floor(vertexId / 6.);
  float by = mod(floor(vertexId / 2.) + floor(vertexId / 3.), 2.);
  float angle = mod(bx, segmentsPerCircle) / segmentsPerCircle * 2. * PI;

  // offset circles
  float circleCount = vertexCount / segmentsPerCircle * vertsPerSegment;
  float circlesPerRow = 33.;
  float circlesPerColumn = floor(circleCount / circlesPerRow);
  float circleId = floor(vertexId / (segmentsPerCircle * vertsPerSegment));
  float cx = mod(circleId, circlesPerRow) * 2.;
  float cy = floor(circleId / circlesPerRow) * 2.;

  vec2 soundTexCoords = vec2(3, 3);
  float sx = cx - circlesPerRow;
  soundTexCoords.x = abs(sx) / (abs(sx) + cy) * 0.215;
  soundTexCoords.y = ((abs(sx) + cy) - 1.) / (circlesPerRow + circlesPerColumn) * 0.25;
  float r = texture(sound, soundTexCoords).r;
  r = r * 1.3;
  r = pow(r, 4.);
  float radius = by * r;
  float x = cos(angle) * radius;
  float y = sin(angle) * radius;

  gl_Position = vec4(x, y, -r / 2., 1);
  gl_Position += vec4(cx, cy, 0, 0);
  gl_Position += vec4(-16., -8, 0, 0) * 2.;

  // scale
  gl_Position *= scale(1. / 64.);

  // fix aspect
  vec4 aspect = vec4(resolution.y / resolution.x, 43, 1, 1);
  gl_Position *= aspect;

  v_color = vec4(r * 2. - 1.5, 0, 1, 1);
}