/*
_______________________________________________________________________

	Title: Conver to Cone Catch
	Author: Jolyon Troscianko
	Date: 16/10/2014
.................................................................................................................

Description:
''''''''''''''''''''''''''''''''
This code converts a multispectral image file into cone-catch quanta.

Instructions:
''''''''''''''''''''''''''''''''''''''''
Load a multispectral image file (must be 32-bit, normalised and aligned), run
the code and select the camera and visual system combinaiton you want.
_________________________________________________________________________
*/


title = getTitle();

if(bitDepth() != 32)
	exit("Requires a 32-bit normalised image");

// LISTING CONE CATCH MODELS

	modelPath = getDirectory("plugins")+"Cone Models";

	modelList=getFileList(modelPath);

	modelNames = newArray();

	for(i=0; i<modelList.length; i++){
		if(endsWith(modelList[i], ".class")==1)
			modelNames = Array.concat(modelNames,replace(modelList[i],".class",""));
		if(endsWith(modelList[i], ".CLASS")==1)
			modelNames = Array.concat(modelNames,replace(modelList[i],".CLASS",""));
	}
	
	for(i=0; i<modelNames.length; i++)
		modelNames[i] = replace(modelNames[i], "_", " ");


// IMAGE PROCESSING SETTINGS

	Dialog.create("Convert Image to Cone Catch");
		Dialog.addMessage("Select the visual system to use:");
		Dialog.addChoice("Model", modelNames);
	Dialog.show();

	visualSystem = Dialog.getChoice();
	//visualSystem = replace(visualSystem, "_", " ");

	run(visualSystem);
	setMinAndMax(0, 65535);

rename(title + " " + visualSystem);


