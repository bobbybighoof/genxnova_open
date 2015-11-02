#version 120

#IFDEF shadow
#extension GL_EXT_gpu_shader4: enable
#ELSEIF texarray
#extension GL_EXT_gpu_shader4: enable
#ELSEIF normaltexarray
#extension GL_EXT_gpu_shader4: enable
#ENDIF

#IMPORT data/shader/cube/cubeTextures.glsl


uniform float density;
uniform float selectTime;
uniform float extraAlpha;

#IFDEF virtual
uniform float uTime;
varying vec2 quadVar;
#ENDIF

#IMPORT data/shader/cube/cubeLightVars.glsl

varying vec3 vertexLight;
varying vec4 occlusion;




varying float extraAlphaVert;



#IFDEF lightall
varying float noLight;
#ENDIF
varying float layer;
const float LOG2 = 1.442695;



#IMPORT data/shader/shadow.glsl

vec3 gamma(vec3 color){
    return pow(color, vec3(1.0/2.0));
}
float rand(vec2 co) { 
 	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
} 

vec4 scanline(vec4 oricol, vec4 col, vec2 uv, float uTime){
	 // contrast curve
	   //col.xyz = clamp(col.xyz *0.5 + 0.5 * col.xyz * col.xyz * 1.2,0.0,1.0);
	
	 //vignette
	   //col.xyz *= 0.6 + 0.4*16.0*uv.x*uv.y*(1.0-uv.x*0.01)*(1.0-uv.y*0.01);
	
	 //color tint
	   col.xyz *= vec3(0.83, 1.0, 0.78);
	
	 //scanline (last 2 constants are crawl speed and size)
	 //TODO make size dependent on viewport
	   col.xyz *= 0.8 + 0.2 * sin(4.0 * uTime + uv.y * 100.0);
	
	 //flickering (semi-randomized)
	   col.xyz *= 1.0 - 0.025 * rand(vec2(uTime, tan(uTime)));
	
	 //smoothen
	 //  float comp = smoothstep( 0.2, 0.7, sin(uTime) );
	   //col.xyz = mix( col.xyz, oricol.xyz, clamp(-2.0+2.0*q.x+3.0*comp,0.0,1.0) );
	
		vec4 finalColor = col * oricol*1.6;
		
	   return finalColor;
  }

#IMPORT data/shader/cube/cubeLight.glsl

