/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/DPyrvZcaDSQBadMfb)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 256,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 69,
    "ORIGINAL_DATE": {
      "$date": 1508083775559
    }
  }
}*/

 void main()
 {

   gl_PointSize = 10.0;
   gl_Position = vec4(-0.5, -0.5, 0.0, 1.0);
   v_color = vec4(1.0, 0.0, 0.0, 1.0);
 }