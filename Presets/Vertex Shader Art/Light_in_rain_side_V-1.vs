/*{
  "DESCRIPTION": "Light in rain : side V - test",
  "CREDIT": "xingchen0085 (ported from https://www.vertexshaderart.com/art/rSBQxzNrXNNi9dKme)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 80000,
  "PRIMITIVE_MODE": "TRIANGLES",
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
      "$date": 1630837025673
    }
  }
}*/

float rand(vec2 co) {
    return fract(sin(dot(co,vec2(95.92921,392.492))) * 93683.2319);
}

float noise(vec2 r) {
 vec2 p = floor(r);
    vec2 f = fract(r);
    f = smoothstep(0.,1.,f);
    vec2 e = vec2(0,1);
    float p00 = rand(p+e.xx);
    float p01 = rand(p+e.xy);
    float p10 = rand(p+e.yx);
    float p11 = rand(p+e.yy);
 return mix(
        mix(p00,p01,f.y),
        mix(p10,p11,f.y),
    f.x) - 0.5;
}

float ot(vec2 r) {
 float v = noise(r) + noise(r*2.*mat2(1,-2,2,1)/sqrt(5.))/2. + noise(r*4.*mat2(-3,5,-5,-3)/sqrt(34.))/4.;
    return v * 0.5 + 0.5;
}

void shift(inout vec3 p) {
 p.y += pow(ot(p.xz),1.2)*0.5;
}

void main() {
  vec3 pos, color;
  float alpha = 1.0;
  vec2 div;
  int i = int(mod(vertexId,6.));
  if(i==0) {
    div = vec2(-1,-1);
  } else if(i==1) {
    div = vec2(-1,1);
  } else if(i==2) {
    div = vec2(1,-1);
  } else if(i==3) {
    div = vec2(1,-1);
  } else if(i==4) {
    div = vec2(-1,1);
  } else if(i==5) {
    div = vec2(1,1);
  }
  if(vertexId < 6.) {
    pos = vec3(0,0,100.);
    pos.xy += div * 1000.;
    color = vec3(0.03);
  } else if(vertexId < 12.) {
    pos = vec3(0,0.2,0);
    pos.xz += div * 100.;
    color = vec3(0,0,0.2);
  } else if(vertexId < 4812.) {
    float vid = vertexId-6.;
    float unitIx = floor(vid/6.);
    vec2 p = vec2(mod(unitIx,40.), floor(unitIx/40.));
    p.x -= 20.5;
    p *= 0.5;
    vec2 origP = p;

    p += div * 0.25;
 pos = vec3(p.x,0,p.y);
    shift(pos);

    color = vec3(0.1,0.1,0.3);
    color *= noise(pos.xz) * 0.5 + 0.5;

    vec3 u = pos - vec3(1,1.5,1);
    u.xy *= mat2(2,-1,1,2)/sqrt(5.);
    float ll = length(u.xz) - abs(u.y*0.2);

    color = mix(vec3(1,0.8,0.4),color,smoothstep(0.5,0.0,1. - ll));
 } else if(vertexId < 15000.) {
    float vid = vertexId-4812.;
    float unitIx = floor(vid/6.);
    float per = time*3. + rand(vec2(unitIx,3));
    float seed = (unitIx + floor(per)*sqrt(2.)) * .2;
    float th = rand(vec2(seed,0))*3.1415926535*2.;
    th += rand(vec2(seed,1));
    float rad = rand(vec2(seed,2))*10. + 0.2;
    pos = vec3(cos(th),0,sin(th)) * rad;
    float ww = rand(vec2(seed,400))*0.02;
    float ww2 = rand(vec2(seed,6))*0.5;
    vec2 ddiv = mat2(1.,1.,-1.,1.)/sqrt(2.)*div;
    pos.xy += ddiv * vec2(0.02+ww,0.5*fract(per)+ww2);
    pos.y += 3.0;
    pos.z -= 1.0;
    pos.y -= (pow(fract(per),2.)+1.)*rad - rad;
   color = mix(vec3(0.3,0.4,1.0), vec3(1.), rand(vec2(seed,5)));
    color *= pow(rand(vec2(seed,6)),4.)*0.9+0.1;
  } else {
    float vid = vertexId-4812.;
    float unitIx = floor(vid/6.);
    float v = rand(vec2(unitIx,9.))*2.-1.;
    float per = time * 0.02 * v;
    float au = time*0.05 + rand(vec2(unitIx,10.));
    pos = vec3(
      fract(rand(vec2(unitIx,1.)) + per) * 10. - 5.,
      rand(vec2(unitIx,2.)) * 2.,
      rand(vec2(unitIx,3.)) * 2. - 1.
    );
    pos.x += sin(au*3.1415926535*2.)*0.1;
    pos.y += sin(au*0.9*3.1415926535*2.)*0.1;
    pos.z += sin(au*1.1*3.1415926535*2.)*0.1;
    vec3 ddiv = vec3(div,0.);
    float ra = time*(1. + rand(vec2(unitIx,8.)));
    ddiv.xy *= mat2(cos(ra),-sin(ra),sin(ra),cos(ra));
    ra *= 2.;
    ddiv.yz *= mat2(cos(ra),-sin(ra),sin(ra),cos(ra));
    float size = rand(vec2(unitIx,5.))+0.5;
    pos += ddiv*0.01*size;

    vec3 u = pos - vec3(1,1.8,1);
    u.xy *= mat2(2,-1,1,2)/sqrt(5.);
    float ll = length(u.xz) - u.y*0.05;

    color = mix(vec3(1,0.8,0.4),vec3(0.0),smoothstep(0.5,0.9,ll));
   alpha = 0.;
  }
  vec3 cam = vec3(0.,1.,0.);
  pos -= cam;
  pos.yz *= mat2(5,-1,1,5)/sqrt(26.);

  float near = 0.001;
  float far = 1000.;
  float fovy = 3.1415926535 * 0.4;
  float aspect = resolution.x / resolution.y;
  float f = 1. / tan(fovy / 2.);
  mat4 P = mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0,0,-2./(far-near),1,
    0,0,-(far+near)/(far-near),1
    // 0, 0, (far + near) / (near - far), (2. * far * near) / (near - far),
    // 0, 0, -1, 0
  );
  gl_Position = P * vec4(pos,1.);
  v_color = vec4(color,alpha);
}