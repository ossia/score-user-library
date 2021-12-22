/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [
    {
      "NAME" : "mouse",
      "TYPE" : "point2D",
      "MAX" : [
        1,
        1
      ],
      "MIN" : [
        0,
        0
      ]
    }
  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#3858.5"
}
*/


#ifdef GL_ES
precision mediump float;
#endif

// Fake bokeh shaded cube by Kabuto
// Theory: works.
// Practice: slow and has bugs... as usual.

// mouse: change focal plane


const float PI = 3.141592653589;

float cap(vec2 a, vec2 b) {
	vec2 abd = vec2(a.x*b.x+a.y*b.y, a.y*b.x-a.x*b.y);
	float y_x = abd.y/(abd.x-1.);
	
	return atan(-y_x)-y_x/(1.+y_x*y_x)+PI/2.;
}

float cap1(float p) {
	p = max(min(p,1.),-1.);
	return asin(p)+p*sqrt(1.-p*p)+PI/2.;
}

float ebok(vec2 p, vec2 a, vec2 b) {
	vec2 an = vec2(a.y,-a.x);
	vec2 bn = vec2(b.y,-b.x);
	
	float surface;
	if (dot(p,p) < .99) {
		float pa = dot(p,a);
		float ra = -pa+sqrt(pa*pa-dot(p,p)+1.);
		vec2 pac = ra*a;
		
		float pb = dot(p,b);
		float rb = -pb+sqrt(pb*pb-dot(p,p)+1.);
		vec2 pbc = rb*b;
		
		surface = cap(p+pac,p+pbc)+(pac.x*pbc.y-pac.y*pbc.x)*.5;
	} else {
		float d1 = dot(an,p);
		float d2 = -dot(bn,p);
		float sda = step(dot(p,a),0.);
		float sdb = step(dot(p,b),0.);
		surface = PI*(sda+sdb-sda*sdb) - cap1(-d1)*sda - cap1(-d2)*sdb;
		
	}
	return surface;
}

float handleCorner(vec2 p, vec2 a, vec2 b, vec2 c) {
	vec2 ba = normalize(a-b);
	vec2 bc = normalize(c-b);
	float h = dot(a-p,vec2(ba.y,-ba.x));
	return ebok(p-b, bc, ba) - cap1(h);
}

float bokehtria(vec2 p, vec2 a, vec2 b, vec2 c) {
	vec2 mi = min(min(a,b),c)-1.;
	vec2 ma = max(max(a,b),c)+1.;
	return (a.x-b.x)*(a.y-c.y)<(a.y-b.y)*(a.x-c.x)||p.x<mi.x||p.y<mi.y||p.x>ma.x||p.y>ma.y ? 0. :  handleCorner(p,a,b,c) + handleCorner(p,b,c,a) + handleCorner(p,c,a,b) + PI;
}

float bokehsquare(vec2 p, vec2 a, vec2 b, vec2 c, vec2 d, float scale) {
	//return bokehtria(p*scale,a*scale,b*scale,c*scale) + bokehtria(p*scale,c*scale,d*scale,a*scale);
	p *= scale; a *= scale; b *= scale; c *= scale; d *= scale;
	vec2 mi = min(min(a,b),min(c,d))-1.;
	vec2 ma = max(max(a,b),max(c,d))+1.;
	return (a.x-b.x)*(a.y-c.y)<(a.y-b.y)*(a.x-c.x)||p.x<mi.x||p.y<mi.y||p.x>ma.x||p.y>ma.y ? 0. :  handleCorner(p,a,b,c) + handleCorner(p,b,c,d) + handleCorner(p,c,d,a) + handleCorner(p,d,a,b) + PI;
}

vec2 project(vec3 v) {
	return v.xy/(v.z+14.);
}

vec4 shade(vec3 v, float f) {
	float highlight = pow(f*.5+.5,100.);
	return vec4(pow(f*.5+.5,10.)*v*1.5*(1.-highlight)+highlight,1.)/PI;
}

void main( void ) {
	float rx = TIME;// + mouse.x*8.;
	//float ry = mouse.y*4.;
	mat3 matx = mat3(cos(rx),0,sin(rx),0,1,0,-sin(rx),0,cos(rx));
	//mat3 maty = mat3(1,0,0,0,cos(ry),-sin(ry),0,sin(ry),cos(ry));
	mat3 mat = matx;//*maty;
	

	mat3 rot = mat3(1,0,0,0,.8,.6,0,-.6,.8)*mat3(.96,.28,0,-.28,.96,0,0,0,1);
	
//	float scale = exp(sin(TIME*.5)*2.5+3.5);

	vec2 p = ( gl_FragCoord.xy - RENDERSIZE*.5 ) / RENDERSIZE.x ;
	
	vec3 color = vec3(0,.2,.7);
	
	for (float z = -1.; z <= 1.; z++) {
		for (float x = -1.; x <= 1.; x++) {
			vec3 q = vec3(x*3.5+z,sin(x*2.+z*2.+TIME),z*-3.5+x);
			
			float scale = 1./(1./(q.z+14.) - 1./(mouse.y*9.-4.5+14.1));
				
			vec2 a = project(vec3(-1.,1.,-1)*mat+q);
			vec2 b = project(vec3(1.,1.,-1.)*mat+q);
			vec2 c = project(vec3(-1.,1.,1.)*mat+q);
			vec2 d = project(vec3(1.,1.,1.)*mat+q);
			vec2 e = project(vec3(-1.,-1.,-1.)*mat+q);
			vec2 f = project(vec3(1.,-1.,-1.)*mat+q);
			vec2 g = project(vec3(-1.,-1.,1.)*mat+q);
			vec2 h = project(vec3(1.,-1.,1.)*mat+q);
			
			vec4 color1 = 
				  (dot(vec3(mat[0][1],mat[1][1],mat[2][1]),q+vec3(0,0,14.)) < 0. ? bokehsquare(p,a,b,d,c,scale)*shade(vec3(.7,.5,.5),-mat[2][1]) : bokehsquare(p,g,h,f,e,scale)*shade(vec3(.3,.5,.5),mat[2][1]))
				+ (dot(vec3(mat[0][2],mat[1][2],mat[2][2]),q+vec3(0,0,14.)) > 0. ? bokehsquare(p,b,a,e,f,scale)*shade(vec3(.5,.7,.5),mat[2][2]) : bokehsquare(p,h,g,c,d,scale)*shade(vec3(.5,.3,.5),-mat[2][2]))
				+ (dot(vec3(mat[0][0],mat[1][0],mat[2][0]),q+vec3(0,0,14.)) > 0. ? bokehsquare(p,a,c,g,e,scale)*shade(vec3(.5,.5,.7),mat[2][0]) : bokehsquare(p,f,h,d,b,scale)*shade(vec3(.5,.5,.3),-mat[2][0]));
			color = color1.xyz + color*(1.-color1.w);
			mat *= rot;
		}
	}

	

	gl_FragColor = vec4( vec3(sqrt(color)), 1.0 );

}