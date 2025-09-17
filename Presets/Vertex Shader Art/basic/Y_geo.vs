/*{
  "DESCRIPTION": "Y geo",
  "CREDIT": "demofox (ported from https://www.vertexshaderart.com/art/SnqDnsfrYzTPyN2BA)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 24,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1507653848749
    }
  }
}*/

#define VERTEX_DATA(inpos, inuv) vert += 1.0; if (vertexId == vert) {pos = inpos; uv = inuv;}

void main() {

  // vertices
  const vec2 AP = vec2(0.4, 0.2);
  const vec2 AU = vec2(0.0, 0.0);

  const vec2 BP = vec2(0.6, 0.2);
  const vec2 BU = vec2(1.0, 0.0);

  const vec2 CP = vec2(0.4, 0.5);
  const vec2 CU = vec2(0.0, 0.7);

  const vec2 DP = vec2(0.6, 0.5);
  const vec2 DU = vec2(1.0, 0.7);

  const vec2 EP = vec2(0.5, 0.6);
  const vec2 EU = vec2(0.5, 0.5);

  const vec2 FP = vec2(0.7, 0.8);
  const vec2 FU = vec2(0.0, 1.0);

  const vec2 GP = vec2(0.8, 0.7);
  const vec2 GU = vec2(1.0, 1.0);

  const vec2 HP = vec2(0.2, 0.7);
  const vec2 HU = vec2(0.0, 1.0);

  const vec2 IP = vec2(0.3, 0.8);
  const vec2 IU = vec2(1.0, 1.0);

  const vec2 JP = vec2(0.5, 0.5);
  const vec2 JU = vec2(0.5, 0.7);

  const vec2 KP = vec2(0.5, 0.6);
  const vec2 KU = vec2(1.0, 0.7);

  const vec2 LP = vec2(0.5, 0.6);
  const vec2 LU = vec2(0.0, 0.7);

  // make the mesh
  vec2 pos = vec2(0.0, 0.0);
  vec2 uv = vec2(0.0, 0.0);
  float vert = -1.0;

  VERTEX_DATA(AP, AU);
  VERTEX_DATA(DP, DU);
  VERTEX_DATA(BP, BU);

  VERTEX_DATA(AP, AU);
  VERTEX_DATA(CP, CU);
  VERTEX_DATA(DP, DU);

  #if 0

  VERTEX_DATA(CP, CU);
  VERTEX_DATA(EP, EU);
  VERTEX_DATA(DP, DU);

  VERTEX_DATA(CP, CU);
  VERTEX_DATA(IP, IU);
  VERTEX_DATA(EP, EU);

  VERTEX_DATA(EP, EU);
  VERTEX_DATA(FP, FU);
  VERTEX_DATA(GP, GU);

  VERTEX_DATA(EP, EU);
  VERTEX_DATA(GP, GU);
  VERTEX_DATA(DP, DU);

  #else

  VERTEX_DATA(CP, CU);
  VERTEX_DATA(KP, KU);
  VERTEX_DATA(JP, JU);

  VERTEX_DATA(JP, JU);
  VERTEX_DATA(LP, LU);
  VERTEX_DATA(DP, DU);

  VERTEX_DATA(CP, CU);
  VERTEX_DATA(IP, IU);
  VERTEX_DATA(KP, KU);

  VERTEX_DATA(LP, LU);
  VERTEX_DATA(FP, FU);
  VERTEX_DATA(GP, GU);

  VERTEX_DATA(LP, LU);
  VERTEX_DATA(GP, GU);
  VERTEX_DATA(DP, DU);

  #endif

  VERTEX_DATA(CP, CU);
  VERTEX_DATA(HP, HU);
  VERTEX_DATA(IP, IU);

  float aspectRatio = resolution.y / resolution.x;
  pos.x *= aspectRatio;

  gl_Position = vec4(pos*2.0-1.0, 0.0, 1.0);
  v_color = vec4(uv, 1.0, 1.0);
}