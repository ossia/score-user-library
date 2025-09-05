/*{
  "DESCRIPTION": "Smooth Icosahedron - Icosahedron geometry.",
  "CREDIT": "oneshade (ported from https://www.vertexshaderart.com/art/7vbkgbBXwtnj4LbT2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 60,
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
    "ORIGINAL_VIEWS": 173,
    "ORIGINAL_DATE": {
      "$date": 1612900594414
    }
  }
}*/

#define EYE_DISTANCE 3.0
#define Z_NEAR 1.0
#define Z_FAR -1.0

// Data from: https://people.sc.fsu.edu/~jburkardt/data/obj/icosahedron.obj
// There's a bug with indexing
vec3 getVertex(int index) {
    if ( index == 0 ) return vec3( 0.0, -0.525731, 0.850651 );
    if ( index == 1 ) return vec3( 0.850651, 0.0, 0.525731 );
    if ( index == 2 ) return vec3( 0.850651, 0.0, -0.525731 );
    if ( index == 3 ) return vec3( -0.850651, 0.0, -0.525731 );
    if ( index == 4 ) return vec3( -0.850651, 0.0, 0.525731 );
    if ( index == 5 ) return vec3( -0.525731, 0.850651, 0.0 );
    if ( index == 6 ) return vec3( 0.525731, 0.850651, 0.0 );
    if ( index == 7 ) return vec3( 0.525731, -0.850651, 0.0 );
    if ( index == 8 ) return vec3( -0.525731, -0.850651, 0.0 );
    if ( index == 9 ) return vec3( 0.0, -0.525731, -0.850651 );
    if ( index == 10 ) return vec3( 0.0, 0.525731, -0.850651 );
    if ( index == 11 ) return vec3( 0.0, 0.525731, 0.850651 );
}

ivec3 getTriangle(int index) {
    if ( index == 0 ) return ivec3( 1, 2, 6 );
    if ( index == 1 ) return ivec3( 1, 7, 2 );
    if ( index == 2 ) return ivec3( 3, 4, 5 );
    if ( index == 3 ) return ivec3( 4, 3, 8 );
    if ( index == 4 ) return ivec3( 6, 5, 11 );
    if ( index == 5 ) return ivec3( 5, 6, 10 );
    if ( index == 6 ) return ivec3( 9, 10, 2 );
    if ( index == 7 ) return ivec3( 10, 9, 3 );
    if ( index == 8 ) return ivec3( 7, 8, 9 );
    if ( index == 9 ) return ivec3( 8, 7, 0 );
    if ( index == 10 ) return ivec3( 11, 0, 1 );
    if ( index == 11 ) return ivec3( 0, 11, 4 );
    if ( index == 12 ) return ivec3( 6, 2, 10 );
    if ( index == 13 ) return ivec3( 1, 6, 11 );
    if ( index == 14 ) return ivec3( 3, 5, 10 );
    if ( index == 15 ) return ivec3( 5, 4, 11 );
    if ( index == 16 ) return ivec3( 2, 7, 9 );
    if ( index == 17 ) return ivec3( 7, 1, 0 );
    if ( index == 18 ) return ivec3( 3, 9, 8 );
    if ( index == 19 ) return ivec3( 4, 8, 0 );
}

int getVertexIndex(ivec3 triangle, int index) {
    if ( index == 0 ) return triangle[0];
    if ( index == 1 ) return triangle[1];
    if ( index == 2 ) return triangle[2];
}

void main() {
    int triIndex = int(vertexId / 3.0);
    int vertIndex = int(mod(vertexId, 3.0));
    ivec3 triangle = getTriangle(triIndex);
    vec3 vertex = getVertex(getVertexIndex(triangle, vertIndex));

    float c = cos(time), s = sin(time);
    vertex.xz *= mat2(c, s, -s, c);
    vertex.yz *= mat2(c, s, -s, c);

    vec3 lightDir = normalize(vec3(-1.0, 1.0, 1.0));
    vec3 normal = normalize(vertex);

    vec2 screenCoords = vertex.xy / (EYE_DISTANCE - vertex.z);
    screenCoords.x *= resolution.y / resolution.x;
    float depth = (vertex.z - Z_NEAR) / (Z_FAR - Z_NEAR);
    gl_Position = vec4(screenCoords, depth, 1.0);
    float diffuse = max(0.0, dot(normal, lightDir));
    v_color = vec4(vec3(diffuse), 1.0);
}