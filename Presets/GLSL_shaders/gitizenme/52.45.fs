/*{
    "CATEGORIES": [
        "Cloud",
        "Fractal",
        "Audioreactive"
    ],
    "DESCRIPTION": "52.45, inspired by  https://www.shadertoy.com/view/NsySD3 by xjorma",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": [
                0,
                0
            ],
            "LABEL": "pos",
            "MAX": [
                100,
                100
            ],
            "MIN": [
                -100,
                -1000
            ],
            "NAME": "pos",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0.13333333333333333,
                0.13333333333333333,
                0.13333333333333333,
                1
            ],
            "LABEL": "Accent Color",
            "NAME": "AccColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": 50,
            "LABEL": "Scale",
            "MAX": 100,
            "MIN": 30,
            "NAME": "scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0.19,
                0.13,
                0.11,
                1
            ],
            "LABEL": "rotation",
            "MAX": [
                1,
                1,
                1,
                1
            ],
            "MIN": [
                0,
                0,
                0,
                1
            ],
            "NAME": "rotation",
            "TYPE": "color"
        }
    ],
    "ISFVSN": "2"
}
*/



// float scale = 50.;



mat2 rot(float a)
{
  float s = sin(a), c = cos(a);
  return mat2(c,-s,s,c);
}

float torus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sphere( vec3 p, float s )
{
  return length(p)-s;
}

float cube(vec3 p, float s)
{
  vec3 a = abs(p) - s;
  return max(a.x, max(a.y, a.z));
}

mat2 mx, my, mz;

float fold(vec3 p)
{
  p *= scale;
  int iter = 13;
  for (int i=0; i < iter; i++)
  {
    p.xy *= mz;
    p.yz *= mx;
    p.xz *= my;
    p = abs(p) - float(iter - i);    
  }
  // float c = cube(p, 1.);
  // float s = sphere(p, 1.);
  float t1 = torus(p + sin(TIME * 5.) - cos(TIME * 5.), vec2(2, 5));
  float t2 = torus(p + sin(TIME * 5.) - cos(TIME * 2.5), vec2(5, 2));
  float t3 = torus(p + sin(TIME * 2.5) - cos(TIME * 5.), vec2(5, 5));
  float d = min(t1, t2);
  d = min(d, t3);
  return d / scale;
}

float map(vec3 p)
{
   return fold(p);
}



float rayCastShadow(in vec3 ro, in vec3 rd)
{
   vec3 p = ro;
   float acc = 0.0;
   float dist = 0.0;

   for (int i = 0; i < 32; i++)
   {
	  if((dist > 6.) || (acc > .75))
		   break;

      float sdf = map(p);
      
      const float h = .05;
      float ld = max(h - sdf, 0.0);
      float w = (1. - acc) * ld;   
     
      acc += w;
             
      sdf = max(sdf, 0.05);
      p += sdf * rd;
      dist += sdf;
   }  
   return max((0.75 - acc), 0.0) / 0.75 + 0.02;
}



vec3 Render(in vec3 ro, in vec3 rd)
{
   vec3 p = ro;
   float acc = 0.;
   
   vec3 accColor = vec3(AccColor);
   
   float dist = 0.0;

   for (int i = 0; i < 64; i++)
   {
      if((dist > 10.) || (acc > .95))
          break;

      float sdf = map(p) * 0.80;
      
      const float h = .05;
      float ld = max(h - sdf, 0.0);
      float w = (1. - acc) * ld;   
      
      accColor += w * rayCastShadow(p, normalize(vec3(0.75,1,-0.10))); 
      acc += w;
        
      sdf = max(sdf, 0.03);
      
      p += sdf * rd;
      dist += sdf;
   }  
    
   return accColor;
}

mat3 setCamera( in vec3 ro, in vec3 ta )
{
	vec3 cw = normalize(ta-ro);
	vec3 up = vec3(0, 1, 0);
	vec3 cu = normalize( cross(cw,up) );
	vec3 cv = normalize( cross(cu,cw) );
  return mat3( cu, cv, cw );
}

void main() {

  mx = rot(TIME * rotation.x);
  my = rot(TIME * rotation.y);
  mz = rot(TIME * rotation.z);

	vec3 tot = vec3(0.0);
        
  // pixel coordinates
  vec2 p = (-RENDERSIZE.xy + 2.0*gl_FragCoord.xy)/RENDERSIZE.y;

  // camera       
  float theta	= radians(360.)*(pos.x/RENDERSIZE.x-0.5);
  float phi	= radians(90.)*(pos.y/RENDERSIZE.y-0.5)-1.;
  vec3 ro = 6. * vec3( sin(phi)*cos(theta),cos(phi),sin(phi)*sin(theta));
  vec3 ta = vec3( 0 );

  // camera-to-world transformation
  mat3 ca = setCamera(  ro, ta );

  vec3 rd =  ca * normalize(vec3(p, 1.5));        

  vec3 col = Render(ro ,rd);

  vec3 colB = AccColor.rgb;
	vec2 vUV = isf_FragNormCoord;
	vUV *=  1.0 - vUV.yx;
	float vig = vUV.x * vUV.y * 100.0; // multiply with sth for intensity
	vig = pow(vig, 0.35); // change pow for modifying the extend of the  vignette
	colB *= vig;
    
  tot = mix(col, colB, 0.5);
  
  // tot += col;         

	gl_FragColor = vec4( sqrt(tot), 1.0 );
}
