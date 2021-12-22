/*
{
  "IMPORTED" : [

  ],
  "CATEGORIES" : [
    "2d",
    "escher",
    "short",
    "Automatically Converted",
    "Shadertoy"
  ],
  "DESCRIPTION" : "Automatically converted from https:\/\/www.shadertoy.com\/view\/ldyXWw by FabriceNeyret2.  reproducing https:\/\/twitter.com\/CPriestman\/status\/684874950944100352\/photo\/1",
  "INPUTS" : [

  ]
}
*/


// reproducing https://twitter.com/CPriestman/status/684874950944100352/photo/1

#define R(t) mat2(c=cos(t),s=sin(t),-s,c)                      // R(1.25) = tilted grid

float t, c,s, k=sqrt(10.); 
vec2 R, u;

vec4 C(vec2 U, float m) {
    U += m*vec2(1,2);                                   // white (m=0) or black (m=1) grid
    u = floor( R(1.25)*U/k +.5);                                           // tilted grid
    t = clamp( mod( TIME -u.y-.3*u.x+ 3.*m, 6.) -4., 0.,1.) *1.57;  // rotates ?
    if (m>0.) t=-t;                                                        // if black
    u = R(-1.25)*u*k;
    
  //U = floor(R(t)*(U-u)+.5);                                              // cross frame
  //return vec4((U.x==0.||U.y==0.)&&abs(U.x)<2.&&abs(U.y)<2.);             // cross shape
                                                       // antialiased version :
    U = abs( R(t)*(U-u) );                                                 // cross frame
    return vec4(smoothstep(.55, .45, max(min(U.x,U.y),max(U.x,U.y)-1.) )); // cross shape
}

void main() {

	vec4 fragCoordPos = gl_FragCoord;

    gl_FragColor -= gl_FragColor; R = RENDERSIZE.xy;
	fragCoordPos.xy =  15.* (fragCoordPos.xy-R/2.)/ R.y; 
    
    if (abs(fragCoordPos.x) < 7.5)  {
        fragCoordPos.xy += 3.;   gl_FragColor =    C(fragCoordPos.xy, 0.);                 // for white rotating wave
        if (t==0.) gl_FragColor = 1.-C(fragCoordPos.xy, 1.);                 // for black rotating wave
    }
}















// -------------- drafts ------------------ 


/** 

#define R(t) mat2(cos(t),sin(t),-sin(t),cos(t))    // R(-1.25) = tilted grid

{
    float t, T = TIME/1.5708, k=sqrt(10.), o = 0.; 
    vec2 R = RENDERSIZE.xy, u;
	U =  15.* (U-R/2.)/ R.y; 
    if (abs(U.x)>7.5) { O-=O; return; }
    U += 3.;

    u = floor(R(1.25)*U/k+.5);
    t = clamp(mod(T,8.)-4.-u.y-.3*u.x,0.,1.)*1.5708; 

    if (t==0.) { 
        o=1.;
        U += vec2(1,2);
        u = floor(R(1.25)*U/k+.5);
        t = -clamp(mod(T+4.,8.)-4.-u.y-.3*u.x,0.,1.)*1.5708; 
    }
   
    u = R(-1.25)*u*k;
    
   
    U = floor(R(t)*(U-u)+.5);
    O = vec4((U.x==0.||U.y==0.)&&abs(U.x)<2.&&abs(U.y)<2.);
    O = o>0. ? 1.-O : O;
}

/**/    


/**

#define M(s) mat2(1,s,-s,1)/sqrt(10.)

{
    float t = TIME, c=cos(t),s=sin(t), l=sqrt(.9),k=sqrt(10.),
          o = 0.; // floor(mod(t/1.5708,2.));
    vec2 u, R = RENDERSIZE.xy;
	U =  15.* (U-R/2.)/ R.y; 
    if (abs(U.x)>7.5) { O-=O; return; }
    U += 3.+ vec2(o,o+o);
	//U *=  15./ RENDERSIZE.y;
    u = M(3)*U;
    u = floor(u/k+.5);
    //u = floor(u/3.*l+.5)*3./l;
    //if (u.y != floor(mod(t/1.5708,8.)-4.)) c=1.,s=0.;
    t = clamp(mod(t/1.5708,8.)-4.-u.y-.3*u.x,0.,1.)*1.5708; c=cos(t),s=sin(t);
    //if (u*l/3.!=vec2(0)) c=1.,s=0.;
    //if (mod(u*l/3.,3.)!=vec2(0)) c=1.,s=0.;
    //O  = vec4(mod(u*l/3.,3.)/3.,0,0); return;
    u = M(-3)*u*k;
    U -= u;
    //O = vec4(length(U)<1.5);
    // O  = vec4(mod(u,3.)/3.,0,0); return;
    
    U = floor(mat2(c,s,-s,c)*U+.5);
    O = vec4((U.x==0.||U.y==0.)&&abs(U.x)<2.&&abs(U.y)<2.);
    O = o>0. ? 1.-O : O;
}
    
/**/




/**
#define M(s) mat2(1,s,-s,1)/sqrt(10.)

{
    float t = TIME, c=cos(t),s=sin(t), l=sqrt(.9),
          o = 0.; // floor(mod(t/1.5708,2.));
    vec2 u, R = RENDERSIZE.xy;
	U =  15.* (U-R/2.)/ R.y + vec2(o,o+o);
	//U *=  15./ RENDERSIZE.y;
    u = M(3)*U;
    u = floor(u/3.*l+.5)*3./l;
    u = M(-3)*u;
    //O = vec4(length(U-u)<1.5);
    
    U = floor(mat2(c,s,-s,c)*(U-u)+.5);
    O = vec4((U.x==0.||U.y==0.)&&abs(U.x)<2.&&abs(U.y)<2.);
    O = o>0. ? 1.-O : O;
}
    
/**/
