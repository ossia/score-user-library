/*{
	"CREDIT": "ossia score",
	"ISFVSN": "2",
	"DESCRIPTION": "Copy the input texture without changes",
	"CATEGORIES": [
		"Utility"
	],
	"INPUTS": [
		{
			"NAME": "inputImage",
			"TYPE": "image"
		}
	]
}*/

void main() {
	gl_FragColor = IMG_THIS_PIXEL(inputImage);
}