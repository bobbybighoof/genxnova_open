#version 120

uniform sampler2D barTex;
uniform float filled;
uniform float glowIntensity;
uniform vec4 barColor;
uniform float maxTexCoord;
uniform float minTexCoord;


void main()
{

	vec2 tc = vec2(gl_TexCoord[0].xy);
	vec2 tcFill = vec2(gl_TexCoord[0].x+0.25, gl_TexCoord[0].y);
	vec2 tcGlow = vec2(gl_TexCoord[0].x+0.5, gl_TexCoord[0].y);
	vec4 back = texture2D(barTex, tc);
	
	vec4 fill = texture2D(barTex, tcFill);

	vec4 glow = texture2D(barTex, tcGlow);
	
	float diff = maxTexCoord - minTexCoord;
	float perc = (1.0-filled) * diff;
	
	vec4 bar = glow*glowIntensity*barColor*2.0;
	
		bar = vec4(back*barColor);
		
		if(gl_TexCoord[0].y > minTexCoord+perc){
			bar = (fill*barColor);
		}
	
	


	gl_FragColor = bar;
}