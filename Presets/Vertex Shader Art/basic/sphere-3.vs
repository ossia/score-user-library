/*{
  "DESCRIPTION": "sphere",
  "CREDIT": "sergioerick (ported from https://www.vertexshaderart.com/art/wJtgtpePx8uemptoj)",
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1552844856440
    }
  }
}*/

void main(){
 float pointsDraw = 70.0;
 float radius = 0.8;

 float xCircle = mod(vertexId, pointsDraw);
 float yCircle = floor(vertexId / pointsDraw);

 float angleT = xCircle / pointsDraw * radians(360.0);
 float angleP = yCircle / pointsDraw * radians(360.0);

 float x = radius * sin(angleT) * cos(angleP);
 float y = radius * sin(angleT) * sin(angleP);
 float z = radius * cos(angleT);

 vec3 xyz = vec3(x, y, z)* 0.8;

 mat3 rx = mat3(cos(time), 0, sin(time),
        0, 1, 0,
        -sin(time), 0, cos(time));
 mat3 ry = mat3(1, 0, 0,
     0, cos(time), -sin(time),
     0, sin(time), cos(time));

 xyz = rx * xyz;
 xyz = ry * xyz;

 gl_Position = vec4(xyz, 1.0);
 gl_PointSize = 2.0;
 v_color = vec4(0.0,0.0,1.0,1.0);
}