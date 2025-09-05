/*{
  "DESCRIPTION": "Functions rotation animation - logic based on my own old demo https://youtu.be/405yudjksDA",
  "CREDIT": "morimea (ported from https://www.vertexshaderart.com/art/8AQFD78CWiZsN4phd)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 99360,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.050980392156862744,
    0.050980392156862744,
    0.050980392156862744,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 610,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1599349722701
    }
  }
}*/

/*

 Created by Danil (2020+) https://github.com/danilw

 Mouse rotation - Left mouse key and move mouse to rotate.

 This is port to vertex shader my old code, old code can be found here https://youtu.be/405yudjksDA

*/

// num lines
// NUM_SEGMENTS 100. 100*2*360 = 72000
// NUM_SEGMENTS 138. 138*2*360 = 99360
#define NUM_SEGMENTS 138.

// anim speed
#define speed 0.95

// debug

//#define debug
const int debug_fid = 0;

vec3 findaxis();
vec3 get_color(vec3 rotate);
vec4 get_func(int fid, float x);
vec3 my_normalize(vec3 v);
mat4 rotationAxisAngle(vec3 v, float angle);
vec3 encodeSRGB(vec3 linearRGB);

#ifdef debug
#define time (((mouse.x + 1.) * 27.05 * 0.5) / speed)
#endif

void main() {
    const float pi = 3.1415926;
    vec4 iMouse = textureLod(touch, vec2(0., 0.), 0.);
    int fid = int(mod(speed * time / (27.05 + .05), 14.));
    #ifdef debug
    fid = debug_fid;
    #endif
    float vert_z = mod(vertexId, NUM_SEGMENTS) / (NUM_SEGMENTS);
    float idx = floor((vertexId / 2.) / NUM_SEGMENTS);
    float slength = 1. / (NUM_SEGMENTS);
    vec2 aspect = vec2(1, resolution.x / resolution.y);
    float vert_s = floor(vertexId / 2.) * slength;
    float ecolf = (((int(mod(vertexId, NUM_SEGMENTS)) == 0) || (int(mod(vertexId, NUM_SEGMENTS)) == int(NUM_SEGMENTS - 1.))) ? 0. : 1.);

    vec4 val = get_func(fid, (vert_z));
    vec3 rotate = findaxis();
    vec4 col = vec4(get_color(rotate), 1.);
    col.rgb = sqrt(encodeSRGB(col.rgb));
    col.rgb += 0.05 * (dot(col.rgb, vec3(1.)));
    col.rgb *= val.z * val.w * ecolf;
    rotate = my_normalize(rotate);

    vec2 xy = val.yx * vec2(0.06);

    gl_Position = vec4(xy + 0.000001, 0.000001, 1.);
    gl_Position = gl_Position * rotationAxisAngle(rotate.xyz, ((2. * pi) / 360.) * idx);
    if (iMouse.z > 0.15) gl_Position = gl_Position * rotationAxisAngle(vec3(0., 1., 0.), iMouse.x * pi / 1.) * rotationAxisAngle(vec3(1., 0., 0.), iMouse.y * pi / 1.);
    gl_Position.xy *= aspect;
    gl_Position.z = (gl_Position.z) * 0.1 + abs(gl_Position.x) * 1. / aspect.y + vert_z * 0.1 + 10.*(1. - val.z) + (1. - ecolf);
    gl_Position.w = 1.;
    gl_PointSize = 3.;

    v_color = col;
    v_color.a = 0.;
}

bool isNan(float val) {
    return (val <= 0.0 || 0.0 <= val) ? false : true;
}
bool isInf(float val) {
    return (val + 1. != val) ? false : true;
}

float get_xt(float xpi, float px) {
    return xpi * px;
}

float get_x(float xpi, float px) {
    const float pi = 3.1415926;
    return -pi * xpi + xpi * 2. * pi * px;
}