void main()
{

	bool scanLN = false;
 	float shift = 0.004;
 	vec2 uvScan;
	#IFDEF virtual
		scanLN = true;
		uvScan =  0.5 + (quadVar.st-0.5)*(0.9 + 0.1*sin(0.95*uTime));
	#ELSE
		float uTime = 0.0; //dummy so compiler is ok. Will be removed by compiler anyways
	#ENDIF

	vec4 tex;
	float emissionAndShine = 0.0;
	#IFDEF normaltexarray
		tex = texture2DArray(cTex, vec3(gl_TexCoord[0].st, layer));
		vec3 bump = normalize(texture2DArray(cTexNormal, vec3(gl_TexCoord[0].st, extraAlphVsLayerNoLight.y)).xyz * 2.0 - 1.0); 
	#ELSEIF texarray
		tex = texture2DArray(cTex, vec3(gl_TexCoord[0].st, layer));
	#ELSEIF normalmap
		vec3 bump;
		if(layer <= 0.1){
			if(scanLN){
				vec4 oricol;
   				vec4 col;
   				
				oricol = texture2D(mainTex0, gl_TexCoord[0].st);
				col.r = texture2D(mainTex0,vec2(gl_TexCoord[0].x+shift*uvScan.x,gl_TexCoord[0].y)).x;
				col.g = oricol.g;
				col.b = texture2D(mainTex0,vec2(gl_TexCoord[0].x-shift*uvScan.x,gl_TexCoord[0].y)).z;
				col.a = oricol.a;
				tex = scanline(oricol, col, uvScan, uTime);
			}else{
				tex = texture2D(mainTex0, gl_TexCoord[0].st);
			}
			vec4 bTex = texture2D(normalTex0, gl_TexCoord[0].st);
			bump = (bTex.xyz * 2.0 - 1.0); // from [0, 1] space to [-1,1] 
			emissionAndShine = bTex.a;
		}else if(layer <= 1.5){
			vec4 bTex = texture2D(normalTex1, gl_TexCoord[0].st);
			if(scanLN){
			
				vec4 oricol;
   				vec4 col;
				oricol = texture2D(mainTex1, gl_TexCoord[0].st);
				col.r = texture2D(mainTex1,vec2(gl_TexCoord[0].x + shift*uvScan.x, gl_TexCoord[0].y)).x;
				col.g = oricol.g;
				col.b = texture2D(mainTex1,vec2(gl_TexCoord[0].x - shift * uvScan.x, gl_TexCoord[0].y)).z;
				col.a = oricol.a;
				tex = scanline(oricol, col, uvScan, uTime);
			}else{
				tex = texture2D(mainTex1, gl_TexCoord[0].st);
			}
			bump = (bTex.xyz * 2.0 - 1.0); 
			emissionAndShine = bTex.a;
		}else if(layer <= 2.5){
			vec4 bTex = texture2D(normalTex2, gl_TexCoord[0].st);
			if(scanLN){
				vec4 oricol;
   				vec4 col;
				oricol = texture2D(mainTex2, gl_TexCoord[0].st);
				col.r = texture2D(mainTex2,vec2(gl_TexCoord[0].x+shift*uvScan.x,gl_TexCoord[0].y)).r;
				col.g = oricol.g;
				col.b = texture2D(mainTex2,vec2(gl_TexCoord[0].x-shift*uvScan.x,gl_TexCoord[0].y)).b;
				col.a = oricol.a;
				tex = scanline(oricol, col, uvScan, uTime);
			}else{
				tex = texture2D(mainTex2, gl_TexCoord[0].st);
			}
			bump = (bTex.xyz * 2.0 - 1.0); 
			emissionAndShine = bTex.a;
		}else{
			vec4 bTex = texture2D(normalTex7, gl_TexCoord[0].st);
			if(scanLN){
				vec4 oricol;
   				vec4 col;
				oricol = texture2D(mainTex7, gl_TexCoord[0].st);
				col.r = texture2D(mainTex7,vec2(gl_TexCoord[0].x+shift*uvScan.x,gl_TexCoord[0].y)).r;
				col.g = oricol.g;
				col.b = texture2D(mainTex7,vec2(gl_TexCoord[0].x-shift*uvScan.x,gl_TexCoord[0].y)).b;
				col.a = oricol.a;
				tex = scanline(oricol, col, uvScan, uTime);
			}else{
				tex = texture2D(mainTex7, gl_TexCoord[0].st);
			}
			bump = (bTex.xyz * 2.0 - 1.0); 
			emissionAndShine = bTex.a;
		}
	#ELSE
		if(layer <= 0.1){
			if(scanLN){
				vec4 oricol;
   				vec4 col;
				oricol = texture2D(mainTex0, gl_TexCoord[0].st);
				col.r = texture2D(mainTex0,vec2(gl_TexCoord[0].x+shift*uvScan.x,gl_TexCoord[0].y)).x;
				col.g = oricol.g;
				col.b = texture2D(mainTex0,vec2(gl_TexCoord[0].x-shift*uvScan.x,gl_TexCoord[0].y)).z;
				col.a = oricol.a;
				tex = scanline(oricol, col, uvScan, uTime);
			}else{
				tex = texture2D(mainTex0, gl_TexCoord[0].st);
			}
		}else if(layer <= 1.5){
			if(scanLN){
				vec4 oricol;
   				vec4 col;
				oricol = texture2D(mainTex1, gl_TexCoord[0].st);
				col.r = texture2D(mainTex1,vec2(gl_TexCoord[0].x+shift*uvScan.x,gl_TexCoord[0].y)).x;
				col.g = oricol.g;
				col.b = texture2D(mainTex1,vec2(gl_TexCoord[0].x-shift*uvScan.x,gl_TexCoord[0].y)).z;
				col.a = oricol.a;
				tex = scanline(oricol, col, uvScan, uTime);
			}else{
				tex = texture2D(mainTex1, gl_TexCoord[0].st);
			}
		}else if(layer <= 2.5){
			if(scanLN){
				vec4 oricol;
   				vec4 col;
				oricol = texture2D(mainTex2, gl_TexCoord[0].st);
				col.r = texture2D(mainTex2,vec2(gl_TexCoord[0].x+shift*uvScan.x,gl_TexCoord[0].y)).x;
				col.g = oricol.g;
				col.b = texture2D(mainTex2,vec2(gl_TexCoord[0].x-shift*uvScan.x,gl_TexCoord[0].y)).z;
				col.a = oricol.a;
				tex = scanline(oricol, col, uvScan, uTime);			
			}else{
				tex = texture2D(mainTex2, gl_TexCoord[0].st);
			}
		}else{
			if(scanLN){
				vec4 oricol;
   				vec4 col;
				oricol = texture2D(mainTex7, gl_TexCoord[0].st);
				col.r = texture2D(mainTex7,vec2(gl_TexCoord[0].x+shift*uvScan.x,gl_TexCoord[0].y)).x;
				col.g = oricol.g;
				col.b = texture2D(mainTex7,vec2(gl_TexCoord[0].x-shift*uvScan.x,gl_TexCoord[0].y)).z;
				col.a = oricol.a;
				tex = scanline(oricol, col, uvScan, uTime);
			}else{
				tex = texture2D(mainTex7, gl_TexCoord[0].st);
			}
		}
	#ENDIF
	
	//tex = vec4(0.5,0.5,0.5,1.0); //uncomment this for greyscale
	
	float shininess = 30.0;
	float emission = 0.0;
	float specular = 1.0;
	#IFDEF noemission
		emissionAndShine = 0.0;
	#ELSE
		if(emissionAndShine > 0.5){
			emission = ((emissionAndShine - 0.5) * 2.0);
			specular = 0.0;
		}else{
			specular = max(0.0, (emissionAndShine * 2.0));
			emission = 0.0;
		}
	#ENDIF
	
	
	
	float alphMod = extraAlphaVert+(extraAlpha * ( tex.a));
	
	#IFDEF blended
	if(alphMod < 0.11){
		discard;
	}
	#ENDIF

	vec4 oTex;
	vec4 oreTex;
	
	
	
	#IFDEF texarray
		oTex = texture2DArray(cTex, vec3(gl_TexCoord[1].st, 3.0));
		oreTex = texture2DArray(cTex, vec3(gl_TexCoord[2].st, 3.0));
		
		shininess = max(1.0, texture2D(cTex, vec2(layer*0.25 + gl_TexCoord[0].s*0.25, 0.125 + gl_TexCoord[0].t*0.25 ), 3.0).r*1024.0);
	#ELSE
		oTex = texture2D(overlayTex, gl_TexCoord[1].st);
		oreTex = texture2D(overlayTex, gl_TexCoord[2].st);
		
		shininess = max(1.0, texture2D(overlayTex, 
		vec2(
			layer * 0.25 + 0.25 * fract(gl_TexCoord[0].x), 
			0.125 + 0.25 * fract(gl_TexCoord[0].y))
			).g*1024.0);
			
	#ENDIF
	
	
	
	
	#IFDEF blended
	vec4 mixTex = mix(tex , oTex, oTex.a);
	#ELSEIF vertexLighting
	//TODO: optimize for LoD
		vec4 mixTexOre = mix(tex , oreTex, oreTex.a);
		vec4 mixTex = mix(mixTexOre , oTex, oTex.a);
	#ELSE
	vec4 mixTexOre = mix(tex , oreTex, oreTex.a);
	vec4 mixTex = mix(mixTexOre , oTex, oTex.a);
	#ENDIF
	
	vec4 lightedColor;
	
	#IFDEF lightall
	if(noLight > 0.0001){
		lightedColor.xyz = vertexLight.xyz * mixTex.xyz;
	}else{
	#ENDIF
	
	
	
	#IFDEF vertexLighting
		lightedColor.xyz = vertexLight.xyz * mixTex.xyz;
	#ELSEIF normaltexarray
		lightedColor.xyz = calculateLight( shininess, specular, mixTex, occlusion, gl_TexCoord[0].st, bump);
	#ELSEIF normalmap
		float dist = length(viewDirection);
		
		lightedColor.xyz = calculateLight( shininess, specular, mixTex, occlusion, gl_TexCoord[0].st, bump);
		if(dist >= 80.0){
			float p = (96.0-dist)*0.0625; // div 16
			vec3 vertexLight = vertexLight.xyz * mixTex.xyz;
			
			lightedColor.xyz = mix(vertexLight, lightedColor.xyz, max(0.0, p));
		}
	#ELSE
		lightedColor.xyz = calculateLight( shininess, specular, mixTex, occlusion, gl_TexCoord[0].st);
	#ENDIF
		
	
	#IFDEF lightall
	}
	#ENDIF
	
	#IFDEF blended
		lightedColor.a = alphMod;
	#ELSE
		lightedColor.a = 1.0;
	#ENDIF
	
	if (selectTime > 0) {
		lightedColor.rgb += (sin(selectTime / 100.0) + 1.0) * 0.125;
	}
	
	
	gl_FragColor = lightedColor;
	
	#IFDEF shadow
		float shadow_coef = occlusion.w*(1.0-shadowCoef());
		
		
		//shadow_coef += occLight;
		gl_FragColor.rgb = gl_FragColor.rgb * min(1.0, ((1.0-shadow_coef)+0.17))*1.2;
	#ENDIF
	
	#IFDEF nospotlights
		gl_FragColor.rgb = max(emission*mixTex.rgb, gl_FragColor.rgb );
	#ELSEIF vertexLighting
		gl_FragColor.rgb = max(emission*mixTex.rgb, gl_FragColor.rgb );
	#ELSEIF normaltexarray
		vec3 spot = vec3(0.0);
		for(int i = 1; i <= spotCount; i++){
		
			vec3 lightDirSpot =  gl_LightSource[i].position.xyz - (vPos).xyz;
			
			float d = length(lightDirSpot);
			
			float spotAtt = min(1.0, 1.0 / ( gl_LightSource[i].constantAttenuation + 
			(gl_LightSource[i].linearAttenuation*d) + 
			(0.02*d*d) ));
		
			spot += spotLight( shininess, mixTex, gl_TexCoord[0].st, lightDirSpot, spotAtt, i, bump);
		}
		spot = clamp(spot, 0.0, 1.0);
		gl_FragColor.rgb = max(emission*mixTex.rgb, gl_FragColor.rgb + spot);
	#ELSEIF normalmap
		vec3 spot = vec3(0.0);
		for(int i = 1; i <= spotCount; i++){
			vec3 lightDirSpot =  gl_LightSource[i].position.xyz - (vPos).xyz;
			
			float d = length(lightDirSpot);
			
			float spotAtt = min(1.0, 1.0 / ( gl_LightSource[i].constantAttenuation + 
			(gl_LightSource[i].linearAttenuation*d) + 
			(0.02*d*d) ));
			spot += spotLight( shininess, mixTex, gl_TexCoord[0].st, lightDirSpot, spotAtt, i, bump);
		}
		spot = clamp(spot, 0.0, 1.0);
		gl_FragColor.rgb = max(emission*mixTex.rgb, gl_FragColor.rgb + spot);
	#ELSE
		vec3 spot = vec3(0.0);
		for(int i = 1; i <= spotCount; i++){
			vec3 lightDirSpot =  gl_LightSource[i].position.xyz - (vPos).xyz;
			
			float d = length(lightDirSpot);
			
			float spotAtt = min(1.0, 1.0 / ( gl_LightSource[i].constantAttenuation + 
			(gl_LightSource[i].linearAttenuation*d) + 
			(0.02*d*d) ));
			spot += spotLight( shininess, mixTex, gl_TexCoord[0].st, lightDirSpot, spotAtt, i);
		}
		spot = clamp(spot, 0.0, 1.0);
		gl_FragColor.rgb = max(emission*mixTex.rgb, gl_FragColor.rgb + spot);
	#ENDIF
	//gl_FragColor.rgb = vec3(shininess/1024.0);
}