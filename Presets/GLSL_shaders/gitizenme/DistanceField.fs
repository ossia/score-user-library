/*{
    "CATEGORIES": [
        "XXX"
    ],
    "CREDIT": "",
    "INPUTS": [
        {
            "NAME": "red",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "NAME": "green",
            "TYPE": "float"
        },
        {
            "NAME": "blue",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "NAME": "alpha",
            "TYPE": "float"
        },
        {
            "NAME": "centerX",
            "TYPE": "float"
        },
        {
            "NAME": "centerY",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/



void main() {
	vec2 st = isf_FragNormCoord;
    float pct = 0.0;

    // a. The DISTANCE from the pixel to the center
    pct = distance(st,vec2(centerX, centerY));

    // b. The LENGTH of the vector
    //    from the pixel to the center
    // vec2 toCenter = vec2(0.5)-st;
    // pct = length(toCenter);

    // c. The SQUARE ROOT of the vector
    //    from the pixel to the center
    // vec2 tC = vec2(0.5)-st;
    // pct = sqrt(tC.x*tC.x+tC.y*tC.y);


    vec3 color = vec3(pct);
    color.r = red * (1.0-pct);
    color.g = green * (1.0-pct);
    color.b = blue * (1.0-pct);

	gl_FragColor = vec4( color, alpha );
}