//return [x,y]-positions [z,w] color fix
vec4 get_func(int fid, float x) {
    const float pi = 3.1415926;
    float ret = 0.;
    float rety = ((x - 0.5) * 4.) * (1. / 0.2);
    float cpw = 0.15;
    float t = 0.;
    const float maxh = 15.;
    if (fid == 0) {t = get_x(1., x);ret = tan(t);} else
    if (fid == 1) {t = get_x(1., x);ret = t * t * t;} else
    if (fid == 2) {t = get_x(2., x);ret = (6. * sin(t)) / 2.;} else
    if (fid == 3) {t = get_x(1., x);ret = 1. / tan(t);} else
    if (fid == 4) {t = get_x(2., x);ret = abs(t) * sin(t);} else
    if (fid == 5) {t = get_x(2., x);ret = t / (t * t);} else
    if (fid == 6) {t = get_x(2., x);ret = -t * sin(t);} else
    if (fid == 7) {cpw = 0.05;t = get_xt(1., rety);rety = 2.5 * (2. * cos(t) + cos(2. * t));ret = 2.5 * (2. * sin(t) - sin(2. * t));} else
    if (fid == 8) {cpw = 0.05;t = get_xt(1., rety);rety = 1.5 * (4. * (cos(t) + cos(5. * t) / 5.));ret = 1.5 * (4. * (sin(t) - sin(5. * t) / 5.));} else
    if (fid == 9) {cpw = 0.075;t = get_xt(1., rety);rety = 1.5 * (3. * (1. + cos(t)) * cos(t));ret = 1.5 * (3. * (1. + cos(t)) * sin(t));} else
    if (fid == 10) {cpw = 0.05;t = get_xt(1., rety);rety = 2.5 * (3. * sin(t + pi / 2.));ret = 2.5 * (3. * sin(2. * t));} else
    if (fid == 11) {cpw = 0.075;t = get_xt(1., rety);rety = 2.5 * ((16. * pow(sin(t), 3.)) / 4.);ret = 2.5 * ((13. * cos(t) - 5. * cos(2. * t) - 2. * cos(3. * t) - cos(4. * t)) / 4.);} else
    if (fid == 12) {t = get_x(1., x);rety = 1.5 * (5. * sin(t));ret = 1.5 * (5. * cos(t));} else
    if (fid == 13) {cpw = 0.1;t = get_x(1., x);rety = 2.5 * (3. * cos(t) * (1. - 2. * pow(sin(t), 2.)));ret = 2.5 * (3. * sin(t) * (1. - 2. * pow(cos(t), 2.)));} else
    {t = get_x(1., x);ret = sin(t * 3.);}
    float cfix = 1.;
    if (isInf(ret)) {ret = maxh;cfix = 0.;} else {
        if (isNan(ret)) {ret = 0.;cfix = 0.;} else {
        if (abs(ret) > maxh) {ret = maxh * sign(ret);cfix = 0.;}
        }
    }
    if (isInf(rety)) {rety = maxh;cfix = 0.;} else {
        if (isNan(rety)) {rety = 0.001;cfix = 0.;} else {
        if (abs(rety) > maxh) {rety = maxh * sign(rety);cfix = 0.;} else {
        if (rety == 0.) rety = 0.001;
        }
        }
    }

    return vec4(ret, rety, cfix, cpw);
}

//return axis
vec3 findaxis() {
    vec3 rotate = vec3(0.);
    const vec4 static_timers1 = vec4(2.33333, 4.7, 7.05, 9.41666);
    const vec4 static_timers2 = vec4(11.76666, 14.11666, 16.4666, 18.8166);
    const vec4 static_timers3 = vec4(21.16666, 23.51666, 25.866, 27.05);

    float time_l = mod(time * speed, static_timers3[3] + .05);

    rotate.x = smoothstep(static_timers1[0], static_timers1[1], time_l) *
        (1. - smoothstep(static_timers1[1], static_timers1[2], time_l));
    rotate.x += -smoothstep(static_timers1[2], static_timers1[3], time_l) *
        (1. - smoothstep(static_timers2[1], static_timers2[2], time_l));
    rotate.x += smoothstep(static_timers2[2], static_timers2[3], time_l) *
        (1. - smoothstep(static_timers3[1], static_timers3[2], time_l));

    rotate.y = smoothstep(0., static_timers1[0], time_l) *
        (1. - smoothstep(static_timers1[0], static_timers1[1], time_l));
    rotate.y += -smoothstep(static_timers1[2], static_timers1[3], time_l) *
        (1. - smoothstep(static_timers1[3], static_timers2[0], time_l));
    rotate.y += smoothstep(static_timers2[0], static_timers2[1], time_l) *
        (1. - smoothstep(static_timers2[1], static_timers2[2], time_l));
    rotate.y += -smoothstep(static_timers2[2], static_timers2[3], time_l) *
        (1. - smoothstep(static_timers2[3], static_timers3[0], time_l));
    rotate.y += smoothstep(static_timers3[0], static_timers3[1], time_l) *
        (1. - smoothstep(static_timers3[1], static_timers3[2], time_l));

    rotate.z = smoothstep(static_timers1[1], static_timers1[2], time_l) *
        (1. - smoothstep(static_timers1[2], static_timers1[3], time_l));
    rotate.z += -smoothstep(static_timers1[3], static_timers2[0], time_l) *
        (1. - smoothstep(static_timers2[0], static_timers2[1], time_l));
    rotate.z += smoothstep(static_timers2[1], static_timers2[2], time_l) *
        (1. - smoothstep(static_timers2[2], static_timers2[3], time_l));
    rotate.z += -smoothstep(static_timers2[3], static_timers3[0], time_l) *
        (1. - smoothstep(static_timers3[0], static_timers3[1], time_l));
    rotate.z += smoothstep(static_timers3[1], static_timers3[2], time_l) *
        (1. - smoothstep(static_timers3[2], static_timers3[3], time_l));

    return rotate;
}

vec3 get_color(vec3 rotate) {
    return abs(rotate * 7.) / 14.0;
}

vec3 my_normalize(vec3 v) {
    float len = length(v);
    if (len == 0.0) return vec3(0., 1., 0.);
    return v / len;
}

mat4 rotationAxisAngle(vec3 v, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    float ic = 1.0 - c;

    return mat4(vec4(v.x * v.x * ic + c, v.y * v.x * ic - s * v.z, v.z * v.x * ic + s * v.y, 0.0),
        vec4(v.x * v.y * ic + s * v.z, v.y * v.y * ic + c, v.z * v.y * ic - s * v.x, 0.0),
        vec4(v.x * v.z * ic - s * v.y, v.y * v.z * ic + s * v.x, v.z * v.z * ic + c, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0));
}

vec3 encodeSRGB(vec3 linearRGB) {
    vec3 a = 12.92 * linearRGB;
    vec3 b = 1.055 * pow(linearRGB, vec3(1.0 / 2.4)) - 0.055;
    vec3 c = step(vec3(0.0031308), linearRGB);
    return mix(a, b, c);
}
