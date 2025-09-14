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
        { "NAME": "t8", "LABEL" : "Texture 8", "TYPE": "image" },
        { "NAME": "t9", "LABEL" : "Texture 9", "TYPE": "image" },
        { "NAME": "t10", "LABEL" : "Texture 10", "TYPE": "image" },
        { "NAME": "t11", "LABEL" : "Texture 11", "TYPE": "image" },
        { "NAME": "t12", "LABEL" : "Texture 12", "TYPE": "image" },
        { "NAME": "t13", "LABEL" : "Texture 13", "TYPE": "image" },
        { "NAME": "t14", "LABEL" : "Texture 14", "TYPE": "image" },
        { "NAME": "t15", "LABEL" : "Texture 15", "TYPE": "image" },
        { "NAME": "index", "LABEL" : "Index", "DEFAULT": 0, "VALUES": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], "TYPE": "long" }
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
    case 8: gl_FragColor = IMG_THIS_NORM_PIXEL(t8); break;
    case 9: gl_FragColor = IMG_THIS_NORM_PIXEL(t9); break;
    case 10: gl_FragColor = IMG_THIS_NORM_PIXEL(t10); break;
    case 11: gl_FragColor = IMG_THIS_NORM_PIXEL(t11); break;
    case 12: gl_FragColor = IMG_THIS_NORM_PIXEL(t12); break;
    case 13: gl_FragColor = IMG_THIS_NORM_PIXEL(t13); break;
    case 14: gl_FragColor = IMG_THIS_NORM_PIXEL(t14); break;
    case 15: gl_FragColor = IMG_THIS_NORM_PIXEL(t15); break;
    default: gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);

  }
}
