/*{
  "DESCRIPTION": "test pos - test",
  "CREDIT": "morimea (ported from https://www.vertexshaderart.com/art/TFXxrMbQQXNqtcTE8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 41,
    "ORIGINAL_DATE": {
      "$date": 1616855567439
    }
  }
}*/


// test shader

#define xpoints

#define NUM 30.0
  void main() {

    // points

    #ifdef points
    gl_PointSize = 64.0;
    float col = mod(vertexId, NUM + 1.0);
    float row = mod(floor(vertexId / NUM), NUM + 1.0);
    float x = col / NUM * 2.0 - 1.0;
    float y = row / NUM * 2.0 - 1.0;
    gl_Position = vec4(x, y, 0, 1);
    v_color = vec4(fract( (col) / NUM)*100., ( mod(col , 2.)), 0, 1);
    if(vertexId==50.)v_color.rgb=vec3(1.,0.,1.);
    if(vertexId==10.)v_color.rgb=vec3(0.,1.,1.);
    if(vertexId==vertexCount-1.)v_color.rgb=vec3(.25,.25,1.);
    #else

    //trianlges
    gl_PointSize = 14.0;
    float vertexId_triangle=floor(vertexId/3.);
    float tri_vtx=mod(vertexId,3.);
    float col = mod(vertexId_triangle, NUM + 1.0);
    float row = mod(floor(vertexId_triangle / NUM), NUM + 1.0);
    float x = col / NUM * 2.0 - 1.0;
    float y = row / NUM * 2.0 - 1.0;
    float a=0.;
    if(tri_vtx==1.)a=1.;
    if(tri_vtx==2.)a=0.;
    x+=(a)*.1;
    y+=(1.-tri_vtx)*.1;
    gl_Position = vec4(x, y, 0, 1);
    v_color = vec4(fract( (col) / NUM)*100., ( mod(col , 2.)), 0, 1);
    if(vertexId_triangle==0.)v_color.rgb=vec3(1.,1.,1.);
    if(vertexId_triangle==20.)v_color.rgb=vec3(1.,0.,1.);
    if(vertexId_triangle==10.)v_color.rgb=vec3(0.,1.,1.);
    if(vertexId_triangle==floor(vertexCount/3.)-1.)v_color.rgb=vec3(.25,.25,1.);
    #endif

  }