/*{
  "DESCRIPTION": "Hello wobbly triangle",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/4tdHwGGpfKN7AQpoQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 2524,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.8784313725490196,
    0.9333333333333333,
    0.8313725490196079,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 72,
    "ORIGINAL_DATE": {
      "$date": 1590748979541
    }
  }
}*/


void main(){

  vec2 xy =vec2(-0.5,0);
  if (vertexId == 1.0)
   {
      xy=vec2(0,0.5);
   }

  else if(vertexId == 2.0)
  {
   xy = vec2(0.5,0);
  }
  xy +=vec2(0,sin(time));
   gl_Position = vec4(xy,0.0,1.0);
    gl_PointSize =10.0;

    v_color = vec4(1.0,0.0,0.0,1.0);

  }