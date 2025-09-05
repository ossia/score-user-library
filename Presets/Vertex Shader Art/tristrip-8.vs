/*{
  "DESCRIPTION": "tristrip",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/zvKXwd6wx6E38aPmf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Effects"
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
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 71,
    "ORIGINAL_DATE": {
      "$date": 1589064752743
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

uniform int numPoints;

const vec2 aspect=vec2(1.0,16.0/9.0);
#define PER_ROW 256.0 // cells per row
#define DEGEN_VERTS_PER_ROW 4.0 // verts
#define VERTS_IN_ROW ((PER_ROW*2.0)+DEGEN_VERTS_PER_ROW + 2.0)
  /*
    Draw triangle strip by inserting degenerate triangles (zero area)
    at the end, and begining of rows.

    Why? Heightmaps, plane distorations / displacements
        Cache coherance
        Fewers verts used to make a grid

    Why not? UV's shared, wasted triangles,
        hardware implementation determines net gain of approach
        cache priming may or may not work dependant on hardware
        (it has in the cases i've used it for, 25% perf gain over triangles
        with indexed tri-strip and cache priming.
        Case usage was distorting images using a grid and interpolation
        instead of shader.)

        9\\ 11\\ 13,(14) <---degen
        | \\ | \\|
degen-->(7)8 \\10 12
        1\\ 3\\ 5(6) <---degen
        | \\ | \\ |
        | \\| \\|
        0 2 4
  */
void main(){
  gl_PointSize=2.0;
  vec2 id = vec2(vertexId);
  vec2 p = floor(id/vec2(2.0,VERTS_IN_ROW));
  float row = p.y; p.y=id.x;
  gl_Position = vec4(mod(p, vec2(VERTS_IN_ROW/2.0, 2.0))+vec2(0.0,row),1.0,1.0);
  bool test = (gl_Position.x>=(PER_ROW+1.0));
  gl_Position = vec4((gl_Position.xy*float(!test))+(float(test)*vec2(PER_ROW*float(gl_Position.x==(PER_ROW+1.0)),row+1.0)),0.0,1.0);
  gl_Position.xy *=aspect/(PER_ROW/1.40);
  gl_Position.xy-=vec2(.7,.7);
  v_color =vec4(1.0);
}