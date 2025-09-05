/*{
  "DESCRIPTION": "PixelSearching - Testing PixelSearching\n-- Evan Chen\u00a0\n\n",
  "CREDIT": "evan_chen (ported from https://www.vertexshaderart.com/art/SRbaWWFNYiYrDmj9H)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1605587102908
    }
  }
}*/


/*

        .___ __ .
        [__ . , _.._ / `|_ _ ._
        [___ \/ (_][ )____\__.[ )(/,[ )

 01/01/2019
*/

#pragma region Pre_Define
 #define PI radians(180.)
#pragma endregion

#pragma region const
 const float FARCLIPPED = 1000. ;
 const float NEARCLIPPED = 0.1 ;
#pragma endregion

#pragma region MatrixConverte

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

#pragma region

#pragma region Func
   mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up)
   {
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
  float hash(float p)
  {
      vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
      p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
      return fract(p2.x * p2.y * 95.4337);
  }

  float m1p1(float v) //normalize to NDC
  {
    return v * 2. - 1.;
  }

  float inv(float v)
  {
    return 1. - v;
  }
/*
  vec3 getQPoint(const float id)
  {
    float outId = mix(id, 8. - id, step(2.5, id));
    float ux = floor(outId / 6.) + mod(outId, 2.);
    float vy = mod(floor(outId / 2.) + floor(outId / 3.), 2.);
    vec3 pos = vec3(ux, vy, 0);
    return pos;
  }
*/
  void GetMatrixFromZY( const vec3 vZ, const vec3 vY, out mat3 m )
  {
     vec3 vX = normalize( cross( vY, vZ ) );
     vec3 vOrthoY = normalize( cross( vZ, vX ) );
     m[0] = vX;
     m[1] = vOrthoY;
     m[2] = vZ;
  }
#pragma endregion

/* -------------------------------- separator ------------------------------- */

/* -------------------------------- separator ------------------------------- */

void main()
{
  #pragma region ProjectionSetUp
     mat4 m = persp(radians(45.),
        resolution.x/ resolution.y,
        NEARCLIPPED ,
        FARCLIPPED);
  #pragma endregion

  #pragma region CameraSetUp/ViewSetUp
      vec3 target = vec3(0. ) ;
      vec3 up = vec3(0. ,1. , 0. ) ;
      vec3 camTarget = target ;
      vec3 camPos = vec3(1.);
      vec3 camForward = normalize(camTarget - camPos);
      m *= cameraLookAt(camPos , camTarget, normalize(up));
  #pragma endregion

  #pragma region model
      m *= uniformScale(0.7);
      m *= trans(vec3(1.)) ;
      m *= rotY(0.2);
  #pragma endregion

  #pragma region Light
    vec3 ambient = vec3(0.) ;
    vec3 diffuse = vec3(0.) ;
    vec3 specular = vec3(0.);
    vec3 result = ambient + diffuse + specular ;
  #pragma endregion

  #pragma region TestDFS

  #pragma endregion

  #pragma region basic Element
    gl_Position = m * vec4(1.) ;
    gl_PointSize *= (vec4(1.0 , 0., 0., 0.)* uniformScale(10.)).x ;
    v_color = vec4(result, 1. ) ;
  #pragma endregion

}
// Removed built-in GLSL functions: transpose, inverse