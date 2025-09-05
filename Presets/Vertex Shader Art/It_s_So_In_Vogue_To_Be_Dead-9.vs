/*{
  "DESCRIPTION": "It's So In Vogue To Be Dead - Bust a move.",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/Qh7WiD2iwnCrdfCXy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1099,
    "ORIGINAL_LIKES": 6,
    "ORIGINAL_DATE": {
      "$date": 1502510128699
    }
  }
}*/

#define PI radians(180.)
#define circular 1

mat4 scale(float s)
{
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
}

vec2 CircleVPos(float vId, float segmentsPerCircle) {
  float bx = mod(vId, 2.) + floor(vId / 6.);
  float by = mod(floor(vId / 2.) + floor(vId / 3.), 2.); // 0 0 1, 0 1 1, 1 1 0, 1 0 0, ...
  float angle = mod(bx, segmentsPerCircle) / segmentsPerCircle * 2. * PI;
  return vec2(cos(angle), sin(angle)) * by;
}

void main() {
  float segmentsPerCircle = 24.;
  float vertsPerSegment = 6.;

  // set base vert pos
  vec2 nCircleVertexPos = CircleVPos(vertexId, segmentsPerCircle);

  // offset circles
  float circleCount = vertexCount / (segmentsPerCircle * vertsPerSegment);
  float circlesPerRow = 30.;
  vec2 gridSize = vec2(circlesPerRow, floor(circleCount / circlesPerRow));
  float circleId = floor(vertexId / (segmentsPerCircle * vertsPerSegment));
  vec2 modelPos = vec2(mod(circleId, circlesPerRow), floor(circleId / circlesPerRow));

  vec2 soundTexCoords = vec2(0, 0);
#if circular
  vec2 sndUv = modelPos;
  sndUv.x -= gridSize.x * 0.5;
  float theta = atan(abs(sndUv.x)/sndUv.y) / (PI*0.5); // theta goes from 0 to 1, radialy, from the middle vertical to the bottom horizontal
  theta *= 0.66; // 1/3rd of the sound texture is unused.
  theta *= 0.75; // arbitrarily trimming to find a good section of the sound tex.
  theta += 1./480.;
  soundTexCoords.x = theta;
  float maxLen = length(vec2(gridSize.x*0.5, gridSize.y));
  soundTexCoords.y = length(sndUv)*0.05 / maxLen;
#else
  float sx = modelPos.x - circlesPerRow * 0.5 - mod(circlesPerRow, 2.0) * 0.5;
  soundTexCoords.x = abs(sx) / (abs(sx) + modelPos.y) * 0.215;
  soundTexCoords.y = ((abs(sx) + modelPos.y) - 1.) / (circlesPerRow + gridSize.y) * 0.1;
#endif

  float s = texture(sound, soundTexCoords).r;
  soundTexCoords.y -= 1./240.;
  float s1 = texture(sound, soundTexCoords).r+0.5;
  //s1 = clamp(s1, 0., 1.);
  //s *= s1;
  s *= 0.75+soundTexCoords.x*1.25; // enhance strength of high-end values
  s = smoothstep(0.2, 0.8, s);
  s = pow(s, 4.); // enhance enhance enhance
  vec2 circleVertexPos = nCircleVertexPos * s;

  float viewDist = -10.; // pretty much just used to approximate "viewing at a distance" in lieu of an actual perspective matrix.
  vec2 viewPos = vec2(-gridSize*0.5);

  gl_Position = vec4((modelPos + circleVertexPos + viewPos)/-viewDist, -s / 2., 1);

  // fix aspect
  vec4 aspect = vec4(resolution.y / resolution.x, 1, 1, 1);
  gl_Position *= aspect;

  //v_color = vec4(theta, 0.0, 0.0, 1.0);
  v_color = vec4(s * 2. - 0.5, 0, 1, 1);
}