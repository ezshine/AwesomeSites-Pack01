import {
    "envmap"
}

properties {
    @Name("Fresnel Color")
    @Description("")
    @UiColor()
    vec3 cFresnel = (1, 1, 1),

    @Name("Color Fresnel Power")
    @Description("")
    @UiSlider(1, 10, 1)
    float fColorFresnelPower = 1.0,

    @Name("Reflection Fresnel Power")
    @Description("")
    @UiSlider(1, 10, 1)
    float fReflectionFresnelPower = 1.0,

    @Name("Reflection Intensity")
    @Description("")
    @UiSlider(0, 1, 0.01)
    float fReflectionIntensity = 1.0
}

vertex {
    varying vec3 vViewPosition;
    varying vec3 vNormal;

    void main(void) {
        vec4 viewpos = modelViewMatrix * vec4(position, 1.0);
        vViewPosition = viewpos.xyz;
        vNormal = normalMatrix * normal;
        gl_Position = projectionMatrix * viewpos;
    }
}

fragment {
    varying vec3 vViewPosition;
    varying vec3 vNormal;

    void main(void) {
        vec3 normal = normalize(vNormal);
        vec3 viewDir = normalize(-vViewPosition);
        float n_dot_v = max(dot(viewDir, normal), 0.0);
        float f = 1.0 - n_dot_v;

        vec3 reflected  = (vec4(reflect(-viewDir, normal), 0.0) * viewMatrix).xyz;
        vec3 reflection = bilinearCubeUV(envMap, reflected, cubeUV_maxMipLevel);
        reflection *= pow(f, fReflectionFresnelPower) * fReflectionIntensity;

        gl_FragColor.rgb = reflection;
        gl_FragColor.a = dot(reflection, vec3(0.2126, 0.7152, 0.0722)); // force alpha to zero
        #include <tonemapping_fragment>

        f = pow(f, fColorFresnelPower);
        gl_FragColor.rgb += cFresnel * f;
        gl_FragColor.a = gl_FragColor.a + f;
        // Oh why is this terribleness necessary.
        gl_FragColor = saturate(gl_FragColor);

        #include <encodings_fragment>
    }
}
