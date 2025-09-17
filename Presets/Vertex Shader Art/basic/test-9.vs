/*{
  "DESCRIPTION": "test",
  "CREDIT": "chemlo (ported from https://www.vertexshaderart.com/art/dvzt2TN84y8LGgnsn)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5000,
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
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1493851187233
    }
  }
}*/

vec3 posf2(float t, float i) {
 return vec3(
      sin(t+i*.9553) +
      sin(t*1.311+i) +
      sin(t*1.4+i*1.53) +
      sin(t*1.84+i*.76),
      sin(t+i*.79553+2.1) +
      sin(t*1.311+i*1.1311+2.1) +
      sin(t*1.4+i*1.353-2.1) +
      sin(t*1.84+i*.476-2.1),
      sin(t+i*.5553-2.1) +
      sin(t*1.311+i*1.1-2.1) +
      sin(t*1.4+i*1.23+2.1) +
      sin(t*1.84+i*.36+2.1)
 )*.2;
}

void main() {
  float t = time*.20;
  float i = vertexId+sin(vertexId)*100.;

  vec3 pos = posf2(t, i);

  pos.yz *= mat2(.8,.6,-.6,.8);
  pos.xz *= mat2(.8,.6,-.6,.8);

  gl_PointSize = 1.+pos.z*5.;
  gl_Position = vec4(pos.x, pos.y, pos.z, 1);
  v_color = vec4(pos.z*10., 0. , -pos.z*10., 1);
}