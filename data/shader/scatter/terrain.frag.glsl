#version 110

struct lightDataType {
    vec4  ambient; 
    vec4  diffuse; 
    vec4  specular; 
    vec4  position;
};
float xlat_lib_saturate( float x) {
  return clamp( x, 0.0, 1.0);
}

vec2 xlat_lib_saturate( vec2 x) {
  return clamp( x, 0.0, 1.0);
}

vec3 xlat_lib_saturate( vec3 x) {
  return clamp( x, 0.0, 1.0);
}

vec4 tbnNormDirToLightsaturate( vec4 x) {
  return clamp( x, 0.0, 1.0);
}

mat2 xlat_lib_saturate(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}

mat3 xlat_lib_saturate(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}

mat4 xlat_lib_saturate(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}

uniform lightDataType light;

uniform float shininess; // Shininess exponent for specular highlights

uniform sampler2D normalMap;
uniform sampler2D specularMap;

varying vec3 tbnDirToLight; // Direction to light in tangent space
varying vec3 tbnHalfVector; // Half vector in tangent space

struct TerrainRegion
{
    float min;
    float max;
};

varying vec3 Lin;
varying vec3 Fex;
varying float distance;

uniform TerrainRegion dirtRegion;
uniform TerrainRegion grassRegion;
uniform TerrainRegion rockRegion;
uniform TerrainRegion snowRegion;

uniform float heightMapScale;

uniform sampler2D heightMap;
uniform sampler2D dirtColorMap;
uniform sampler2D grassColorMap;
uniform sampler2D rockColorMap;
uniform sampler2D snowColorMap;


varying float terrainHeight;

float GetHeightMapHeight(const vec2 texCoord)
{
    return length(texture2D(heightMap, texCoord)) * 400.0 * heightMapScale;
}

vec4 GenerateTerrainColor()
{
    vec4 terrainColor = vec4(0.3, 0.3, 0.3, 1.0);
    vec2 heightMapTexCoord = gl_TexCoord[4].st;
    vec2 terrainTexCoord = gl_TexCoord[0].st;
    
    float height = GetHeightMapHeight(heightMapTexCoord);
    float regionMin = 0.0;
    float regionMax = 0.0;
    float regionRange = 0.0;
    float regionWeight = 0.0;

    // Dirt terrain region.
    regionMin = dirtRegion.min;
    regionMax = dirtRegion.max;
    regionRange = regionMax - regionMin;
    regionWeight = (regionRange - abs(height - regionMax)) / regionRange;
    regionWeight = (regionWeight < 0.0) ? 0.0 : regionWeight;
    terrainColor += regionWeight * texture2D(dirtColorMap, terrainTexCoord);

    // Grass terrain region.
    regionMin = grassRegion.min;
    regionMax = grassRegion.max;
    regionRange = regionMax - regionMin;
    regionWeight = (regionRange - abs(height - regionMax)) / regionRange;
    regionWeight = (regionWeight < 0.0) ? 0.0 : regionWeight;
    terrainColor += regionWeight * texture2D(grassColorMap, terrainTexCoord);
    
    // Rock terrain region.
    regionMin = rockRegion.min;
    regionMax = rockRegion.max;
    regionRange = regionMax - regionMin;
    regionWeight = (regionRange - abs(height - regionMax)) / regionRange;
    regionWeight = (regionWeight < 0.0) ? 0.0 : regionWeight;
    terrainColor += regionWeight * texture2D(rockColorMap, terrainTexCoord);
    
    // Snow terrain region.
    regionMin = snowRegion.min;
    regionMax = snowRegion.max;
    regionRange = regionMax - regionMin;
    regionWeight = (regionRange - abs(height - regionMax)) / regionRange+0.01;
    regionWeight = (regionWeight < 0.0) ? 0.0 : regionWeight;
    terrainColor += regionWeight * texture2D(snowColorMap, terrainTexCoord);


    return terrainColor;
}

void main()
{   

	vec4 baseColour = GenerateTerrainColor();
	
	
	// Uncompress normal from normal map texture
    vec3 normal = normalize(texture2D(normalMap, gl_TexCoord[5].st).xyz * 2.0 - 1.0);
    // Depending on the normal map's format, the normal's Y direction may have to be inverted to
    // achieve the correct result. This depends - for example - on how the normal map has been
    // created or how it was loaded by the de.schema.schine.engine. If the shader output seems wrong, uncomment
    // this line:
    // normal.y = -normal.y;
   
    // Ambient
    vec4 ambient = light.ambient * baseColour;
    
    // Diffuse
    // Normalize interpolated direction to light
    vec3 tbnNormDirToLight = normalize(tbnDirToLight);
    
    // Full strength if normal points directly at light
    float diffuseIntensity = max(dot(tbnNormDirToLight, normal), 0.0);
    vec4 diffuse = light.diffuse * baseColour * diffuseIntensity;

    // Specular
    vec4 specular = vec4(0.0, 0.0, 0.0, 0.0);
    // Only calculate specular light if light reaches the fragment.
    if (diffuseIntensity > 0.0) {
        // Colour of specular reflection
        vec4 specularColour = texture2D(specularMap, gl_TexCoord[6].st); 
        // Specular strength, Blinn�Phong shading model
        float specularModifier = max(dot(normal, normalize(tbnHalfVector)), 0.0); 
        specular = light.specular * specularColour * pow(specularModifier, shininess);
    }

    // Sum of all lights
    vec4 terrainColor;
    terrainColor = clamp(ambient + diffuse + specular, 0.0, 1.0);
    
    // Use the diffuse texture's alpha value.
    //terrainColor.a = baseColour.a;
	
    
   	terrainColor.xyz = xlat_lib_saturate(terrainColor.xyz);
   	
   	//vec3 color = mix(terrainColor.xyz, Fex.xyz, terrainColor.xyz);
   	//vec3 color = mix(terrainColor.xyz, Lin.xyz, terrainColor.xyz);
   	//color += Fex.xyz;
	//terrainColor += vec4(Fex,1.0);
	//terrainColor /= vec4(Lin,1.0);
	
	terrainColor.xyz *= Fex.xyz;
	vec3 color = mix(terrainColor.xyz, Lin.xyz, distance/50000.0 ).xyz; //50000 is the radius of the sphere
	//color *= Fex.xyz;
	gl_FragColor.xyz = color; //texture2D(dirtColorMap, gl_TexCoord[0].st).xyz;
	gl_FragColor.a = baseColour.a;
}

