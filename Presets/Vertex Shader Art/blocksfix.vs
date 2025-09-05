/*{
  "DESCRIPTION": "blocksfix",
  "CREDIT": "jarredthecoder (ported from https://www.vertexshaderart.com/art/japgmuqb6SYNuHBb4)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 21017,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.30980392156862746,
    0.30980392156862746,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 50,
    "ORIGINAL_DATE": {
      "$date": 1670455746207
    }
  }
}*/

varying vec2 surfacePosition;
void main(){
 vec2 pos = surfacePosition;

 const float pi = 3.14159;
 const float n = 12.0;

 float radius = length(pos)*6. - 1.;
 float t = atan(pos.y, pos.x)/pi;

 float color = 0.0;
 for (float i = 1.; i < n; i++){
  color += 0.01/abs(color+i*0.15*sin(18.0*pi*(t + i/n*time*0.05)) - radius);
 }

 v_color = vec4(vec3(1., 1., 1.0) * color, color);

}