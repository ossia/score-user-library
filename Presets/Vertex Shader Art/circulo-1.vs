/*{
  "DESCRIPTION": "circulo",
  "CREDIT": "polacienta (ported from https://www.vertexshaderart.com/art/WuRAKg77S8gD366A8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 42,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1551487082770
    }
  }
}*/

void main()
{
  float width=20.0;
  float total =20.0;

  //x= r cos
  //y= r*sin
  // a= x/total*2pi
  //radio = cuadrado

  float y=mod(vertexId+1.0,2.0);
  float x=floor(vertexId/2.0);

  float angle= (x/total)*radians(360.0);
  float radio= 2.0+y;

  float ux=radio*cos(angle);
  float uy= radio*sin(angle);

 //float u= x/(width-1.0);
  //float v= y/(width-1.0);

  //float xOffset= cos(time+y)*0.1;
  //float yOffset= sin(time+x*0.1);

  //float ux=u*2.0-1.0+xOffset;
  //float uy= v*2.0-1.0+yOffset;

  vec2 xy= vec2(ux,uy)*0.1;

  gl_Position= vec4(xy,0.0,1.0);
  v_color=vec4 (1.0,0.0,1.0,1.0);
  gl_PointSize=10.0;
}