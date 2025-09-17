/*{
  "DESCRIPTION": "Hello wobbly triangle",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/ofYQfSm7FHtddg7on)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 2590,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.8784313725490196,
    0.9333333333333333,
    0.8313725490196079,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 88,
    "ORIGINAL_DATE": {
      "$date": 1590411162876
    }
  }
}*/


const float line = 3. ;
vec2 drawTriangle(in float vertexId ,out vec3 color )
{
  vec2 res = vec2(1.);
 // res.x = floor(mod(vertexId , line))/line;
 // res.y = floor(vertexId/ line) ;
  if(vertexId < (vertexCount / 4. ))
  {
    res.x = -0.5 ;
    res.y = -0.5 ;
    color.r = 1.;
    color.g = 0. ;
    color.b = 0. ;
    res.x += (sin(-time * 3.0) * 0.1);
    res.y += (cos(-time * 10.0) * 0.1);
  }
  else if (vertexId > (vertexCount * 2. /3. ))
  {
    res.x = 0.5 ;
    res.y = -0.5 ;
    color.r = 0.;
    color.g = 1. ;
    color.b = 0. ;
    res.x += (sin(-time * 10.0) * 0.1);
    res.y += (cos(time * 7.0) * 0.1);
  }
  else
  {
    res.x = 0. ;
    res.y = 0.5 ;
    color.r = 0.;
    color.g = 0. ;
    color.b = 1. ;
    res.x += (sin(time * 5.0) * 0.1);
    res.y += (cos(time * 11.0) * 0.1);
  }
  return res;

}

void main()
{
  vec3 color = vec3(0.);

  gl_Position = vec4(drawTriangle(vertexId ,color) , 0.0 ,1.) ;

  gl_PointSize = 10. ;

  v_color = vec4(color , 1.0);
}