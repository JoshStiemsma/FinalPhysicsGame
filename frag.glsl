#define PROCESSING_TEXTURE_SHADER

//properties set automatically by processing
uniform sampler2D texture;
uniform vec2 texOffset;

// properties set by vertex shader
varying vec4 uvs;

uniform Vec2[] highPoints;


//this function is executed for every pixel on the screen
// the primary purpose is to set gl_FragColor for the GPU

void main(){
	//set gl farg color to final color we want to use
	//(R,G,B,A)

	//vec4 color = texture2D(texture, uvs.xy);



//gl_FragColor=color;

}