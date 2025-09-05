/*{
  "DESCRIPTION": "circulitoTriangleStrip",
  "CREDIT": "vanoog (ported from https://www.vertexshaderart.com/art/pGvDuYEiAcZ95p7Cw)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 17300,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1552528097188
    }
  }
}*/

vec2 circle(float circleId,float grid,float distance){
 float y = mod(vertexId,2.0);
 float x = floor(vertexId/2.0);
 float angle = x / 20.0 * radians(360.0);

    float r = 2.0 - y;

    x = r*cos(angle);
 y = r*sin(angle);

   x += 0.0+mod(circleId,grid)*distance;
   y += 0.0+floor(circleId/grid)*distance;

   float u = x/grid*3.0;// / (grid);
   float v = y/grid*3.0;// / (grid);

    vec2 xy = vec2(u, v) * 0.2;
    return xy;
}

void main(){
   float vertexPerCircle = 126.0;
   float circleId = floor(vertexId/vertexPerCircle);
   float grid = 9.0;
   float distance = 4.5;

    vec2 xy = circle(circleId,grid,distance);

    gl_Position = vec4(xy.x-1.0,xy.y-1.0, 0.0, 1.0);
    v_color = vec4(sin(time*xy.x), cos(time*xy.y), cos(xy.x*xy.y), 1.0);

    gl_PointSize = 10.0;
}