/*
_______________________________________________________________________

	Title: Make Presentation Image
	Author: Jolyon Troscianko
	Date: 30/06/15
.................................................................................................................

Description:

Multispectral images are displayed as a greyscale stack by default so that any
number of channels can be added. For display purposes it is often desirable
to show colour images for human viewing on monitors and in print.

This tool makes it easy to select how a multispectral image or cone-catch image
should be converted to an RGB colour image.

_________________________________________________________________________
*/

origImage = getImageID();
title = getTitle();
w=getWidth();
h=getHeight();

setBatchMode(true);
sliceNames = newArray(nSlices);
setSlice(1);
for(i=0; i<nSlices; i++){
	setSlice(i+1);
	sliceNames[i] = getInfo("slice.label");
}

outColours = newArray("Red", "Green", "Blue", "Yellow", "Ignore");
transform = newArray("None", "Square Root");


Dialog.create("Colour and False-Colour Image Creator");
	Dialog.addMessage("Select which input channels to use for\neach colour output. For best results\nonly use red, green and blue once each,\nor yellow and blue for dichromats.");
	for(i=0; i<nSlices; i++){
		Dialog.addChoice(replace(sliceNames[i], ":", "_"), outColours, outColours[4]);
	}

	Dialog.addMessage(" \nTransform to make non-linear?");
	Dialog.addChoice("Transform", transform);
	Dialog.addMessage("Remember this image is for presentation\nonly, not for measurements");
	Dialog.addCheckbox("Convert to RGB colour", true);
Dialog.show();

for(i=0; i<nSlices; i++)
	outColours[i] = Dialog.getChoice();

transformChoice = Dialog.getChoice();
rgbColour = Dialog.getCheckbox();

outCount = 0;
for(i=0; i<sliceNames.length; i++)
	if(outColours[i] != "Ignore")
		outCount++;


newImage(title + " - False Colour", "32-bit black", w, h, outCount);
run("Make Composite", "display=Composite");
outImage = getImageID();

setPasteMode("Copy");
min = 0;
max=65535;
if(transformChoice == "Square Root")
	max = 255;

outSlice = 1;
for(i=0; i<sliceNames.length; i++)
	if(outColours[i] != "Ignore"){
		selectImage(origImage);
		setSlice(i+1);
		run("Select All");
		run("Copy");
		selectImage(outImage);
		setSlice(outSlice);
		run("Paste");
		run(outColours[i]);
		if(transformChoice ==  "Square Root")
			run("Square Root", "slice");
		setMinAndMax(min, max);
		outSlice++;
	}//fi

selectImage(outImage);
if(rgbColour==true)
	run("RGB Color");

setBatchMode("show");


