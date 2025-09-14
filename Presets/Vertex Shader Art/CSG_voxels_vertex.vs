/*{
  "DESCRIPTION": "CSG voxels vertex - CSG template",
  "CREDIT": "morimea (ported from https://www.vertexshaderart.com/art/rpRcyCMh5R2XDbm49)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 60750,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.043137254901960784,
    0.0392156862745098,
    0.03529411764705882,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1616536594181
    }
  }
}*/

  //#define vertexId float(gl_InstanceID+gl_VertexID)

  // default number of particles 15*15*15*6*3=60750 15 is cube size

  const float size=1.;

  //out vec4 v_color;

  const float PI = 3.1415926535898;

  const float VertX = 15.0;
  const float VertY = 15.0;

  const float tscale = 0.2;
  const vec3 obj_pos = vec3(-1.5);

  mat3 rotx(float a){float s = sin(a);float c = cos(a);return mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, c, s), vec3(0.0, -s, c)); }
  mat3 roty(float a){float s = sin(a);float c = cos(a);return mat3(vec3(c, 0.0, s), vec3(0.0, 1.0, 0.0), vec3(-s, 0.0, c));}
  mat3 rotz(float a){float s = sin(a);float c = cos(a);return mat3(vec3(c, s, 0.0), vec3(-s, c, 0.0), vec3(0.0, 0.0, 1.0 ));}

  const float degree_to_rad = PI / 180.0;

  mat4 perspectiveMatrix(float fovYInRad, float aspectRatio)
  {
      float yScale = 1.0 / tan(fovYInRad / 2.0);
      float xScale = yScale / aspectRatio;
      float zf = 100.0;
      float zn = 0.3;

      float z1 = zf / (zf - zn);
      float z2 = -zn * zf / (zf - zn);

      mat4 result = mat4(xScale, 0.0, 0.0, 0.0, 0.0, yScale, 0.0, 0.0, 0.0, 0.0, -z1, -1., 0.0, 0.0, z2, 0.0);

      return result;
  }

  mat4 lookat(vec3 eye, vec3 look, vec3 up)
  {
      vec3 z = normalize(eye - look);
      vec3 x = normalize(cross(up, z));
      vec3 y = cross(z, x);
      return mat4(x.x, y.x, z.x, 0.0, x.y, y.y, z.y, 0.0, x.z, y.z, z.z, 0.0, 0.0, 0.0, 0.0, 1.0) *
        mat4(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -eye.x, -eye.y, -eye.z, 1.0);
  }

  vec3 voxelPosToWorld(vec3 vp)
  {
      return vp * (tscale / (size)) + obj_pos;
  }

  float sphereSDF(vec3 p, float r)
  {
      return length(p) - r;
  }

  float sdBox( vec3 p, vec3 b )
  {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
  }

  float sdfUnion( const float a, const float b )
  {
      return min(a, b);
  }

  float sdfDifference( const float a, const float b)
  {
      return max(a, -b);
  }

  float sdfIntersection( const float a, const float b )
  {
      return max(a, b);
  }

  float scene(vec3 p)
  {
      float d = 0.0;
      d = sdfDifference(sphereSDF(p + vec3(0., 0.3, 0.), .8),
        sphereSDF(p + vec3(0., -0.6 + 0.6 * sin(time), 0.), .7));
      d = sdfDifference(sdBox(p + vec3(0., 0.3, 0.), vec3(.8)),
        sphereSDF(p + vec3(0., -0.6 + 0.6 * sin(time), 0.), .7));

      return d;
  }

  vec3 sceneNormal(vec3 p)
  {
      vec3 EPS = vec3(0.01, 0.0, 0.0);
      vec3 n;
      n.x = scene(p + EPS.xyz) - scene(p - EPS.xyz);
      n.y = scene(p + EPS.zxy) - scene(p - EPS.zxy);
      n.z = scene(p + EPS.yzx) - scene(p - EPS.yzx);
      return normalize(n);
  }

  vec3 vertexSmooth(vec3 ip)
  {
      vec3 p = ip;
      vec3 n = sceneNormal(p);
      for (int i = 0; i < 8; i++)
      {
        float d = scene(p);
        p -= n * d;
        if (abs(d) < 0.01)
        {
        break;
        }
      }
      return p;
  }

  vec3 phongContribForLight(vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye, vec3 lightPos, vec3 lightIntensity, vec3 N)
  {
      vec3 L = normalize(lightPos - p);
      vec3 V = normalize(eye - p);
      vec3 R = normalize(reflect(-L, N));

      float dotLN = dot(L, N);
      float dotRV = dot(R, V);

      if (dotLN < 0.0)
      {
        return vec3(0.0, 0.0, 0.0);
      }

      if (dotRV < 0.0)
      {
        return lightIntensity * (k_d * dotLN);
      }
      return lightIntensity * (k_d * dotLN + k_s * pow(dotRV, alpha));
  }

  vec3 phongIllumination(vec3 k_a, vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye, vec3 norm)
  {
      const vec3 ambientLight = 0.5 * vec3(1.0, 1.0, 1.0);
      vec3 color = ambientLight * k_a;

      vec3 light1Pos = normalize(vec3(mouse.x, mouse.y, .20));
      vec3 light1Intensity = 2. * vec3(0.4, 0.4, 0.4);

      color += phongContribForLight(k_d, k_s, alpha, p, eye, light1Pos, light1Intensity, norm);

      return color;
  }

  vec4 color_phong(vec3 p, vec3 ro, vec3 n, vec3 col)
  {
      vec3 K_a = col;
      vec3 K_d = K_a;
      vec3 K_s = vec3(1.0, 1.0, 1.0);
      float shininess = 12.0;

      col = phongIllumination(K_a, K_d, K_s, shininess, p, ro, n);
      return vec4(col, 1.);
  }

  void main()
  {
      // vertex index in quad face, two triangles
      float id_Vert = mod(vertexId, 6.0);
      // face index
      float id_Face = floor(vertexId / 6.0);
      // corner face index
      float id_Face_corner = mod(id_Face, 3.0);
      // corner edge index
      float id_Edge = mod(id_Face, 3.0);
      // corner index 1 corner is 3 faces is 3*6 verts
      float id_Corner = floor(vertexId / 18.0);
      // corner position
      vec3 cornerP;
      float tVertX = VertX * size;
      float tVertY = VertY * size;
      cornerP.x = mod(id_Corner, tVertX);
      cornerP.y = mod(floor(id_Corner / tVertX), tVertY);
      cornerP.z = mod(floor(id_Corner / (tVertX * tVertY)), tVertY);

      vec3 faceNorm;
      vec3 faceTan;
      vec3 faceaTan;
      if (id_Edge == 0.0)
      {
        faceNorm = vec3(1.0, 0.0, 0.0);
        faceTan = vec3(0.0, 0.0, -1.0);
        faceaTan = vec3(0.0, 1.0, 0.0);
      }
      else if (id_Edge == 1.0)
      {
        faceNorm = vec3(0.0, 1.0, 0.0);
        faceTan = vec3(1.0, 0.0, 0.0);
        faceaTan = vec3(0.0, 0.0, -1.0);
      }
      else
      {
        faceNorm = vec3(0.0, 0.0, 1.0);
        faceTan = vec3(1.0, 0.0, 0.0);
        faceaTan = vec3(0.0, 1.0, 0.0);
      }
      vec3 aPos = cornerP + faceNorm;

      // sampling points
      vec3 p0 = voxelPosToWorld(cornerP);
      vec3 p1 = voxelPosToWorld(aPos);

      // field value
      float d0 = scene(p0);
      float d1 = scene(p1);

      vec3 p;
      vec3 vertNorm;

      if (d0 * d1 > 0.0)
      {
        // no face
        p = p0;
        vertNorm = vec3(1.0, 1.0, 1.0);
      }
      else
      {
        // have a face
        if (d1 < d0)
        {
        // 0->1 is standard normal.
        // otherwise flip triangle
        if (id_Vert == 0.0)
        {
        id_Vert = 2.0;
        }
        else if (id_Vert == 2.0)
        {
        id_Vert = 0.0;
        }
        else if (id_Vert == 3.0)
        {
        id_Vert = 5.0;
        }
        else if (id_Vert == 5.0)
        {
        id_Vert = 3.0;
        }
        faceNorm *= -1.0;
        }

        /*
        face
        2 4-5
        |\ \|
        0-1 3
        */
        float faceSize = mix(0.45, 0.5, clamp(cos(time * .75) * 4.0 + 0.5, 0.0, 1.0));
        vec3 edgeMidP = (cornerP + aPos) * 0.5;
        vec3 faceVertP;
        if (id_Vert == 0.0)
        {
        faceVertP = edgeMidP + faceTan * -faceSize + faceaTan * -faceSize;
        }
        else if (id_Vert == 1.0)
        {
        faceVertP = edgeMidP + faceTan * faceSize + faceaTan * -faceSize;
        }
        else if (id_Vert == 2.0)
        {
        faceVertP = edgeMidP + faceTan * -faceSize + faceaTan * faceSize;
        }
        else if (id_Vert == 3.0)
        {
        faceVertP = edgeMidP + faceTan * faceSize + faceaTan * -faceSize;
        }
        else if (id_Vert == 4.0)
        {
        faceVertP = edgeMidP + faceTan * -faceSize + faceaTan * faceSize;
        }
        else if (id_Vert == 5.0)
        {
        faceVertP = edgeMidP + faceTan * 0.5 + faceaTan * 0.5;
        }
        p = voxelPosToWorld(faceVertP);

        // smoothing
        vec3 sp = vertexSmooth(p);
        vertNorm = sceneNormal(p);

        float vmix = clamp(sin(time * 0.35) * 2.0 + 0.5, 0.0, 1.0);
        vmix = 1.;
        p = mix(p, sp, vmix);
        vertNorm = mix(faceNorm, vertNorm, vmix);
      }

      vec3 eye = vec3(0.0, 0.0, 3.5) * rotx(clamp(mouse.y, -0.5, 0.5) * 1.5) * roty(-clamp(mouse.x, -0.5, 0.5) * 1.5);
      // eye = vec3(0.0, 0.0, 3.0);
      mat4 viewMat = lookat(eye, vec3(0.0), vec3(0.0, 1.0, 0.0));
      mat4 pMatrix = perspectiveMatrix(60.0 * degree_to_rad, resolution.x / resolution.y);
      vec4 viewPos = (viewMat * vec4(p, 1.0));
      vec3 viewNorm = normalize((viewMat * vec4(vertNorm, 0.0)).xyz);

      gl_Position = (pMatrix * viewPos) * 100.2;
      gl_PointSize = 2.0;

      v_color = color_phong(viewPos.xyz, eye, viewNorm, 0.5 * (viewNorm + 1.) / 2.);
  }