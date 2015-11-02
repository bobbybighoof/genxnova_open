#version 120
#IFDEF shader4
#extension GL_EXT_gpu_shader4: enable
#ENDIF

const float tiling = 0.0625;
const float tilingH = 0.03;
const float adi = 0.00485;

varying vec2 mainTexCoords;
varying float textureIndex;

uniform int animationTime;

uniform vec3 normals[7];
uniform vec3 quadPosMark[6];

void main()
{

	vec3 specC = vec3(2.9);
	#IFDEF shader4
	
	int indexInfo = int(gl_Vertex.x);
	float vIndex = float((indexInfo ) & 4095);


	
	int info = int(gl_Vertex.y);
	
	float vertNumCodeE = float(info & 3);
	
	int sideId =  (info >> 2) & 7; // /4.0
	
	float layerE =  float((info >> 5) & 15);
	
	float typeE =  float((info >> 9) & 255) ;
	
	//float hitPointsE =  float((info >> 17) & 7) ;
	
	//float animatedE = float((info >> 20) & 1);
	
	float extFlag =  float(info >> 21);
	
	
	int normalIndex = sideId;
	vec3 qpm = quadPosMark[normalIndex];
	
	
	#ELSE


	float colorInfoX = gl_Vertex.x;
	
	
	float blue =  floor(colorInfoX / 1048576.0);
	colorInfoX -= blue * 1048576.0;
	
	float green =  floor(colorInfoX / 65536.0);
	colorInfoX -= green * 65536.0;
	
	float red =  floor(colorInfoX / 4096.0);
	colorInfoX -= red * 4096.0;
	
	float vIndex = floor(colorInfoX);
	

	float texInfoY = gl_Vertex.y;
	
	float extFlag =  floor(texInfoY / 2097152.0);
	texInfoY -= extFlag * 2097152.0;
	
	float animatedE =  floor(texInfoY / 1048576.0);
	texInfoY -= animatedE * 1048576.0;
	
	float hitPointsE =  floor(texInfoY / 131072.0) ;
	texInfoY -= hitPointsE * 131072.0;
	
	float typeE =  floor(texInfoY / 512.0) ;
	texInfoY -= typeE * 512.0;
	
	float layerE =  floor(texInfoY * 0.03125) ; // / 32.0
	texInfoY -= layerE * 32.0;
	
	float sideId =  (floor(texInfoY * 0.25)); // /4.0
	texInfoY -= sideId * 4.0;
	
	float vertNumCodeE = (floor(texInfoY));
	
	int normalIndex = int(sideId);
	vec3 qpm = quadPosMark[normalIndex];
	
	#ENDIF
	
	
	
	
	
	float oreOverlayE = 0;
	float occE = 0;
	
	
	float inside = 0.5;
	
	float posInfoZ = gl_Vertex.z;
	
	float zPos = floor(posInfoZ / 65536.0); 
	posInfoZ = posInfoZ - (zPos * 65536.0);
	float yPos = floor(posInfoZ * 0.00390625); //divided by 256 
	float xPos = ( posInfoZ - (yPos * 256)); 
	
	
	
	float sInfoW = gl_Vertex.w;
	
	
	occE =  floor(sInfoW / 65536.0) ; //32768.0, 65536.0, 131072.0, 262144.0
	
	sInfoW -= occE * 65536.0;
	
	oreOverlayE =  floor(sInfoW / 1024.0) ;
	
	sInfoW -= oreOverlayE * 1024.0;
	
	
	float normalModeE =  sInfoW;
	
	
	
	vec3 normalPos = normals[normalIndex+1];
	/*
	if(normalModeE == 0){
		vec3 normal = normalPos;
	}else{
		float nAf = (floor(normalModeE * 0.015625)); // div by 64.0
		normalModeE -= nAf*64.0;
		
		float nBf = (floor(normalModeE * 0.125)); // div by 8.0
		normalModeE -= nBf*8.0;
		
		float nCf = normalModeE; 
		
		int nA = int(nAf);
		int nB = int(nBf);
		int nC = int(nCf);
		
		vec3 com = normals[nA]  + normals[nB] + normals[nC];
		vec3 normal = normalize(com);
	}
	*/
	
	float type = typeE;

	vec2 texCoords;
	
	float mVertNum = (vertNumCodeE) * 0.25;
	float mTex = (extFlag) * 0.25;
	
	
	
	
	
	textureIndex = layerE;		
	
	
	
	//type += animatedE * animationTime;
	
	
	
	float xIndex = mod(type, 16.0);
	float yIndex = floor(type * 0.0625 ); // / 16.0
	
	
	
	
	
	
	vec2 quad = vec2(
			mod(floor(mTex * (2.0)), 2.0), 
			mod(floor(mTex * (4.0)), 2.0)
			);
	//either 0,0; 0,1; 1,1; 1,0
	
	
	
	
	 //8,8,8 = 8736
	float z = floor(vIndex * 0.00390625); //divided by 256
	vIndex -= z * 256.0;
	float y = floor(vIndex * 0.0625);
	vIndex -= y * 16.0;
	float x = vIndex;
	
	
	vec3 vertexPos = vec3(x-8.0, y-8.0, z-8.0);
	
	
	
	
	float xP = ((1.0 - abs(normalPos.x)) * -0.5) + mod(floor(mVertNum * qpm.x), 2.0);
	float yP = ((1.0 - abs(normalPos.y)) * -0.5) + mod(floor(mVertNum * qpm.y), 2.0);
	float zP = ((1.0 - abs(normalPos.z)) * -0.5) + mod(floor(mVertNum * qpm.z), 2.0);
	
	vertexPos += vec3(xP,yP,zP) + (normalPos * inside);	
	
	
	
	
	vec2 adip = vec2(
	((1.0 -((quad.x)*adi)) + (abs(quad.x - 1.0)*adi)), 
	((1.0 -((quad.y)*adi)) + (abs(quad.y - 1.0)*adi)));
	
	texCoords = vec2(quad.x *tiling, quad.y *tiling );

	
	
	vec2 vcord = vec2(texCoords.x, texCoords.y);
	
	
	
	mainTexCoords.xy = vec2( texCoords.x + tiling * xIndex, texCoords.y + tiling * yIndex);
	
		vertexPos.x += (xPos - 128.0) * 16.0;
		vertexPos.y += (yPos - 128.0) * 16.0;
		vertexPos.z += (zPos - 128.0) * 16.0;
	
	
	mainTexCoords.xy += adip;
	
	//note: this is a directional light! 

	
	
	gl_Position =  gl_ModelViewProjectionMatrix * vec4(vertexPos,1.0);
	
}
