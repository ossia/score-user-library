/*{
  "DESCRIPTION": "woozy mod",
  "CREDIT": "PLU Collective (ported from https://www.vertexshaderart.com/art/Siq7bKzSywBNKoE5B)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 5000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1497418523535
    }
  }
}*/

//woozy by gman

//KDrawmode=GL_LINES
#define PointsCntrl 30.//KParameter0 15.>>45.
#define PumpCntrl 0.9//KParameter1 0.1>>0.9
#define SndCntrl 0.5//KParameter2 0.1>>0.9
#define AngleCntrl 21.//KParameter3 10.>>50.
#define ColorCntrl 5.//KParameter4 1.>>10.
#define ScaleCntrl 1.1//KParameter5 0.4>>1.4
#define RadiusCntrl 8.//KParameter6 1.>>20.
#define Squiggle 1.//KParameter7 1.>>10.

#define PI radians(180.0)

void main() {
  float pointsPerLine = PointsCntrl;
  float lineId = floor(vertexId / pointsPerLine);
  float numLines = floor(vertexCount / pointsPerLine);

  float lineV = lineId / numLines;
  float angle = lineV * PI * 2.;

  float pointId = mod(vertexId, pointsPerLine);
  float pointV = pointId / (pointsPerLine - floor(pointsPerLine / Squiggle));

  float id = floor(pointId / 2.) + mod(pointId, 2.);
  float idV = id / (pointsPerLine / 2. - 1.);

  float snd = texture(sound, vec2(abs(lineV - 0.5) * 0.15, pointV * SndCntrl)).r;

  float odd = mod(id, 2.);
  angle += sin(time + idV * AngleCntrl) * odd * 0.2 + time * 0.1 + snd * 0.;
// angle += odd * 0.2;

// float radius = pow(idV + 1., 2.) - 3.0;
  float radius = pow(idV, 2.) + sin(time + lineV * PI * 2. * RadiusCntrl) * odd * idV * 0.1;
  float c = cos(angle) * radius;
  float s = sin(angle) * radius;

  vec2 aspect = vec2(1, resolution.x / resolution.y) * ScaleCntrl;
  vec2 xy = vec2(c, s);
  gl_Position = vec4(xy * aspect, 0, 1);

  float p = 1. - pow(snd, ColorCntrl);
  float pump = step(PumpCntrl, snd);
  v_color = vec4(0, p, p, idV) + pump * vec4(0,10,10,0);
  v_color.rgb *= v_color.a;
}