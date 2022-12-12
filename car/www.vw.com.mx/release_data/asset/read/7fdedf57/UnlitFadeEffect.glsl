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

    @Name("Power")
    @UiSlider(1, 32, 0.1)
    float fPower = 1.0
}

vertex {
    varying vec3 vViewPosition;
    varying vec3 vNormal;
    varying vec2 vUV;

    void main(void) {
        vec4 viewpos = modelViewMatrix * vec4(position, 1.0);
        vViewPosition = viewpos.xyz;
        vNormal = normalMatrix * normal;
        vUV = uv;
        gl_Position = projectionMatrix * viewpos;
    }
}

fragment {
    varying vec3 vViewPosition;
    varying vec3 vNormal;
    varying vec2 vUV;

    void main(void) {
        vec3 normal = normalize(vNormal);
        vec3 viewDir = normalize(-vViewPosition);
        float NdotV = pow(saturate(dot(viewDir, normal)), fPower);

        vec3 color = cDiffuseColor;

        #ifdef USE_MAP
            vec4 texel = texture2D(tDiffuseMap, vUV); 

            if (texel.a < 0.5) {
                discard;
            }

            color.rgb *= texel.rgb;
        #endif

        gl_FragColor = vec4(color * fIntensity, NdotV);

        #include <encodings_fragment>
    }
}
