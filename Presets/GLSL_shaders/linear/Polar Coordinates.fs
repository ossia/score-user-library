/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Polar coordinate remapping. Converts between Cartesian and polar UV spaces. Forward (CarttoPolar) wraps the image into a tunnel/ring. Inverse (PolartoCart) unwraps a radial image into a flat strip. Creates tunnels, wormholes, kaleidoscope wrapping, and radial symmetry effects.",
    "CATEGORIES": [ "Distortion Effect" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        {
            "NAME": "mode",
            "LABEL": "Mode",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1 ],
            "LABELS": [ "Cartesian to Polar", "Polar to Cartesian" ]
        },
        { "NAME": "center",       "LABEL": "Center",          "TYPE": "point2D", "DEFAULT": [ 0.5, 0.5 ] },
        { "NAME": "angle_offset", "LABEL": "Angle Offset",    "TYPE": "float", "DEFAULT": 0.0,  "MIN": 0.0,  "MAX": 1.0 },
        { "NAME": "radius_scale", "LABEL": "Radius Scale",    "TYPE": "float", "DEFAULT": 1.0,  "MIN": 0.1,  "MAX": 4.0 },
        { "NAME": "repeat_angle", "LABEL": "Angular Repeats",  "TYPE": "float", "DEFAULT": 1.0,  "MIN": 1.0,  "MAX": 12.0 },
        { "NAME": "tile",         "LABEL": "Tile Edges",       "TYPE": "bool",  "DEFAULT": true }
    ]
}*/

const float PI = 3.14159265358979;
const float TAU = 6.28318530718;

void main() {
    vec2 uv = isf_FragNormCoord;
    vec2 sampleUV;

    if (mode == 0) {
        // Cartesian to Polar:
        // Input X to angle, Input Y to radius
        // Reads the image as if wrapped into a cylinder viewed from inside
        vec2 d = uv - center;
        float aspect = RENDERSIZE.x / RENDERSIZE.y;
        d.x *= aspect;

        float r = length(d) * 2.0 / radius_scale;
        float a = atan(d.y, d.x) / TAU + 0.5; // 0-1
        a = fract(a * repeat_angle + angle_offset);

        sampleUV = vec2(a, r);
    }
    else {
        // Polar to Cartesian:
        // Input is assumed radial, output is rectangular unwrap
        // X to angle (0-1 = 0-2π), Y to radius (0-1 = center to edge)
        float a = (uv.x + angle_offset) * TAU * repeat_angle;
        float r = uv.y * 0.5 * radius_scale;

        float aspect = RENDERSIZE.x / RENDERSIZE.y;
        sampleUV = center + vec2(cos(a) * r / aspect, sin(a) * r);
    }

    // Handle tiling vs clamping
    if (tile) {
        sampleUV = fract(sampleUV);
    }

    gl_FragColor = IMG_NORM_PIXEL(inputImage, sampleUV);
}
