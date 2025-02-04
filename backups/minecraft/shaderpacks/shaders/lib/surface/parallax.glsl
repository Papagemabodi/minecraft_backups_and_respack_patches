vec4 ReadNormal(vec2 coord) {
    coord = fract(coord) * vTexCoordAM.pq + vTexCoordAM.st;
	return texture2DGradARB(normals, coord, dcdx, dcdy);
}

void GetParallaxCoord(float parallaxFade, inout vec2 newCoord, inout float parallaxDepth) {
    vec2 coord = vTexCoord.st;
    float invParallaxQuality = 1.0 / PARALLAX_QUALITY;
	
    if (parallaxFade < 1.0) {
        vec3 normalMap = ReadNormal(vTexCoord.st).xyz * 2.0 - 1.0;
		
        float normalCheck = normalMap.x + normalMap.y;
        float minHeight = 1.0 - invParallaxQuality;

        if (viewVector.z < 0.0 && ReadNormal(vTexCoord.st).a < minHeight && normalCheck > -1.999) {
            float multiplier = 0.2 * (1.0 - parallaxFade) * PARALLAX_DEPTH /
                                (-viewVector.z * PARALLAX_QUALITY);
            vec2 interval = viewVector.xy * multiplier;
            for(int i = 0; i < PARALLAX_QUALITY; i++) {
                if (ReadNormal(coord).a < 1.0 - float(i) / PARALLAX_QUALITY) {
                    coord += interval;
                    #ifdef SELF_SHADOW
                        if (i > 0) parallaxDepth -= invParallaxQuality;
                    #endif
                } else break;
            }
            newCoord = fract(coord.st) * vTexCoordAM.pq + vTexCoordAM.st;
        }
    }
    #ifdef SELF_SHADOW
        parallaxDepth = parallaxDepth;
    #endif
}

float GetParallaxShadow(float parallaxFade, vec2 coord, vec3 lightVec, mat3 tbn, float parallaxDepth) {
    float parallaxshadow = 1.0;
    float minHeight = 1.0 - 1.0 / PARALLAX_QUALITY;

    if (dist < PARALLAX_DISTANCE + 32.0) {
        #ifdef PARALLAX
            float height = parallaxDepth;
        #else
			float height = texture2DGradARB(normals, coord, dcdx, dcdy).a;
		#endif
        if (height < minHeight) {
            vec3 parallaxdir = tbn * lightVec;
            parallaxdir.xy *= 0.2 * SELF_SHADOW_ANGLE * PARALLAX_DEPTH;
            vec2 newvTexCoord = (coord - vTexCoordAM.st) / vTexCoordAM.pq;
            float step = 1.28 / PARALLAX_QUALITY;
            
            for(int i = 0; i < PARALLAX_QUALITY / 4; i++) {
                float currentHeight = height + parallaxdir.z * step * i;
                vec2 parallaxCoord = fract(newvTexCoord + parallaxdir.xy * i * step) * 
                                     vTexCoordAM.pq + vTexCoordAM.st;
                float offsetHeight = texture2DGradARB(normals, parallaxCoord, dcdx, dcdy).a;
                parallaxshadow *= clamp(1.0 - (offsetHeight - currentHeight) * 40.0, 0.0, 1.0);
                if (parallaxshadow < 0.01) break;
            }
            
            parallaxshadow = mix(parallaxshadow, 1.0, parallaxFade);
        }
    }

    return parallaxshadow;
}