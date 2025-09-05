/*{
  "DESCRIPTION": "circle_grid",
  "CREDIT": "sergioerick (ported from https://www.vertexshaderart.com/art/A5wHpLQiQydYkB7sg)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 6000,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1552842877347
    }
  }
}*/

void main(){
 float width = 10.0;
 float circumPoints = 60.0;

 float gridId = floor(vertexId/(circumPoints));

 float xGrid = mod(gridId, width);
 float yGrid = floor(gridId / width);

 float uGrid = xGrid / (width - 1.0);
 float vGrid = yGrid / (width - 1.0);

 float circleId = mod(vertexId, circumPoints);

 float xCircle = floor(circleId/ 2.0);
 float yCircle = mod(circleId + 1.0, 2.0);

 float angle = xCircle / ((circumPoints-2.0)/2.0) * radians(360.0);
 float radius = 2.0 - yCircle;

 float uCircle = radius * cos(angle);
 float vCircle = radius * sin(angle);

 float xOffset = cos(time + yGrid * 0.2) * 0.1;
 float yOffset = cos(time + xGrid * 0.3) * 0.2;

 float ux = uGrid * 2.0 - 1.0 + xOffset + uCircle*0.05;
 float vy = vGrid * 2.0 - 1.0 + yOffset + vCircle*0.05;

 vec2 xy = vec2(ux, vy) * 0.8;

 gl_Position = vec4(xy, 0.0, 1.0);
 gl_PointSize = 5.0;
 v_color = vec4(1.0,0.0,0.0,1.0);
}