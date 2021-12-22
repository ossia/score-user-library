/*
{
    "CATEGORIES": [
        "Automatically Converted",
        "GLSLSandbox"
    ],
    "DESCRIPTION": "Automatically converted from http://glslsandbox.com/e#71410.0",
    "INPUTS": [
        {
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0,
                0
            ],
            "NAME": "mouse",
            "TYPE": "point2D"
        }
    ]
}

*/


#ifdef GL_ES
precision highp float;
#endif


void main()
{
    vec2 p=(2.0*gl_FragCoord.xy-RENDERSIZE)/max(RENDERSIZE.x,RENDERSIZE.y);
    
    for(float i=1.;i<20.;i++)
    {
        p.x += .5/i*sin(i*p.y+TIME)+1.;
        p.y += .5/i*cos(i*p.x+TIME)+2.;
    } 
	
    p.y += cos(TIME/4.+mouse.y)*5.;
    p.x += sin(TIME/3.+mouse.x)*4.;
    
    // vec3 col=vec3(abs(sin(3.0*p.x))*1.3,  abs(sin(1.5*p.y))+0.3, abs(sin(1.0*p.x+p.y))+0.3);
    vec3 col=vec3(abs(sin(3.0*p.x))*1.3,  abs(sin(1.5*p.y))+0.0, abs(sin(1.0*p.x+p.y))+0.3);
    float dist = sqrt(col.x*col.x + col.y * col.y + col.z*col.z);
    gl_FragColor=vec4(col/dist, 1.0);
}