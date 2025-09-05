/*{
  "DESCRIPTION": "rot_test - test",
  "CREDIT": "viktor (ported from https://www.vertexshaderart.com/art/7gmHgFYYTRjd3BKEZ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 16384,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1496440811884
    }
  }
}*/



struct Ori {
  vec3 a_;
  vec3 b_;
};

void main() {
   int idx = int(vertexId);
  vec3 rpos;
  vec3 rcol = vec3(1,0,0);

    Ori src = Ori(vec3(0,0,1), vec3(0,1,0));
   Ori dst = Ori(normalize(vec3(0,0,1)), normalize(vec3(1,1,0)));

    if(idx == 1) { rpos = src.a_; }
    if(idx == 3) { rpos = src.b_; }

    if(idx >= 4) rcol = vec3(0,1,0);
    if(idx == 5) { rpos = dst.a_; }
    if(idx == 7) { rpos = dst.b_; }

  gl_Position = vec4(rpos, 1);
   v_color = vec4(rcol, 1);
}