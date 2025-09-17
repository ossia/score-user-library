/*{
  "DESCRIPTION": "logistic",
  "CREDIT": "kolargon (ported from https://www.vertexshaderart.com/art/q2CemJwQMdeCQ7S7P)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 203,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1551437824057
    }
  }
}*/

 #define ITERS 50

//KDrawmode=GL_TRIANGLE_STRIP

#define lineNumber 1.//KParameter0 1.>>10.
#define speedFactor 1.//Karameter1 1.>>5.
#define sndFactor 3.//KParameter7 0.>>5.0
#define cubeRotFactor 1.//KParameter2 1.>>15.

#define HPI 1.570796326795

#define PI 3.141592653589880

vec3 noise(vec3 _v) {

    return fract(sin(_v * vec3(43758.5453123, 12345.6789012,76543.2109876)));
}

vec3 rotX(vec3 _v, float _rad) {
    vec2 f = sin(vec2(_rad, _rad + HPI));
    vec3 r = _v;
    r.y = _v.y * f.y + _v.z * -f.x;
    r.z = _v.y * f.x + _v.z * f.y;
    return r;
}

vec3 rotY(vec3 _v, float _rad) {
    vec2 f = sin(vec2(_rad, _rad + HPI));
    vec3 r = _v;
    r.x = _v.x * f.y + _v.z * f.x;
    r.z = _v.x * -f.x + _v.z * f.y;
    return r;
}

vec3 rotZ(vec3 _v, float _rad) {
    vec2 f = sin(vec2(_rad, _rad + HPI));
    vec3 r = _v;
    r.x = _v.x * f.x + _v.y * f.y;
    r.y = _v.x * -f.y + _v.y * f.x;
    return r;
}

vec4 perspective(vec3 _v, float _fov, float _near, float _far, vec2 _res) {
    vec4 r = vec4(_v, -_v.z);
    r.xy *= vec2(_res.y / _res.x, 1.0) / tan(radians(_fov * 0.5));
    r.z = (-_v.z * (_far + _near) - 2.0 * _far * _near) / (_far - _near);
    return r;
}

vec3 lookAt(vec3 _v, vec3 _eye, vec3 _look, vec3 _up) {
    vec3 z = normalize(_eye - _look);
    vec3 x = normalize(cross(_up, z));
    vec3 y = cross(z, x);
    vec4 r = mat4(x.x, y.x, z.x, 0.0, x.y, y.y, z.y, 0.0, x.z, y.z, z.z, 0.0, 0.0, 0.0, 0.0, 1.0) *mat4(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -_eye.x, -_eye.y, -_eye.z, 1.0)* vec4(_v, 1.0);
    return r.xyz;
}

vec3 shade(vec3 _eye, vec3 _p, vec3 _n, vec3 _dfscol, float _amb, vec2 _spec)
{
    vec3 rgb;
    vec3 lit = normalize(vec3(1.0, 1.0, 4.0));

    float diffuse = max(0.0, dot(_n, lit)) * (1.0 - _amb) + _amb;

    vec3 h = normalize(normalize(_eye - _p) + lit);
    float specular = 1.0;
    if(diffuse > 0.0) {
        specular = max(0.1,dot(_n, h));
    }

    rgb = diffuse * _dfscol + specular * _spec.y;

    return rgb;
}

#define kShapeVertexCount 36.0
#define kVertexPerShape 6.0

vec3 shapeVertex(float _vId, out vec4 _nI)
{
    float faceId = floor(_vId / kVertexPerShape);
    float vtxId = mod(_vId, kVertexPerShape);
    vec2 fp;
    vec3 v;

    if(vtxId <= 1.0) {
        fp = vec2(1.0, 1.0);
    }
    else if(vtxId == 2.0) {
        fp = vec2(-1.0, 1.0);
    }
    else if(vtxId == 3.0) {
        fp = vec2(1.0, -1.0);
    }
    else {
        fp = vec2(-1.0, -1.0);
    }

    if(faceId == 0.0) {

        v = vec3(fp.x, fp.y, 1.0);
        _nI = vec4(0.0, 0.0, 1.0, faceId);
    }
    else if(faceId == 1.0) {

        v = vec3(-fp.x, fp.y, -1.0);
        _nI = vec4(0.0, 0.0, -1.0, faceId);
    }
    else if(faceId == 2.0) {

        v = vec3(fp.x, 1.0, -fp.y);
        _nI = vec4(0.0, 1.0, 0.0, faceId);
    }
    else if(faceId == 3.0) {

        v = vec3(fp.x, -1.0, fp.y);
        _nI = vec4(0.0, -1.0, 0.0, faceId);
    }
    else if(faceId == 4.0) {

        v = vec3(-1.0, fp.y, -fp.x);
        _nI = vec4(-1.0, 0.0, 0.0, faceId);
    }
    else {

        v = vec3(1.0, fp.y, fp.x);
        _nI = vec4(1.0, 0.0, 0.0, faceId);
    }

    return v;
}

void main() {
    //gl_PointSize = 0.1;
    float sizeFactor = 1./200.;
    //float patternSize = sizeFactor*3.;
    float shapeCount = floor(vertexCount / kShapeVertexCount);
    float shapeId = floor(vertexId / kShapeVertexCount);
    float shapeVertexId = mod(vertexId, kShapeVertexCount);

    float shapeRelId = shapeId/shapeCount;

    float numberOfElement = lineNumber;
    float numberOfLines = shapeCount/numberOfElement;

    float lineId = floor(shapeId/numberOfElement);

    float xPos = mod(shapeId,numberOfElement)/numberOfElement;
    float normXid = xPos/2.;
    xPos = xPos*2.-1.;
    float snd = texture(sound, vec2(normXid, shapeRelId)).r/2.;

    vec4 cbNi;

    vec3 cubep = shapeVertex(shapeVertexId, cbNi);;

    cubep*= min(lineId/10., 1.0)*sizeFactor;//resize

  //LOGISTIC

  vec2 vp = vec2(0.,0.);
  float z = 0.4+snd;//sin(shapeRelId+fract(time/100.));//fract(0.02);

  float trig = (cos(2. * PI * z) + 1.) / 2.;
  float a = mix(1., 3.75, trig) + shapeRelId * mix(3., 0.25, trig);

  for (int i = 0; i < ITERS; i++) {
    z = a * z * (1.-z);
  }
  float iters = float(ITERS);

  cubep.y+= z;
  cubep.x+= shapeRelId;
  //END LOGISTIC

    //cubep = vec3(cubep.x+xPos, cubep.y+sndFactor*snd, cubep.z+lineId*patternSize +mod(time*speedFactor,patternSize));//position
    //vec3 eye = vec3(0.5, 0.5, 1.5);
    vec3 eye = vec3(0.5+sin(time/1.3)/4., 0.5+sin(time/1.)/4., cos(time/5.));
    //vec3 eye = vec3(sin(time/1.3), sin(time/1.), 0.5);//29./2.*abs(cos(time/5.))
    //vec3 eye = vec3(0., 1., 0.5);//29./2.*abs(cos(time/5.))
    vec3 color = shade(eye, cubep, cbNi.xyz, vec3(1.), 0.6, vec2(64.0, .8));

    vec3 p = lookAt(cubep, eye, vec3(0.5, 0.5, 0.), vec3(0.0, 01.0, 0.0));
    gl_Position = perspective(p, 60.0, 0.1, 10.0, resolution);
    gl_PointSize = 2.;

    v_color = vec4(color, 1.0);
    //v_color.x = acc/10.;

}

