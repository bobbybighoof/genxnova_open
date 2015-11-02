#IFDEF normaltexarray
//calculates tangent space matrix from normal, vector in plane and texture coordinates 
//needs normalized normal and position! 

mat3 computeTangentFrame(vec3 normal, vec3 position, vec2 texCoord) { 
	vec3 dpx = dFdx(position); 
	vec3 dpy = dFdy(position); 
	vec2 dtx = dFdx(texCoord); 
	vec2 dty = dFdy(texCoord); 
	//vec3 tangent = normalize(dpx * dty.t - dpy * dtx.t); 
	//vec3 binormal = normalize(-dpx * dty.s + dpy * dtx.s); 

	vec3 tangent = normalize(dpy * dtx.t - dpx * dty.t); 
	vec3 binormal = cross(tangent, normal);

	return mat3(tangent, binormal, normal); 
}
#ELSEIF normalmap


mat3 computeTangentFrame(vec3 normal, vec3 position, vec2 texCoord) { 
	vec3 dpx = dFdx(position); 
	vec3 dpy = dFdy(position); 
	vec2 dtx = dFdx(texCoord); 
	vec2 dty = dFdy(texCoord); 
	//vec3 tangent = normalize(dpx * dty.t - dpy * dtx.t); 
	//vec3 binormal = normalize(-dpx * dty.s + dpy * dtx.s); 

	vec3 tangent = normalize(dpy * dtx.t - dpx * dty.t); 
	vec3 binormal = cross(tangent, normal);



	return mat3(tangent, binormal, normal); 
}

/*
mat3 computeTangentFrame(vec3 n_obj_i, vec3 pw_i, vec2 tc_i) { 
	// compute derivations of the world position
	vec3 p_dx = dFdx(pw_i);
	vec3 p_dy = dFdy(pw_i);
	// compute derivations of the texture coordinate
	vec2 tc_dx = dFdx(tc_i);
	vec2 tc_dy = dFdy(tc_i);
	// compute initial tangent and bi-tangent
	vec3 t = normalize( tc_dy.y * p_dx - tc_dx.y * p_dy );
	vec3 b = normalize( tc_dy.x * p_dx - tc_dx.x * p_dy ); // sign inversion
	// get new tangent from a given mesh normal
	vec3 n = normalize(n_obj_i);
	vec3 x = cross(n, t);
	t = cross(x, n);
	t = normalize(t);
	// get updated bi-tangent
	x = cross(b, n);
	b = cross(n, x);
	b = normalize(b);
	mat3 tbn = mat3(t, b, n);
	
	return tbn;
}
*/
#ENDIF



//const float shininess = 30.0;
//const float attenuation = 1.1;

