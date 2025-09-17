/*{
  "DESCRIPTION": "sphere df sphere - sphere difference sphere approximation",
  "CREDIT": "morimea (ported from https://www.vertexshaderart.com/art/NYiqfuasX6PFoLoQr)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math"
  ],
  "POINT_COUNT": 3072,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 19,
    "ORIGINAL_DATE": {
      "$date": 1615908564541
    }
  }
}*/


// number of triangles == pow(2,X)*6
// pow(2,2)*6=24
// pow(2,14)*6=98304
// pow(2,9)*6=3072 ...etc
// pow(2,6)*6=384 ...etc

// comment for union
#define difference

float sdfDifference( const float a, const float b)
{
    return max(a, -b);
}

float sphereSDF(vec3 p, float r) {
    return length(p) - r;
}

const float pi = 3.1415926;
const float degree_to_rad = pi / 180.0;

vec3 phongContribForLight(vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye,
        vec3 lightPos, vec3 lightIntensity, vec3 N) {
    vec3 L = normalize(lightPos - p);
    vec3 V = normalize(eye - p);
    vec3 R = normalize(reflect(-L, N));

    float dotLN = dot(L, N);
    float dotRV = dot(R, V);

    if (dotLN < 0.0) {
        return vec3(0.0, 0.0, 0.0);
    }

    if (dotRV < 0.0) {
        return lightIntensity * (k_d * dotLN);
    }
    return lightIntensity * (k_d * dotLN + k_s * pow(dotRV, alpha));
}

vec3 phongIllumination(vec3 k_a, vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye, vec3 norm) {
    const vec3 ambientLight = 0.5 * vec3(1.0, 1.0, 1.0);
    vec3 color = ambientLight * k_a;

    vec3 light1Pos = normalize(vec3(mouse.x,mouse.y,.20))*5.;
    vec3 light1Intensity = 5.*vec3(0.4, 0.4, 0.4);

    color += phongContribForLight(k_d, k_s, alpha, p, eye,
        light1Pos,
        light1Intensity, norm);

    return color;
}

vec3 color_phong(vec3 p, vec3 ro, vec3 nor, vec3 col){
    vec3 K_a = col;
    vec3 K_d = K_a;
    vec3 K_s = vec3(1.0, 1.0, 1.0);
    float shininess = 12.0;

    col = phongIllumination(K_a, K_d, K_s, shininess, p, ro, nor);
    return col;
}

vec3 basic_light(vec3 nor){
   vec3 li = normalize(vec3(0.5, 1.0, 1.0));
    float dif = clamp(dot(nor, li), 0.0, 1.0);
    float amb = max(0.5 + 0.5 * nor.y, 0.0);
   vec3 col = vec3(0.88);
   return col*clamp(max(dif, 0.3) * amb, 0.0, 1.0);
}

mat3 rotx(float a){float s = sin(a);float c = cos(a);return mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, c, s), vec3(0.0, -s, c)); }
mat3 roty(float a){float s = sin(a);float c = cos(a);return mat3(vec3(c, 0.0, s), vec3(0.0, 1.0, 0.0), vec3(-s, 0.0, c));}
mat3 rotz(float a){float s = sin(a);float c = cos(a);return mat3(vec3(c, s, 0.0), vec3(-s, c, 0.0), vec3(0.0, 0.0, 1.0 ));}

mat4 rotXMatrix(float theta)
{
    float cs = cos(theta);
    float ss = sin(theta);

    mat4 result =
    mat4(vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, cs, -ss, 0.0),
        vec4(0.0, ss, cs, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0) );

    return result;
}

