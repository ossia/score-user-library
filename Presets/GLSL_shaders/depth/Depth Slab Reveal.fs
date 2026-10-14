/*{
    "CREDIT": "ossia team",
    "ISFVSN": "2",
    "MODE": "ISF",
    "DESCRIPTION": "Slab reveal: keeps only pixels whose eye depth falls inside [slabNear, slabFar]. Outside the slab the scene is cut away: with Outside opacity 0 it becomes transparent, with 1 it is replaced by the outside colour, in between it fades to that colour at that opacity. Essentially a depth-based clipping plane for VJ reveals, cross-sections, and staged transitions.",
    "CATEGORIES": ["Post-process", "Slice"],

    "PIPELINE_STATE": {
        "DEPTH_TEST": true,
        "DEPTH_COMPARE": "always",
        "DEPTH_WRITE": true
    },

    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "DEPTH": true, "LABEL": "Scene color + depth" },
        { "NAME": "camera", "TYPE": "uniform", "LABEL": "Camera matrices",
            "LAYOUT": [
                { "NAME": "view",           "TYPE": "mat4" },
                { "NAME": "projection",     "TYPE": "mat4" },
                { "NAME": "viewProjection", "TYPE": "mat4" },
                { "NAME": "cameraPosition", "TYPE": "vec4" },
                { "NAME": "renderSize",     "TYPE": "vec4" },
                { "NAME": "params",         "TYPE": "vec4" } ] },
        { "NAME": "slabNear", "TYPE": "float", "LABEL": "Slab near (world units)",
          "DEFAULT": 3.0, "MIN": 0.0, "MAX": 1000.0 },
        { "NAME": "slabFar",  "TYPE": "float", "LABEL": "Slab far (world units)",
          "DEFAULT": 15.0, "MIN": 0.0, "MAX": 10000.0 },
        { "NAME": "feather",  "TYPE": "float", "LABEL": "Feather (world units, soft edges)",
          "DEFAULT": 0.5, "MIN": 0.0, "MAX": 10.0 },
        { "NAME": "outsideColor", "TYPE": "color", "LABEL": "Outside slab colour",
          "DEFAULT": [0.0, 0.0, 0.0, 1.0] },
        { "NAME": "outsideAmount", "TYPE": "float", "LABEL": "Outside opacity (0 = transparent reveal, 1 = replace)",
          "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0 }
    ]
}*/

#include "depth_helpers.glsl"

void main()
{
    vec2  uv    = isf_FragNormCoord;
    vec4  color = IMG_NORM_PIXEL(inputImage, uv);
    float rawD  = IMG_DEPTH_NORM_PIXEL(inputImage, uv);
    float eye   = dh_linearizeDepth(rawD, camera.projection);

    float mask = dh_slabMask(eye, slabNear, slabFar, feather);
    float outside = 1.0 - mask;

    // Inside: the scene. Outside: a layer of outsideColor at outsideAmount
    // opacity (0 cuts to transparent). Composited premultiplied.
    vec3  pm = color.rgb * color.a * mask + outsideColor.rgb * outsideAmount * outside;
    float a  = color.a * mask + outsideAmount * outside;
    isf_FragColor = vec4(pm / max(a, DH_EPSILON), a);
    gl_FragDepth = rawD;
}