#IFDEF normaltexarray
vec3 calculateLight(float shininess, float specular, vec4 diffuse, vec4 occlusionVec, vec2 tCords, vec3 bump){
#ELSEIF normalmap
vec3 calculateLight(float shininess, float specular, vec4 diffuse, vec4 occlusionVec, vec2 tCords, vec3 bump){
#ELSE
vec3 calculateLight(float shininess, float specular, vec4 diffuse, vec4 occlusionVec, vec2 tCords){
#ENDIF
	vec3 nView = normalize(viewDirection);
	#IFDEF normaltexarray
		mat3 TBN = computeTangentFrame(normalVec, nView, tCords);
		vec3 normalDirection = normalize(TBN * bump);
	#ELSEIF normalmap
		mat3 TBN = computeTangentFrame(normalVec, nView, tCords);
		vec3 normalDirection = normalize(TBN * bump );
	#ELSE
		vec3 normalDirection = normalVec;
	#ENDIF
	
  	vec3 lDir = lightDir;
  	vec3 norm = normalDirection;
	float nDotL =  dot(norm, lDir);
  	if (nDotL <= 0.0) // light source on the wrong side?
    {
      	return (0.45 * diffuse.rgb * (occlusionVec.xyz * 3.5 + occlusionVec.w)).xyz; //0.45 is ambient
    }
  	else // light source on the right side
    {
    
	    vec3 lightDiffuse = vec3(1.4 * occlusionVec.w);
		vec3 lightSpecular = vec3((occlusionVec.w*occlusionVec.w) * (diffuse.rgb)) * specular;
		lightSpecular.rg *= 2.20;
		lightSpecular.b *= 1.60;
		
    	vec3 diffuseReflection = 1.1 * lightDiffuse * diffuse.rgb * nDotL; //attenuation is 1.1
	
		vec3 specularReflection = 1.1 * lightSpecular * 0.45 //attenuation is 1.1, diffuse is 0.45 
        	* pow(max(0.0, dot(reflect(-lDir, norm), nView)), shininess); //shininess is 30.0
        
        return (0.45 * diffuse.rgb * (occlusionVec.xyz * 3.5 + occlusionVec.w)).xyz + diffuseReflection.xyz + specularReflection.xyz;
    }
	
}


const float cos_outer_cone_angle = 0.95; // 36 degrees

#IFDEF normaltexarray
vec3 spotLight (float shininess, vec4 diffuse, vec2 tCords, vec3 lDir, float att, int lightIndex, vec3 bump){
#ELSEIF normalmap
vec3 spotLight (float shininess, vec4 diffuse, vec2 tCords, vec3 lDir, float att, int lightIndex, vec3 bump){
#ELSE
vec3 spotLight (float shininess, vec4 diffuse, vec2 tCords, vec3 lDir, float att, int lightIndex){
#ENDIF

	vec3 nView = normalize(viewDirection);
	#IFDEF normaltexarray
		vec3 localCoords = bump;
		mat3 TBN = computeTangentFrame(normalVec, nView, tCords);
		vec3 normalDirection = normalize(TBN * localCoords);
	#ELSEIF normalmap
		vec3 localCoords = bump;
		mat3 TBN = computeTangentFrame(normalVec, nView, tCords);
		vec3 normalDirection = normalize(TBN * localCoords);
	#ELSE
		vec3 normalDirection = normalVec;
	#ENDIF

	/*
	vec4 final_color =
	(gl_FrontLightModelProduct.sceneColor * gl_FrontMaterial.ambient) +
	(gl_LightSource[lightIndex].ambient * gl_FrontMaterial.ambient);
	*/
	vec4 final_color = vec4(0.0);//(gl_LightSource[lightIndex].ambient * 0.0) * att; //0.0 is ambient

	vec3 L = normalize(lDir);
	vec3 D = normalize(gl_LightSource[lightIndex].spotDirection);

	float cos_cur_angle = dot(-L, D);

	float cos_inner_cone_angle = 0.9;//gl_LightSource[lightIndex].spotCosCutoff;

	float cos_inner_minus_outer_angle = 
	      cos_inner_cone_angle - cos_outer_cone_angle;
	
	//****************************************************
	// Don't need dynamic branching at all, precompute 
	// falloff(i will call it spot)
	float spot = 0.0;
	spot = 1.0-clamp((cos_cur_angle - cos_outer_cone_angle) / 
	       cos_inner_minus_outer_angle, 0.0, 1.0);
	//****************************************************

	vec3 N = normalize(normalDirection);

	float lambertTerm = max( dot(N,L), 0.0);
	if(lambertTerm > 0.0)
	{
		/*final_color += gl_LightSource[lightIndex].diffuse *
			gl_FrontMaterial.diffuse *
			lambertTerm * spot;
		*/
		//final_color += gl_LightSource[lightIndex].diffuse * diffuse *
		//	lambertTerm * spot * att;
		final_color += vec4(1.2,1.2,1.2,1) * diffuse *
			lambertTerm * spot * att;
		

		vec3 E = nView;
		vec3 R = reflect(-L, N);

		float specular = pow( max(dot(R, E), 0.0), shininess); //8.0 is material specular

		/*final_color += gl_LightSource[lightIndex].specular *
			gl_FrontMaterial.specular *
			specular * spot;
		*/
		//final_color += gl_LightSource[lightIndex].specular *
		//	specular * spot * att;
		final_color += vec4(0.3,0.3,0.3,1) *
		 specular * spot * att;
	}
	return final_color.xyz;
}