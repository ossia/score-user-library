/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/QWNj2ZspFrBLdtsJm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.27058823529411763,
    0.6509803921568628,
    0.7294117647058823,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 14,
    "ORIGINAL_DATE": {
      "$date": 1666962565214
    }
  }
}*/

void main()
{

 vec4 color = vec4(1.0, 0.0, 0.0, 1.0);
   /*if (sin(time) >= 0.0)
      color = vec4(sin(time), 1.0/sin(time), 0.0, 0.0);
   else
      color = vec4(1.0/(sin(time)*-1.0), sin(time)*-1.0, 0.0, 0.0);*/

   vec4 pos = vec4(vertexId/10.0, vertexId/10.0, 0.0, 1.0);
   gl_Position = pos;

}