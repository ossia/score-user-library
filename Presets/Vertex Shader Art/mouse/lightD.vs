/*{
  "DESCRIPTION": "lightD",
  "CREDIT": "evan_chen (ported from https://www.vertexshaderart.com/art/ABszkWtBmfrqcHecz)",
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
    0.9764705882352941,
    1,
    0.8980392156862745,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 540,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1577693506797
    }
  }
}*/

/*

        .___ __ .
        [__ . , _ ._ / `|_ _ ._
        [___ \/ (/,[ )____\__.[ )(/,[ )

       . . , .__ .
       | * _ |_ -+- *._ [__)*\./ _ |
       |___|(_][ ) | |[ ) | |/'\(/,|
        ._|

20/12/2019

*/
//Best Regard, @gman

#define PI radians(180.)

mat4 mAspect = mat4
(
  1, 0, 0, 0,
  0, resolution.x / resolution.y, 0, 0,
  0, 0, 1, 0,
  0, 0, 0, 1
);
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotY( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

mat4 rotZ( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
    0, 0, 0, 1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
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

mat4 trInv(mat4 m) {
  mat3 i = mat3(
    m[0][0], m[1][0], m[2][0],
    m[0][1], m[1][1], m[2][1],
    m[0][2], m[1][2], m[2][2]);
  vec3 t = -i * m[3].xyz;

  return mat4(
    i[0], t[0],
    i[1], t[1],
    i[2], t[2],
    0, 0, 0, 1);
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

mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up) {
  #if 1
  return inverse(lookAt(eye, target, up));
  #else
  vec3 zAxis = normalize(target - eye);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, 0,
    zAxis, 0,
    -dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), 1);
  #endif

}
// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

float m1p1(float v) {
  return v * 2. - 1.;
}

float inv(float v) {
  return 1. - v;
}

vec3 getQPoint(const float id) {
  float outId = mix(id, 8. - id, step(2.5, id));
  float ux = floor(outId / 6.) + mod(outId, 2.);
  float vy = mod(floor(outId / 2.) + floor(outId / 3.), 2.);
  vec3 pos = vec3(ux, vy, 0);
  return pos;
}
void GetMatrixFromZY( const vec3 vZ, const vec3 vY, out mat3 m )
{
   vec3 vX = normalize( cross( vY, vZ ) );
   vec3 vOrthoY = normalize( cross( vZ, vX ) );
   m[0] = vX;
   m[1] = vOrthoY;
   m[2] = vZ;
}

void main ()
{
  float pointsPerSphere = vertexCount;
  float pointsPerLoop = 1.;
  float sphereId = floor(vertexId / pointsPerSphere);
  float spherePointId = mod(vertexId, pointsPerSphere);
  float aspectR = resolution.x / resolution.y ;

  mat4 m = persp(radians(45.), resolution.x / resolution.y, 0.1, 20.);
  vec3 camera = vec3(0., 0., 1);
  vec3 target = vec3(0.);
  vec3 up = vec3(0.,1.,0.);

  float radius = 0.5 ;

 #pragma region ViewMatrix
    //camera
    float animTime = time;
    float orbitAngle = animTime * 0.3456 + 4.0;
    float elevation = -0.02 + (sin(animTime * 0.223 - PI * 0.5) * 0.5 + 0.5) * 0.5;
    float fOrbitDistance = 5.0 + (cos(animTime * 0.2345) * 0.5 + 0.5 ) * 40.0;

    vec3 vCameraTarget = target;

    vec3 vCameraPos = vCameraTarget + vec3( sin(orbitAngle),
        sin(elevation),
        1.);
    vec3 vCameraUp = vec3( 0., 1., 0. );
    vec3 vCameraForwards = normalize(vCameraTarget - vCameraPos);

  m*= cameraLookAt(vCameraPos , vCameraTarget , normalize(vCameraUp));

 #pragma endregion

  #pragma region modelSetup
    m*= uniformScale(0.7);
  #pragma endregion

  #pragma region CubeSetUp
    float yPos = cos(spherePointId / pointsPerSphere * PI) * radius;
    float xyLen = sin(spherePointId / pointsPerSphere * PI) * radius;
    float xPos = sin(spherePointId ) * xyLen;
    float zPos = cos(spherePointId ) * xyLen;

    vec4 pos = vec4(xPos, yPos, zPos, 1) + vec4(target, 0.);
    vec3 objectC = vec3(0. , 0. , 0.);
  #pragma endregion

  vec3 normal = normalize(vec3(xPos , yPos , zPos));
  float lZoffSet = ((abs(mouse.x * aspectR) > radius) && (abs(mouse.y * aspectR) > radius))? 1. : 0. ;

  vec3 lightP = vec3(10. , 10. ,10.+ pos.z);
  vec3 lightC = vec3(1.0) ;

  float aStrength = 0.1 ;
  vec3 ambient = lightC * aStrength ;
  float dStrength = 1.;

  vec3 l2SD = normalize(lightP - vec3(pos)) ;
  float diff = max(dot(normal , l2SD) , 0. );
  vec3 diffuse = dStrength* diff * lightC;

  float sStrength = 0.001 ;
  vec3 viewP = vec3(1.) ;
  vec3 viewD = normalize(viewP - vec3(pos));
  vec3 refDir = reflect(-l2SD , normal);
  float spec = pow(max(dot(refDir , viewP) , 0.), 10.);
  vec3 specular = spec * sStrength * lightC ;

  vec3 resultC = vec3(1.) ;
  resultC = ambient + diffuse + specular;

  gl_Position = m * pos ; ;
  gl_PointSize *= (vec4(1.0 , 0., 0., 0.)* uniformScale(10.)).x ;

  v_color = vec4(objectC + resultC , 1. ) ;

}
// Removed built-in GLSL functions: transpose, inverse