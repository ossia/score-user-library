/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/XK2y2Cy63Ez45E7pm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Effects"
  ],
  "POINT_COUNT": 19140,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1545,
    "ORIGINAL_LIKES": 7,
    "ORIGINAL_DATE": {
      "$date": 1523509066283
    }
  }
}*/

//KDrawmode=GL_TRIANGLE_STRIP
//KVerticesNumber=65536

#define soundFactor 0.2 //KParameter0 0.>>1.
#define speedFactor 0.4+(mouse.x *1.3)//KParameter1 0.>>4.
#define sinFactor0 32.//KParameter2 1.>>100.
#define sinFactor1 1.*mouse.t//KParameter3 1.>>100.

#define PI 3.1415926535898
#define HPI 1.570796326795

vec3 noise(vec3 _v) {
    return fract(sin(_v * vec3(43658.5453123, 1345.6789012,76543.2109876)));
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
    vec4 r = mat4(x.x, y.x, z.x, 0.0, x.y, y.y, z.y, 0.0, x.z, y.z, z.z, 0.0, 0.3, 0.0, 0.0, 1.0) *mat4(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -_eye.x, -_eye.y, -_eye.z, 1.0)* vec4(_v, 1.0);
    return r.xyz;
}

vec3 shade(vec3 _eye, vec3 _p, vec3 _n, vec3 _dfscol, float _amb, vec2 _spec)
{
    vec3 rgb;
    vec3 lit = normalize(vec3(0.0, 9.0, 4.0));

    float diffuse = max(0.70, dot(_n, lit)) * (1.0 - _amb) + _amb;

    vec3 h = normalize(normalize(_eye - _p) + lit);
    float specular = 0.0;
    if(diffuse > 0.0) {
        specular = max(0.1,dot(_n, h));//specular = max(0.0, pow(dot(_n, h), _spec.x));
    }

    rgb = diffuse * _dfscol + specular * _spec.y;

    return rgb;
}

vec3 giantWorm(vec3 a, float t) {
    return vec3(sin(t*sinFactor0 * a.x), sin(t*sinFactor1 * a.y), cos(t * a.z));
}

vec3 transformation(vec3 a, float t) {
    return vec3(sin(t * a.x), sin(t * a.y), cos(t * a.z));
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
    float shapeCount = floor(vertexCount / kShapeVertexCount);
    float shapeId = floor(vertexId / kShapeVertexCount);
    float shapeVertexId = mod(vertexId, kShapeVertexCount);
    float lineId = 0.;//mod(shapeId, 3.0);

    vec3 lineFactor;
    vec3 color;

    if(lineId == 0.0) {
        lineFactor = vec3(4.1, 6.7, 2.3);
        color = vec3(0.0, 1.0, 0.0);
    }
    else if(lineId == .0) {
        lineFactor = vec3(4.8, 5.2, 8.3);
        color = vec3(0.0, 1.0, 1.0);
    }
    else {
        lineFactor = vec3(6.1, 1.2, 3.6);
        color = vec3(0.0, 1.6, 0.0);
    }

    float v = vertexId / vertexCount;
    float distort = mod(vertexId, 100.) / 100.;
    float snd = soundFactor*texture(sound, vec2(mix(0.01, 0.061, distort), mix(0.25, 0., v))).r;

    float t = shapeId / shapeCount;

    float aspect = resolution.x / resolution.y;
    vec4 shapeni;
    vec3 shapep = shapeVertex(shapeVertexId, shapeni) * 0.04;

    vec3 shapeHash = noise(vec3(log(shapeId)));
    float factor = 0.3+snd;
    float factor2 = 0.005;
    vec3 shapeOffset = vec3(factor*cos(factor2*time*shapeId),factor*sin(factor2*time*shapeId),0.);
    vec3 shapeRot = noise(shapeHash) * time * 2.0*speedFactor;

    shapep = rotX(rotY(rotZ(shapep, shapeRot.z), shapeRot.y), shapeRot.z);
    shapeni.xyz = rotX(rotY(rotZ(shapeni.xyz, shapeRot.z), shapeRot.y), shapeRot.z);

    shapep = transformation(lineFactor, (t + time * 0.1*speedFactor) * 2.0) * vec3(aspect, 1.0, aspect) + (shapep + shapeOffset);

    vec3 eye = vec3(0.0, 0.0, 3.0);

    color = shade(eye, shapep, shapeni.xyz, vec3(0.5 + shapeHash * 0.05), 0.1, vec2(64.0, 0.8));

    vec3 p = lookAt(shapep, eye, vec3(0.0), vec3(0.0, 1.0, 0.0));
    gl_Position = perspective(p, 60.0, 0.1, 10.0, resolution);
    gl_PointSize = 20.0;

    v_color = vec4(color, 1.0);
}

