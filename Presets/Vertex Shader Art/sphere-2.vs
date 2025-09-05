/*{
  "DESCRIPTION": "sphere - based on gman's morp",
  "CREDIT": "watermeloon (ported from https://www.vertexshaderart.com/art/oEaayNGujJaMMkRSu)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.9215686274509803,
    0.984313725490196,
    0.9176470588235294,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 102,
    "ORIGINAL_DATE": {
      "$date": 1655326039946
    }
  }
}*/

#define RESOLUTION_OF_MY_DISPLAY 2000.0
#define PI radians(180.)

//6956

//X axis rotation
mat4 rotateX(float angleInRadians){
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0, -s, c, 0,
      0, 0, 0, 1);
}

//Y axis rotation
mat4 rotateY(float angleInRadians){
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

//Z axis rotation
mat4 rotateZ(float angleInRadians){
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

//returns the evenly distributed points
vec4 FIBO(float rad, float id, float sum){

   //golden angle in radians
  float phi = PI * (3. - sqrt(5.));

   // y goes from 1 to -1
  float y = 1. - (id / (sum - 1.)) * 2.;
  float radius = sqrt(1. - y * y);

  float theta = phi * id;

  float x = cos(theta) * radius;
  float z = sin(theta) * radius;

  vec4 point = vec4(x * rad, y * rad, z * rad, 1.);

  float xz = abs(atan(point.x, point.z) - rad / 2.) / PI;
  float yy = abs(point.y) * 1.;

  float snd = texture(sound, vec2(mix(0.1, 0.5, xz), yy)).r;

  point.x *= pow(0.2 + snd, 0.2);
  point.y *= pow(0.2 + snd, 0.2);
  point.z *= pow(0.2 + snd, 0.2);

  return point;
}

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 0.5 - 0.5 * fov);
  float rangeInv = 1.0 / (zNear - zFar);

  return mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
    0, 0, zNear * zFar * rangeInv * 2., 0);
}
mat4 lookAt(vec3 eye, vec3 target, vec3 up) {
  vec3 zAxis = normalize(eye - target);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, 0,
    zAxis, 0,
    eye, 1);
}

void main(void){

  //rotation velocity
  mat4 rotX = rotateX(time * 0.3);
  mat4 rotY = rotateY(time * 0.2);
  mat4 rotZ = rotateZ(time * 0.3);

  vec4 sphere;
  float radius = (abs(sin(time * 0.02)) + 0.9) * .8;

  //initializing the vertices
  if(mod(vertexId, 3.) == 0.){
    radius *= 0.7;
   sphere = FIBO(radius, vertexId, floor(vertexCount / 10.));
    //rotation of the sphere
   sphere *= rotX;
   sphere *= rotY;
   //sphere *= rotZ;
  }else if(mod(vertexId, 3.) == 1.){
    radius *= 0.5;
   sphere = FIBO(radius, vertexId, floor(vertexCount / 10.));
    //rotation of the sphere
   //sphere *= rotX;
   sphere *= rotY;
   sphere *= rotZ;
  }else{
    radius *= 0.4;
    sphere = FIBO(radius * 0.6, vertexId, floor(vertexCount / 10.));
    //rotation of the sphere
   sphere *= rotX;
   //sphere *= rotY;
   sphere *= rotZ;
  }

  float tm = time * 0.1;
  float tm2 = time * 0.13;

  float r = 2.5;
  mat4 mat = persp(radians(60.0), resolution.x / resolution.y, 0.1, 10.0);
  vec3 eye = vec3(cos(tm) * r, sin(tm * 0.93) * r, sin(tm) * r);
  vec3 target = vec3(0);
  vec3 up = vec3(0., sin(tm2), cos(tm2));

  mat *= inverse(lookAt(eye, target, up));

  vec4 denorm = mat * sphere;

  //the sphere
  gl_Position = denorm;

  //setting a base point size
  gl_PointSize = 10.;
  //adjusting the point size based on the depth
  //gl_PointSize += pow(radius, 4.) * 600.;
  //adjustment
  gl_PointSize *= 0.03;
  //resolution indipendent
  gl_PointSize *= resolution.x / RESOLUTION_OF_MY_DISPLAY;

  vec3 color = mix(vec3(0.5, 0, 0), vec3(0, 0, 0.5), sphere.z * 7.3);
  v_color = vec4(color, mix(.0, 1., pow(1. * radius * .6 * gl_Position.z, 2.)));
  v_color.rgb *= v_color.a;

}

// Removed built-in GLSL functions: inverse