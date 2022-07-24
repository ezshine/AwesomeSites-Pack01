{
  "metadata": {
    "type": "Object",
    "generator": "",
    "version": 1
  },
  "geometries": [
    {
      "groups": [],
      "offsets": {
        "index": [
          0,
          2399
        ],
        "position": [
          2400,
          3851
        ],
        "normal": [
          3852,
          5303
        ],
        "tangent": [
          5304,
          7239
        ],
        "uv": [
          7240,
          8207
        ]
      },
      "uuid": "6FD068F2-622F-4B56-9AC0-7B3EE1E4C390",
      "name": "Plane"
    },
    {
      "groups": [],
      "offsets": {
        "index": [
          8208,
          17423
        ],
        "position": [
          17424,
          23603
        ],
        "normal": [
          23604,
          29783
        ],
        "tangent": [
          29784,
          38023
        ],
        "uv": [
          38024,
          42143
        ]
      },
      "uuid": "0FF22E6C-5E8A-40E4-90B5-37E21D64827A",
      "name": "Sphere"
    },
    {
      "groups": [],
      "offsets": {
        "index": [
          42144,
          42167
        ],
        "position": [
          42168,
          42215
        ],
        "normal": [
          42216,
          42263
        ],
        "tangent": [
          42264,
          42327
        ],
        "uv": [
          42328,
          42359
        ]
      },
      "uuid": "E409C23A-68C5-48C9-9E35-5D887DA2EFDB",
      "name": "Quad"
    }
  ],
  "materials": [
    {
      "color": 16777215,
      "map": "4D287A6F-2E2D-494D-872B-A50DF31AC21F",
      "uuid": "57CDDE74-2D75-43FA-9B23-DE886C4B7FB5",
      "type": "MeshBasicMaterial",
      "name": "start_ground"
    },
    {
      "color": 16777215,
      "map": "043413F6-DA8A-4A95-B900-F03E9CA759DC",
      "uuid": "E6775600-CFC1-4A37-BD90-D1B3E977EC00",
      "type": "MeshBasicMaterial",
      "name": "start_sphere",
      "side": 1
    },
    {
      "color": 16777215,
      "map": "9BB5F668-2A37-425F-BA3C-71F440B879D4",
      "uuid": "1973C81B-ED9A-4EE3-BBA0-AEC65C584864",
      "type": "MeshBasicMaterial",
      "name": "start_instructions",
      "transparent": true,
      "shading": 1,
      "depthTest": false
    },
    {
      "color": 16777215,
      "map": "C34E3189-0598-4235-9FCE-2B13C61D33F2",
      "uuid": "C2D2A366-F0D9-4535-A089-09A68B756CB8",
      "type": "MeshBasicMaterial",
      "name": "start_blink",
      "transparent": true,
      "shading": 1,
      "depthTest": false
    }
  ],
  "cameras": [
    "F74B5DC4-83DF-4AFA-9335-893F5EA74BA0"
  ],
  "images": [
    {
      "uuid": "DFB16834-6540-4885-8F17-97F432BC8655",
      "url": "maps/start/grid.jpg"
    },
    {
      "uuid": "98A6C0EA-E2EA-414F-A4FD-CC2ED9D8D077",
      "url": "maps/start/sphere.jpg"
    },
    {
      "uuid": "3BF182BA-425A-43FE-8EC2-5CD23FF14B82",
      "url": "maps/start/instructions.png"
    },
    {
      "uuid": "5695180C-FB96-436A-BDB8-33D9F0BBDD37",
      "url": "maps/start/instructions.png"
    }
  ],
  "textures": [
    {
      "uuid": "4D287A6F-2E2D-494D-872B-A50DF31AC21F",
      "name": "grid",
      "image": "DFB16834-6540-4885-8F17-97F432BC8655",
      "offset": [
        0.0,
        0.0
      ],
      "repeat": [
        2000.0,
        2000.0
      ],
      "wrap": [
        1000,
        1000
      ],
      "anisotropy": 16
    },
    {
      "uuid": "043413F6-DA8A-4A95-B900-F03E9CA759DC",
      "name": "sphere",
      "image": "98A6C0EA-E2EA-414F-A4FD-CC2ED9D8D077",
      "offset": [
        0.0,
        0.0
      ],
      "repeat": [
        1.0,
        1.0
      ],
      "wrap": [
        1000,
        1000
      ]
    },
    {
      "uuid": "9BB5F668-2A37-425F-BA3C-71F440B879D4",
      "name": "instructions",
      "image": "3BF182BA-425A-43FE-8EC2-5CD23FF14B82",
      "offset": [
        0.0,
        0.22
      ],
      "repeat": [
        1.0,
        0.78
      ],
      "wrap": [
        1000,
        1000
      ]
    },
    {
      "uuid": "C34E3189-0598-4235-9FCE-2B13C61D33F2",
      "name": "instructions",
      "image": "5695180C-FB96-436A-BDB8-33D9F0BBDD37",
      "offset": [
        0.0,
        0.0
      ],
      "repeat": [
        1.0,
        0.25
      ],
      "wrap": [
        1000,
        1000
      ]
    }
  ],
  "animations": [],
  "object": {
    "uuid": "F9015AFB-EF4C-4C98-8C1B-2CEB71012C1A",
    "name": "start",
    "type": "Scene",
    "children": [
      {
        "uuid": "570FBCA1-BB08-452A-8D5E-294A75E2EDFD",
        "name": "Missing Prefab"
      },
      {
        "fov": 60,
        "aspect": 2.26429987,
        "near": 0.3,
        "far": 1000.0,
        "uuid": "F74B5DC4-83DF-4AFA-9335-893F5EA74BA0",
        "name": "Main Camera",
        "type": "PerspectiveCamera",
        "matrix": [
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          1.08,
          0.0,
          1.0
        ],
        "layers": -1
      },
      {
        "color": 16777215,
        "intensity": 1.0,
        "uuid": "ABA8CCBC-33CD-4CD1-B62B-EC51A80379D9",
        "name": "Directional Light",
        "type": "DirectionalLight",
        "castShadow": true,
        "matrix": [
          -0.09159279,
          0.398414582,
          -0.9126209,
          0.0,
          -0.8731321,
          0.40852958,
          0.265977561,
          0.0,
          0.478802,
          0.8212001,
          0.310450017,
          0.0,
          0.0,
          3.0,
          0.0,
          1.0
        ]
      },
      {
        "geometry": "6FD068F2-622F-4B56-9AC0-7B3EE1E4C390",
        "material": "57CDDE74-2D75-43FA-9B23-DE886C4B7FB5",
        "uuid": "BC2102B9-366A-4773-A332-2D80824BF4CA",
        "name": "Plane",
        "type": "Mesh",
        "castShadow": true,
        "receiveShadow": true,
        "matrix": [
          100.0,
          0.0,
          0.0,
          0.0,
          0.0,
          100.0,
          0.0,
          0.0,
          0.0,
          0.0,
          100.0,
          0.0,
          0.0,
          -0.15,
          0.0,
          1.0
        ]
      },
      {
        "geometry": "0FF22E6C-5E8A-40E4-90B5-37E21D64827A",
        "material": "E6775600-CFC1-4A37-BD90-D1B3E977EC00",
        "uuid": "74D8EC25-8859-4EE1-AAF6-82095BF32F99",
        "name": "Sphere",
        "type": "Mesh",
        "castShadow": true,
        "receiveShadow": true,
        "matrix": [
          96.41625,
          0.0,
          0.0,
          0.0,
          0.0,
          96.41612,
          0.0,
          0.0,
          0.0,
          0.0,
          96.41612,
          0.0,
          0.0,
          -1.18,
          0.0,
          1.0
        ]
      },
      {
        "uuid": "FE5E3484-8A77-40D2-9636-5019C08D6609",
        "name": "instructions",
        "children": [
          {
            "geometry": "E409C23A-68C5-48C9-9E35-5D887DA2EFDB",
            "material": "1973C81B-ED9A-4EE3-BBA0-AEC65C584864",
            "uuid": "FF796398-8AA6-425C-AE1E-A672096290AC",
            "name": "text",
            "type": "Mesh",
            "castShadow": true,
            "receiveShadow": true,
            "matrix": [
              1.024,
              0.0,
              0.0,
              0.0,
              0.0,
              0.397,
              0.0,
              0.0,
              0.0,
              0.0,
              1.0,
              0.0,
              0.0,
              0.0,
              0.0,
              1.0
            ]
          },
          {
            "geometry": "E409C23A-68C5-48C9-9E35-5D887DA2EFDB",
            "material": "C2D2A366-F0D9-4535-A089-09A68B756CB8",
            "uuid": "7E617177-AF2C-45CF-98BB-268302C99B1D",
            "name": "cta",
            "type": "Mesh",
            "castShadow": true,
            "receiveShadow": true,
            "matrix": [
              1.024,
              0.0,
              0.0,
              0.0,
              0.0,
              0.128,
              0.0,
              0.0,
              0.0,
              0.0,
              1.0,
              0.0,
              0.0,
              -0.265,
              0.0,
              1.0
            ]
          }
        ]
      }
    ]
  },
  "renderer": {
    "shadowMapEnabled": false
  },
  "binary": true
}