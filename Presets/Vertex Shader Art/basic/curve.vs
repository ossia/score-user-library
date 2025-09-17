/*{
  "DESCRIPTION": "curve",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/5vfETRh3Q89xEEMAA)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1024,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 122,
    "ORIGINAL_DATE": {
      "$date": 1463879885693
    }
  }
}*/

void main() {
  //float t = float(vertexId) / float(vertexCount);

  //vec3 xyz = vec3(cos(t), sin(t), 1.0);

  //gl_Position = vec4(xyz * 50.0, 1.0);
  //v_color = min(vec4(2.),vec4(xyz.x,xyz.y,2,1))/max(0.,(-xyz.z*5.+5.));
  float phi = vertexId / vertexCount * 3.14159265*2.0;

  float x = cos(phi);
  float y = sin(phi);
  float z = 0.0;

  float theta = 5.0 * sin(sign(y)*cos(phi)*3.1415192) * sin(time);//(x+time * 0.3) * 3.141592*2.0;

  //x *= cos(theta);
  y *= cos(theta);
  z = sin(theta);

  vec4 pos = vec4(x, y, z, 1.0);

  vec3 eye = vec3(sin(time), 0, cos(time));
  vec3 right = vec3(-eye.z, 0, eye.x);
  vec3 look = -eye;
  /*
m[0]=right.x
m[1]=right.y
m[2]=right.z

m[4]=up.x
m[5]=up.y
m[6]=up.z

m[8]=look.x
m[9]=look.y
m[10]=look.z
*/

  mat4 L = mat4(vec4(right, 0), vec4(0, 1, 0, 0), vec4(look, 0), vec4(0, 0, 0, 1));

  gl_Position = (L * pos) * vec4((resolution.y / resolution.x) * 0.5, 0.5, 0.5, 1);
  v_color = vec4(sin(theta) *0.5 + 0.5,
        cos(phi) *0.5 + 0.5,
        sin(time) * 0.5 + 0.5,
        1.0);
}