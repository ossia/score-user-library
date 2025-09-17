/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/296k8Y8nj6kcNxYG9)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 300,
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
    "ORIGINAL_VIEWS": 68,
    "ORIGINAL_DATE": {
      "$date": 1568858435978
    }
  }
}*/


vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
 float ID = vertexId;
 vec4 OutColor = vec4(1,1,1,1);
 gl_Position=vec4(
   cos(ID + time) * (ID * ID * 0.01),
   sin(ID + time) * (40.0),
   1.,
   60.0 + ID );
 gl_PointSize= 5.0;
  float st = step(time,1.0);
  OutColor.x = time * 0.01 - (ID / 300.0);
  OutColor = vec4(hsv2rgb(OutColor.xyz),1.0);

 v_color= OutColor;

}