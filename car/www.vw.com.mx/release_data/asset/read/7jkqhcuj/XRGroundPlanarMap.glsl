import {
    "tjs-common"
}

properties {
    @Name("Diffuse Color")
    @UiColor()
    vec3 cDiffuseColor,

    @Name("Diffuse Map")
    @Define("USE_MAP")
    sampler2D tDiffuseMap,

    @Name("Intensity")
    @UiSlider(0, 256, 0.1)
    float fIntensity = 1.0,

    @Name("Planar Mapping Scale X")
    @UiSlider(-25, 25, 0.01)
    float fMapScaleX = 1.0,

    @Name("Planar Mapping Scale Y")
    @UiSlider(-25, 25, 0.01)
    float fMapScaleY = 1.0,

    @Name("Planar Mapping Offset X")
    @UiSlider(-1, 1, 0.01)
    float fMapOffsetX = 1.0,

    @Name("Planar Mapping Offset Y")
    @UiSlider(-1, 1, 0.01)
    float fMapOffsetY = 1.0
}

vertex {
    varying vec2 vUV;

    void main(void) {
        vec4 worldpos = modelMatrix * vec4(position, 1.0);
        vUV = worldpos.xz * vec2(fMapScaleX, fMapScaleY) + vec2(fMapOffsetX, fMapOffsetY);
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
}

fragment {
    varying vec2 vUV;

    void main(void) {
        vec4 color = vec4(cDiffuseColor, 1.0);

        #ifdef USE_MAP 
            // TODO: sRGB to linear decode?
            color *= texture2D(tDiffuseMap, vUV);
        #endif

        gl_FragColor = vec4(color.rgb * fIntensity, color.a);
    }
}
