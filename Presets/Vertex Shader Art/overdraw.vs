/*{
  "DESCRIPTION": "overdraw",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/vd4wAi9P33ezAYGis)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry"
  ],
  "POINT_COUNT": 4,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 12,
    "ORIGINAL_DATE": {
      "$date": 1524969508745
    }
  }
}*/

/*

Overdraw with blending test

This vertex shader just draws full canvas size planes

Turn on the Chrome Devtools FPS Meter
(Console tab -> Press ESC -> bottom left ⋮ icon -> Rendering)
Increase the count above (the number to the right of the slider)
**SLOWLY** Try 50, then 100, then 150, then 200. If you put
a large number like 10000 the browser may kill WebGL since
the draw took too long.

On my 2014 Macbook Pro I get to about 100 with the window
fullscreen. That's only 100/6 or 16 screens of pixels
even though the fragment shader is just

     varying vec4 v_color
     void main() {
       gl_FragColor = v_color;
     }

Note this page uses CSS pixels so on an HD-DPI display
it's probably only drawing 1/4th the pixels relative
to the actual screen resolution.

Things to consider

* The browser is composting the WebGL canvas on the page
   so that's one fullscreen of pixels of rendering

* This text (the code editor) is another 1/2 or fullscreen
   of pixels being rendered and compositied on the page.

* Vertexshaderart.com has blending enabled. Blending is slower
   than not blending.

* Changing DRAW_BACK_TO_FRONT to 0 I can set count to 350
   which is 58 screens of pixels or 3.6x faster because of
   early depth test rejection. This is of course a simple
   fragment shader. For a complex fragment shader the
   difference would be far higher.

*/

#define DRAW_BACK_TO_FRONT 1

void main() {
  float id = vertexId;
  float x = mod(id, 2.);
  float y = mod(floor(id / 2.) + floor(id / 3.), 2.);
  float planeId = floor(id / 6.);
  float numPlanes = floor(vertexCount / 6.);
  float z = planeId / numPlanes;

  #if DRAW_BACK_TO_FRONT
  z = 1. - z;
  #endif

  gl_Position = vec4(vec3(x, y, z) * 2. - 1., 1);

  v_color = vec4(0.01, 0.02, 0.03, 0.01);
}