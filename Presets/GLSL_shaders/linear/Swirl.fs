/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Swirl / twirl distortion. Rotates pixels around a center point with strength decreasing by distance. Animatable angle for spinning effects. Present in Isadora, Notch, After Effects as a standard warp.",
    "CATEGORIES": [ "Filter" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "twist_angle",
            "LABEL": "Twist Angle (radians)",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": -12.566,
            "MAX": 12.566
        },
        {
            "NAME": "radius",
            "LABEL": "Radius",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": 0.01,
            "MAX": 2.0
        },
        {
            "NAME": "center",
            "LABEL": "Center",
            "TYPE": "point2D",
            "DEFAULT": [ 0.5, 0.5 ]
        },
        {
            "NAME": "falloff",
            "LABEL": "Falloff",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.1,
            "MAX": 4.0
        }
    ]
}*/

void main() {
    vec2 uv = isf_FragNormCoord;
    float aspect = RENDERSIZE.x / RENDERSIZE.y;

    // Aspect-corrected distance from center
    vec2 d = uv - center;
    d.x *= aspect;
    float dist = length(d);

    // Normalized distance (0 at center, 1 at radius edge)
    float t = dist / radius;

    // Rotation amount: full at center, zero at radius
    float angle = 0.0;
    if (t < 1.0) {
        float blend = pow(1.0 - t, falloff);
        angle = twist_angle * blend;
    }

    // Rotate UV around center
    float c = cos(angle);
    float s = sin(angle);
    vec2 rotated;
    rotated.x = d.x * c - d.y * s;
    rotated.y = d.x * s + d.y * c;

    // Undo aspect correction and offset back
    rotated.x /= aspect;
    vec2 sampleUV = rotated + center;

    gl_FragColor = vec4(
        IMG_NORM_PIXEL(inputImage, sampleUV).rgb,
        IMG_NORM_PIXEL(inputImage, uv).a
    );
}
