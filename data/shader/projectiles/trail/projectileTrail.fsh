#version 120

uniform sampler2D tex;
uniform float time;
uniform vec4 trailColor;
void main()
{
	vec4 color = texture2D(tex,   vec2(gl_TexCoord[0].x, gl_TexCoord[0].z+time*0.5));
	
	float tt = abs(gl_TexCoord[0].s - 0.5);
	
	float alpha = pow(max(0.0,(0.5-tt)), 1.2) * 5.0;
	
		
	float p = min(1.0, pow(gl_TexCoord[0].t , 0.8));
	float p2 = min(1.0, pow(1.0-gl_TexCoord[0].t, 1.4) * 10.0);
	
	alpha *= p*p2;//max(0.0,(alpha - (p)));
	//alpha *= p2;
	
	
	if(alpha < 0.1){
		discard;
	}
	alpha -= 0.1;
	color *= 2.0;
	gl_FragColor =  vec4(color.x,color.y,color.z, alpha) * trailColor;//vec4(1,1,1,0.5f);
}