/*{
  "DESCRIPTION": "surface",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/esyFcPb5cskLWGgGE)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.10196078431372549,
    0.10196078431372549,
    0.10196078431372549,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 53,
    "ORIGINAL_DATE": {
      "$date": 1611666123081
    }
  }
}*/

/* ---------------------------- SURFACE --------------------------//
Special gifts for everyone who loves 2d games and sprite creation.*/

vec3 surface(){
  float x, y, w, h;//x,y coordinates and w,h width and height of a surface.
  float width = 0.2;
  float height = 0.4;
  x = mouse.x-(width/2.);//move the surface from the center of widith.
  y = mouse.y-(height/2.);//move the surface from the center of height.
  w = width+x;
  h = height+y;

  vec3 v[4];
  v[0] = vec3(x, y, 0.);
  v[1] = vec3(x, h, 0.);
  v[2] = vec3(w, y, 0.);
  v[3] = vec3(w, h, 0.);

  int vid = int(vertexId);
  for(int i=0; i<3; i++){
    if(vid == i){
      return v[i];
    }
  }
  return v[3];
}

void main(){
  gl_Position = vec4(surface(), 1);
  gl_PointSize = 10.;
  v_color = vec4(0, 1, 1, 1);
}