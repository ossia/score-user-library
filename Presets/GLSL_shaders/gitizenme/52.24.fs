/*{
    "CATEGORIES": [
        "Color",
        "Iteration"
    ],
    "CREDIT": "ChaosOfZen",
    "DESCRIPTION": "",
    "INPUTS": [
        {
            "DEFAULT": true,
            "NAME": "invert",
            "TYPE": "bool"
        },
        {
            "DEFAULT": 0.03,
            "MAX": 2,
            "MIN": 0,
            "NAME": "gradient",
            "TYPE": "float"
        },
        {
            "DEFAULT": 10,
            "MAX": 50,
            "MIN": 0.0001,
            "NAME": "radius",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0.5,
                0.5
            ],
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0,
                0
            ],
            "NAME": "pos",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0,
                0
            ],
            "MAX": [
                0.1,
                0.1
            ],
            "MIN": [
                -0.1,
                -0.1
            ],
            "NAME": "offsetPos",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": 0.2,
            "MAX": 1,
            "MIN": 0.0001,
            "NAME": "offset",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABELS": [
                "circle",
                "square"
            ],
            "NAME": "shapeSelect",
            "TYPE": "long",
            "VALUES": [
                0,
                1
            ]
        },
        {
            "DEFAULT": [
                0,
                0,
                1,
                1
            ],
            "LABEL": "Base Color",
            "NAME": "baseColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.6,
                0,
                1,
                1
            ],
            "LABEL": "line Color",
            "NAME": "lineColor",
            "TYPE": "color"
        }
    ],
    "ISFVSN": "2"
}
*/

float circle(in vec2 _st, in float _radius){
    vec2 l = _st;
    return 1.-smoothstep(_radius-(_radius*gradient),
                         _radius+(_radius*gradient),
                         dot(l,l)*radius);
}

float box(vec2 _st, vec2 _size, float _smoothEdges){
    //_size = vec2(0.0);
    _st += 0.5;
    vec2 aa = vec2(_smoothEdges*0.5);
    vec2 uv = smoothstep(_size,_size+aa,_st);
    uv *= smoothstep(_size,_size+aa,vec2(1.0)-_st);
    return uv.x*uv.y;
}

 vec3 invertColor(vec3 color) {
    return vec3(color *-1.0 + 1.0);
 	
 }

void main() {

		vec2 st = isf_FragNormCoord;
		st -= vec2(pos);						
		st.x *= RENDERSIZE.x/RENDERSIZE.y;		
		
		vec3 color = vec3(lineColor.r, lineColor.g, lineColor.b);

		
		for (float i = 0.0; i<50.0; i++){
			 vec3 shape = vec3(0.0);
			 if (shapeSelect == 0) shape = vec3(circle(st-=vec2(offsetPos), (offset * i)));
			 if (shapeSelect == 1) shape = vec3(box(st-=vec2(offsetPos),vec2(radius*0.009*offset,radius*0.009*offset),gradient*0.05));

			
			shape *= invertColor(shape);
			color += shape;
		}
		
		
	vec3 finalColor = vec3(baseColor.r, baseColor.g, baseColor.b);
	if (invert) { 
		color = invertColor(color);
	}
    finalColor.r += color.r;
	finalColor.g += color.g;
	finalColor.b += color.b;

	gl_FragColor = vec4(finalColor,1.0);
}