mat4 rotYMatrix(float theta)
{
    float cs = cos(theta);
    float ss = sin(theta);

    mat4 result =
    mat4(vec4(cs, 0.0, -ss, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(ss, 0.0, cs, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0) );

    return result;
}

mat4 perspectiveMatrix(float fovYInRad, float aspectRatio)
{
    float yScale = 1.0 / tan(fovYInRad / 2.0);
    float xScale = yScale / aspectRatio;
    float zf = 100.0;
    float zn = 0.3;

    float z1 = zf / (zf - zn);
    float z2 = -zn * zf / (zf - zn);

    mat4 result = mat4(xScale, 0.0, 0.0, 0.0, 0.0, yScale, 0.0, 0.0, 0.0, 0.0, -z1, -1., 0.0, 0.0, z2, 0.0);

    return result;
}

vec3 meshSqhere(in float id, in float split)
{
    float d = split * 2.0;
    float n = floor(id / 6.0);
    vec2 q = vec2(mod(n, d), mod(floor(n / d), d));
    vec2 a = q + 0.5 - split;
    float s = sign(a.x * a.y);
    float c = abs(3.0 - mod(id, 6.0));
    vec2 uv = vec2(mod(c, 2.0), abs(step(0.0, s) - floor(c / 2.0)));
    uv = floor(uv + q) / split - 1.0;
    if (uv.x > abs(uv.y))
        uv.y -= (uv.x - abs(uv.y)) * s;
    if (-uv.x > abs(uv.y))
        uv.y -= (uv.x + abs(uv.y)) * s;
    if (uv.y > abs(uv.x))
        uv.x -= (uv.y - abs(uv.x)) * s;
    if (-uv.y > abs(uv.x))
        uv.x -= (uv.y + abs(uv.x)) * s;
    return normalize(vec3(uv, 0.8 * (1.0 - pow(max(abs(uv.x), abs(uv.y)), 2.0)) * s));
}

float map(in vec3 p)
{
    return sphereSDF(p,1.);
}

vec3 calcNormal(in vec3 p)
{
    vec2 e = vec2(1.0, -1.0) * 0.002;
    return normalize(e.xyy * map(p + e.xyy) + e.yyx * map(p + e.yyx) + e.yxy * map(p + e.yxy) + e.xxx * map(p + e.xxx));
}

void main()
{
   vec4 sphere1 = vec4(0.,0.,0.,1.);
 vec4 sphere2 = vec4(0.,.5,0.,1.);

    mat4 pMatrix = perspectiveMatrix(45.0 * degree_to_rad, resolution.x / resolution.y);
    mat4 vMatrix = mat4(1.0);
    vMatrix[3].z += -3.5;
   vMatrix[3].xyz+=sphere1.xyz;

    float split = floor(sqrt(floor(vertexCount / 6.0)));
    split = floor(split / 2.0);
    vec3 p_smooth = meshSqhere(vertexId, split);
   vec3 p_flat = meshSqhere(floor(vertexId/3.)*3., split);

    vec3 nor_smooth = calcNormal(p_smooth);
   vec3 nor_flat = calcNormal(p_flat);
    //vec3 col = basic_light(nor_smooth);

   float d1=sphereSDF(p_smooth-sphere1.xyz,sphere1.w);
    float d2=sphereSDF(p_smooth-sphere2.xyz,sphere2.w);
   float d=sdfDifference(d1,d2);

  //sphere2
    mat4 pMatrix2 = perspectiveMatrix(45.0 * degree_to_rad, resolution.x / resolution.y);
    mat4 vMatrix2 = mat4(1.0);
    vMatrix2[3].z += -3.5;
   vMatrix2[3].xyz+=sphere2.xyz;
  #ifdef difference
    vMatrix2*=rotYMatrix(1.*pi);
  #endif

    float split2 = floor(sqrt(floor(vertexCount / 6.0)));
    split2 = floor(split2 / 2.0);
    vec3 p_smooth2 = meshSqhere(vertexId, split2)*rotx(0.5);
   vec3 p_flat2 = meshSqhere(floor(vertexId/3.)*3., split2)*rotx(0.5);
  #ifdef difference
    p_smooth2*=-1.;
    p_flat2*=-1.;
  #endif

    vec3 nor_smooth2 = calcNormal(p_smooth2);

  /*
    if(d>0.001){
      gl_Position = pMatrix2 * vMatrix2 * vec4(p_smooth2, 1.0);
      p_smooth=p_smooth2;
      p_flat=p_flat2;
      nor_smooth=nor_smooth2;
    }
    else {
      gl_Position = pMatrix * vMatrix * vec4(p_smooth, 1.0);
    }
  */

   gl_Position = pMatrix2 * vMatrix2 * vec4(p_smooth2, 1.0);
    gl_Position = min(gl_Position,pMatrix * vMatrix * vec4(p_smooth, 1.0));

   vec3 col=vec3(0.);
    if(gl_Position.x<-.15){
      vec3 nor = calcNormal(p_flat);
      col=color_phong(p_flat,vec3(0.,0.,10.), nor, (nor_flat+1.)/2.);
      col *= 0.65 + .35 * floor(mod(floor(vertexId / 3.), 2.));
    }else{
      vec3 nor = calcNormal(p_smooth);
      col=color_phong(p_smooth,vec3(0.,0.,10.), nor, (nor_smooth+1.)/2.);
    }

    v_color = vec4(col, 1.0);
}