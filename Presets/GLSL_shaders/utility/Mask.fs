/*{
    "DOCUMENTATION": "https://ossia.io/score-docs/processes/shaders/utility/mask.html",
    "CATEGORIES": [
        "General"
    ],
    "CREDIT": " Jean-Michaël Celerier",
    "DESCRIPTION": "Apply a mask",
    "INPUTS": [
        { "NAME": "source", "LABEL" : "Texture 1", "TYPE": "image" },
        { "NAME": "mask", "LABEL" : "Texture 2", "TYPE": "image" }
    ],
    "ISFVSN": "2"
}
*/
void main()	{
  gl_FragColor = vec4(IMG_THIS_NORM_PIXEL(source).rgb, IMG_THIS_NORM_PIXEL(mask).r);
}