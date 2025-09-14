/*{
  "DESCRIPTION": "Line Of Sound",
  "CREDIT": "dertrackererpro (ported from https://www.vertexshaderart.com/art/BwFoiT5wD28u9HN5Z)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 5000,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Volume", "NAME": "volume", "TYPE": "audioFloatHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 231,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1541694021578
    }
  }
}*/

void main () {
  vec3 pos = vec3((vertexId/vertexCount), 0.0, 0.0);
  pos.y = (texture(volume, vec2(0.0, pos.x)).r-0.3)*1.6;
  pos.x = (pos.x-0.5)*2.0;
  vec3 clr = vec3(pos.x, pos.y, -pos.x)+0.5;

  gl_PointSize = 12.0;
  gl_Position = vec4(pos, 1.0);
  v_color = vec4(clr, 1.0);
}