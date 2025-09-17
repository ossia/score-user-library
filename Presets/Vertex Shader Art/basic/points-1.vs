/*{
  "DESCRIPTION": "points",
  "CREDIT": "lin (ported from https://www.vertexshaderart.com/art/pAqsg4vT33xiFePoG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 1,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.9686274509803922,
    0.9529411764705882,
    0.9529411764705882,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1705311926960
    }
  }
}*/


float x0 = 0.0;
float y0 = 0.0;

float x1 = 0.0;
float y1 = 0.0;

float x2 = 0.5;
float y2 = 0.0;

float x3 = 0.5;
float y3 = 0.0;

//float x3 = 0.6;
//float y3 = 0.3;

//float x4 = 0.4;
//float y4 = 0.5;

// 2 ->6
//3 -> 6*(N-1) = 6x2 =12
//4 -> 6*3= 18

void main() {

  // test 1 ：4 vertices, starts from offset:0
  float offset =0.;

  float u_thickness = 0.1;

  float id = vertexId;

  float line_i = floor(id / 6.);//line index
  float tri_i = mod(id, 6.);// point index in two triangles

  vec4 va[4];

  va[0] = vec4(x0,y0,0,1);
  va[1] = vec4(x1,y1,0,1);
  va[2] = vec4(x2,y2,0,1);
  va[3] = vec4(x3,y3,0,1);

  vec2 v_line = normalize(va[2].xy-va[1].xy);
  vec2 nv_line = vec2(-v_line.y, v_line.x);
  vec2 v_pred = normalize(va[1].xy - va[0].xy);
  vec2 v_succ = normalize(va[3].xy - va[2].xy);
  vec2 v_miter1 = normalize(nv_line + vec2(-v_pred.y, v_pred.x));
  vec2 v_miter2 = normalize(nv_line + vec2(-v_succ.y, v_succ.x));

  vec4 pos;
 if (tri_i == 0. || tri_i == 1. || tri_i == 3.)
{
    vec2 v_pred = normalize(va[1].xy - va[0].xy);
    vec2 v_miter = normalize(nv_line + vec2(-v_pred.y, v_pred.x));

    pos = va[1];
    pos.xy += v_miter * u_thickness * (tri_i == 1. ? -0.5 : 0.5) / dot(v_miter, nv_line);
}
else
{
    vec2 v_succ = normalize(va[3].xy - va[2].xy);
    vec2 v_miter = normalize(nv_line + vec2(-v_succ.y, v_succ.x));

    pos = va[2];
    pos.xy += v_miter * u_thickness * (tri_i == 5. ? 0.5 : -0.5) / dot(v_miter, nv_line);
}

  gl_Position = vec4(pos.xy, 0, 1);

  gl_PointSize = 30.0;

  v_color = vec4(vertexId, 0, 0, 1);
}