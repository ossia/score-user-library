/*{
  "DESCRIPTION": "husleri - remember to reset time!",
  "CREDIT": "atomim (ported from https://www.vertexshaderart.com/art/WZ4EToBv8LTc3N3Tn)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 4311,
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
    "ORIGINAL_VIEWS": 214,
    "ORIGINAL_DATE": {
      "$date": 1454951999858
    }
  }
}*/



vec3 getPosition(float t){
  float p_time=time*1.+97.;
  float t2=t*20.;
  t2+=0.01*sin(p_time)+(p_time-110.)*3.;//speed
  float dist=20.+sin(t2*1.3)*5.;
  return vec3(sin(t2+(1.-t)*2.+sin(t2*2.)*0.6)*dist,0.,cos(t2+(1.-t)*2.+sin(t2*2.)*0.7)*dist)*(1.2-t*t)*1.2//around
        + vec3(0.,t2*2.+cos(t2)*15.+cos(t2*3.5)*5.,0.)-vec3(0.,(1.-t*t*t)*10.,0.)//forward
        + vec3(sin(t2*2.3),sin(t2*1.32)+(t+1.)*(t-1.)*2.,sin(t2*3.6754))*(1.-t)*15.//tail movement

 ;
}

vec3 getDiff(float t){
 return getPosition(t)-getPosition(t+0.21);
}

void main() {
  float point = vertexId;
  float pos = float(vertexId+mod(vertexId,2.)) / vertexCount;
  float side = mod(vertexId,2.);

  vec3 nor=vec3(0.);
  for(int i=0;i<15;i++){
    vec3 tmp=normalize(cross(normalize(getDiff(pos+0.1 *float(i))),normalize(getDiff(pos+0.1*(float(i)+1.)))));
    if(!(tmp!=tmp))nor+=tmp;
  }

  vec3 pos2=getPosition(pos)+normalize(nor)*side*3.;

  vec3 xyz=pos2*0.02;

  gl_Position = vec4(xyz * 0.5, 1);

  v_color = min(vec4(2.),vec4(xyz.x,xyz.y,2,1))/max(0.,(-xyz.z*5.+5.));
}