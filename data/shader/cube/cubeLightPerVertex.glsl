




	uniform vec3 specular = vec3(0.45,0.45,0.45);
	uniform vec4 zo = vec4(0.0, 0.0, 0.0, 1.0);
	uniform vec3 daa =  vec3(1.4,1.4,1.4);
	uniform vec3 dsa = vec3(2.20,2.20,1.60);
	uniform vec3 ambient = vec3(0.45,0.45,0.45);
	uniform vec3 diffuse = vec3(1.0,1.0,1.0);

vec3 vertexLightFunc(vec3 normalVec, vec3 lightDir, vec3 pos, vec3 viewDirection, vec4 occlusionVec){

	vec3 normalDirection = normalVec;
	
  	
	float nDotL =  dot(normalDirection, lightDir);
	
	 
  	if (nDotL <= 0.0) // light source on the wrong side?
    {
      	return (ambient * diffuse.rgb * (occlusionVec.xyz * 3.5 + occlusionVec.w)).xyz;
    }
  	else // light source on the right side
    {
    
	    vec3 lightDiffuse = daa * occlusionVec.w; ;	
		vec3 lightSpecular = dsa * occlusionVec.w*occlusionVec.w * (diffuse.rgb);
		
    	vec3 diffuseReflection = 1.1 * lightDiffuse * diffuse.rgb * nDotL; //1.1 = attenuation
	
		vec3 specularReflection =  1.1 * lightSpecular * specular
        	* pow(max(0.0, dot(reflect(-lightDir, normalDirection), normalize(viewDirection))), 30.0); //30 = shininess, 1.1 = attenuation
        
        return (ambient * diffuse.rgb * (occlusionVec.xyz * 3.5 + occlusionVec.w)).xyz + diffuseReflection.xyz + specularReflection.xyz;
    }
}



