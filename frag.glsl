#define PROCESSING_TEXTURE_SHADER

//properties set automatically by processing
uniform sampler2D texture;
uniform vec2 texOffset;

// properties set by vertex shader
varying vec4 uvs;
varying vec4 vertTexCoord;
varying vec4 vertColor;

uniform float highPoints[];
uniform float lowPoints[];
uniform sampler2D canvas;


//this function is executed for every pixel on the screen
// the primary purpose is to set gl_FragColor for the GPU

void main(){
	//set gl farg color to final color we want to use
	//(R,G,B,A)
	vec2 uv = vertTexCoord.xy;

	vec4 color = texture2D(texture, uvs.xy);
if(uv.y>highPoints[uv.x]){
vec4 color =  vec4 (0,0,255,0);

}


gl_FragColor=color;

}