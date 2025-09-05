/*{
  "DESCRIPTION": "Fireworks",
  "CREDIT": "aaron1924 (ported from https://www.vertexshaderart.com/art/omsdK8ycyfF9ofeYS)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Nature"
  ],
  "POINT_COUNT": 10000,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1535281784985
    }
  }
}*/

#define TAU 6.28318530718

vec3 hash(vec3 p)
{
    p = fract(p * vec3(.1031,.11369,.13787));
    p += dot(p, p.yxz+19.19);
    return fract(vec3((p.x + p.y)*p.z, (p.x+p.z)*p.y, (p.y+p.z)*p.x));
}

vec2 solve( float a, float b, float c )
{
  float d = sqrt( b * b - 4.0 * a * c );
  vec2 dV = vec2( d, -d );
  return (-b + dV) / (2.0 * a);
}

vec3 throw( vec3 pos, vec3 vel, float h, float t )
{
      vec3 g = vec3(0, -4., 0);

      for( int iBounce=0; iBounce < 3; iBounce++)
    {
      vec2 q = solve( 0.5 * g.y, vel.y, -h + pos.y);
      float tInt = max( q.x, q.y );
      tInt -= 0.0001;

      if ( t < tInt )
      {
        pos += vel*t + 0.5*g*t*t;
        break;
      }
      else
      {
        vec3 v = vel + g * tInt;
        pos += vel * tInt + 0.5 * g * tInt * tInt;
        vel = v;

        vel.y = -vel.y * 0.3;
        vel.xz *= 0.6;

        t -= tInt;
      }
    }

      return pos;
}

float box(vec3 p)
{
  p = abs(p);
  return max(p.x, max(p.y, p.z));
}

mat2 rot(float a)
{
  float s=sin(a), c=cos(a);
  return mat2(c,s,-s,c);
}

vec3 fountain(float id, float count)
{
  vec3 d = normalize(hash(vec3(id))-0.5);
  d.y=abs(d.y);

  float t=fract(0.3*time + id/count);
  vec3 p=d*t;
  p.y = max(-8. * t * (t-.9), 0.1*sin(t));

  return p;
}

/*vec3 boom(float id, float count, float t)
{
  vec3 d = hash(vec3(id))-0.5;
  d *= (1.0 + id/count) / length(d);

  vec3 p=d*pow(t, 0.6);

  return p;
}*/

vec3 boom(float id, float count, vec3 pos, float t)
{
  vec3 d = hash(vec3(id))-0.5;
  d *= (1.0 + id/count) / length(d);

  return throw(pos, d, -1.0, t);
}

vec3 spiral(float id, float count)
{
  vec3 rnd = hash(vec3(id)) - 0.5;

  float t = time + id/count;

  float a = 2. * t + rnd.x;
  if(2.*id > count)a += 0.5*TAU;

  vec3 td = (2. + rnd.z) * vec3(sin(a), 0.1 * rnd.y, cos(a));
  vec3 to = vec3(0,1,0);

  return throw(to, td, -2.0, fract(t+a));
}

void main() {
  vec3 p = vec3(0);

  float md = 32.0;
  float gr = floor(md*vertexId/vertexCount+md*time);

  float t = time;
  p = 2. * hash(vec3(gr)) - 1.; p.xz *= vec2(5, 3); p.y += 2.;
  p = boom(vertexId, vertexCount, p, fract(t - gr/md));

  //p.z -= 3. * fract(t - gr/md);

  p.z += 4.;

  vec2 uv = p.xy / p.z;
  uv.x *= resolution.y / resolution.x;

  gl_PointSize = 4. / p.z;
  gl_Position = vec4(uv, 0, 1);

  vec3 col = hash(vec3(3.*gr));
  col /= box(col);

  v_color = vec4(col, 1);
}