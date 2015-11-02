#version 120

#IFDEF shadow
#extension GL_EXT_gpu_shader4: enable
#ELSEIF texarray
#extension GL_EXT_gpu_shader4: enable
#ELSEIF normaltexarray
#extension GL_EXT_gpu_shader4: enable
#ENDIF

#IMPORT data/shader/cube/cubeTextures.glsl

#IMPORT data/shader/cube/cubeLightVars.glsl

#IMPORT data/shader/cube/cubeLight.glsl



uniform float texMult;
varying float layer;
varying float lifeTimeAlpha;


#IMPORT data/shader/shadow.glsl

void main()
{
	vec4 occlusion = vec4(0.0,0.0,0.0,0.99);
	vec4 tex;
	
	float shininess = 30.0;
	#IFDEF normaltexarray
		tex = texture2DArray(cTex, vec3(gl_TexCoord[0].xy, layer));
		vec3 bump = normalize(texture2DArray(cTexNormal, vec3(gl_TexCoord[0].xy, layer)).xyz * 2.0 - 1.0); 
	#ELSEIF texarray
		tex = texture2DArray(cTex, vec3(gl_TexCoord[0].xy, layer));
	#ELSEIF normalmap
		vec3 bump;
		if(layer == 0.0){
			tex = texture2D(mainTex0, gl_TexCoord[0].xy);
			bump = normalize(texture2D(normalTex0, gl_TexCoord[0].xy).xyz * 2.0 - 1.0); 
		}else if(layer <= 1.5){
			tex = texture2D(mainTex1, gl_TexCoord[0].xy);
			bump = normalize(texture2D(normalTex1, gl_TexCoord[0].xy).xyz * 2.0 - 1.0); 
		}else if(layer <= 2.5){
			tex = texture2D(mainTex2, gl_TexCoord[0].zw);
			bump = normalize(texture2D(normalTex2, gl_TexCoord[0].zw).xyz * 2.0 - 1.0); 
		}else{
			tex = texture2D(mainTex7, gl_TexCoord[0].zw);
			bump = normalize(texture2D(normalTex7, gl_TexCoord[0].zw).xyz * 2.0 - 1.0); 
		}
	#ELSE
		if(layer == 0.0){
			tex = texture2D(mainTex0, gl_TexCoord[0].xy);
		}else if(layer <= 1.5){
			tex = texture2D(mainTex1, gl_TexCoord[0].xy);
		}else if(layer <= 2.5){
			tex = texture2D(mainTex2, gl_TexCoord[0].zw);
		}else{
			tex = texture2D(mainTex7, gl_TexCoord[0].zw);
		}
	#ENDIF
	
	float specular = 1.0;
	
	
	
	#IFDEF normaltexarray
		vec4 lightedColor = vec4(calculateLight( shininess, specular, tex, occlusion, gl_TexCoord[0].xy, bump),1.0);
	#ELSEIF normalmap
		vec4 lightedColor = vec4(calculateLight( shininess, specular, tex, occlusion, gl_TexCoord[0].xy, bump),1.0);
	#ELSE
		vec4 lightedColor = vec4(calculateLight( shininess, specular, tex, occlusion, gl_TexCoord[0].xy),1.0);
	#ENDIF
	
	gl_FragColor = lightedColor;
	
	#IFDEF shadow
		float shadow_coef = occlusion.w*(1.0-shadowCoef());
		
		
		//shadow_coef += occLight;
		gl_FragColor.rgb *=  min(1.0, ((1.0-shadow_coef)+0.17))*1.2;
	#ENDIF
	
	gl_FragColor.a *= lifeTimeAlpha;
}