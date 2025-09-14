/*{
    "CATEGORIES": [
        "General"
    ],
    "CREDIT": "Jean-Michaël Celerier",
    "ISFVSN": "2",
    "DESCRIPTION": "Video switcher",
    "INPUTS": [
        { "NAME": "t0", "LABEL" : "Texture 0", "TYPE": "image" },
        { "NAME": "t1", "LABEL" : "Texture 1", "TYPE": "image" },
        { "NAME": "t2", "LABEL" : "Texture 2", "TYPE": "image" },
        { "NAME": "t3", "LABEL" : "Texture 3", "TYPE": "image" },
        { "NAME": "t4", "LABEL" : "Texture 4", "TYPE": "image" },
        { "NAME": "t5", "LABEL" : "Texture 5", "TYPE": "image" },
        { "NAME": "t6", "LABEL" : "Texture 6", "TYPE": "image" },
        { "NAME": "t7", "LABEL" : "Texture 7", "TYPE": "image" },
        { "NAME": "index", "LABEL" : "Index", "DEFAULT": 0, "VALUES": [0, 1, 2, 3, 4, 5, 6, 7], "TYPE": "long" }
    ]
}
*/

void main() {
  int idx = int(index);
  switch(idx) {
    case 0: gl_FragColor = IMG_THIS_NORM_PIXEL(t0); break;
    case 1: gl_FragColor = IMG_THIS_NORM_PIXEL(t1); break;
    case 2: gl_FragColor = IMG_THIS_NORM_PIXEL(t2); break;
    case 3: gl_FragColor = IMG_THIS_NORM_PIXEL(t3); break;
    case 4: gl_FragColor = IMG_THIS_NORM_PIXEL(t4); break;
    case 5: gl_FragColor = IMG_THIS_NORM_PIXEL(t5); break;
    case 6: gl_FragColor = IMG_THIS_NORM_PIXEL(t6); break;
    case 7: gl_FragColor = IMG_THIS_NORM_PIXEL(t7); break;
    default: gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);

  }
}
