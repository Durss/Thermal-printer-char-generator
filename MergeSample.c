//This code shows you how to make use of the "zones" feature to merge
//one zone inside another bitmap at a specific coordinates.

//byte arrays must *not* be set as "const PROGMEM" !
//imageSource_data	: source image in which an image should be injected
//imageSource_width	: width of the image source
//inject_data		: data of the image to be injected
//zone_byteOffset	: byte index of the zone where to start the injection
//zone_bitSubOffset	: bit index of the byte
//injectWidth		: width of the image to be injected

//Copy the image's source to a new array
uint8_t clone[ sizeof(imageSource_data) ];
memcpy(clone, (int8_t *)&imageSource_data, sizeof(imageSource_data));

//Inject our "inject_data" bytes into the cloned array
mergeImages(clone, imageSource_width, inject_data, sizeof(inject_data), zone_byteOffset, zone_bitSubOffset, injectWidth);

//Print the merged images.
printer.printBitmap(imageSource_width, imageSource_height, clone, false);

//Free memory
free( clone );

//Injects a byte array inside another one.
//source		: image source
//srcW			: width of the source image
//toMerge		: image to inject inside the "source" image
//mergeSize		: size of the injected image's byte array
//byteOffset	: byte at which start the injection
//bitSubOffset	: bit index of the byte to start the injection at.
//bitWidth		: width of the injected image.
void mergeImages(uint8_t source[], int srcW, uint8_t toMerge[], int mergeSize, int byteOffset, int bitSubOffset, int bitWidth) {
	int bitMask; int data; int index;
	int leftOffset = ceil(((byteOffset*8) % srcW + (7-bitSubOffset))/8) - 1;
	int rightOffset = ceil((srcW-(leftOffset*8 + bitWidth))/8);
	int len = mergeSize + (bitSubOffset != 7? 1 : 0);
	for(int i = 0; i < len; i++) {
		//Draw low bits
		bitMask	= (0xff >> (7-bitSubOffset)) & 0xff;
		index	= byteOffset + i + (leftOffset + rightOffset) * floor(i/(bitWidth/8));
		data	= (toMerge[i] >> (7-bitSubOffset)) & bitMask;
		source[ index ] |= data;
		
		//Draw high bits
		bitMask	= (0xff << (bitSubOffset + 1)) & 0xff;
		index	= byteOffset + i + (leftOffset + rightOffset) * floor(i/(bitWidth/8));
		if(i%(bitWidth/8)==0)index -=(leftOffset + rightOffset);//...?
		data	= (toMerge[i-1] << (bitSubOffset + 1)) & bitMask;
		source[ index ] |= data;	
	}
}