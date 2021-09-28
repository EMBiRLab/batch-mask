/*
_______________________________________________________________________

	Title: Generate Multispectral Image
	Author: Jolyon Troscianko
	Date: 16/10/2014
.................................................................................................................

Description:
''''''''''''''''''''''''''''''''
This code generates multispectral images that are linear, normalised and aligned from
any combination of photos and filters. These images can be used for analysis directly,
or used for converting to animal cone-catch quanta.

As long as none of the photos are over-exposed, the processing will not result in data
loss when measuring reflectances above 100% relative to the standard (which is
common with shiny objects, or when the standard isn't as well lit as other parts of the
image). This is because all images are opened and processed as 32-bit floating point
straight from the RAW files, so no (very)large intermediate TIFF images ever need to be
saved.

Using two or more standards (or one standard with black point estimates) overcomes
the problem of the unknown black point of the camera sensor, making the method
robust in the field with various factors reducing contrast.

Photographing through reflective surfaces, or through slightly opaque media is also
made possible by using two or more grey standards. This allows photography through
water from the air (as long as the reflected sky/background is uniform), underwater, or
though uniformly foggy/misty atmospheric conditions.

Multi/hyperspectral cameras with almost any number of bands are supported by the
code and can be used for greater colour measurement confidence.

These tools will be published soon, but in the meantime they can only be used and
distributed with our permission.

Please let me know if you need any specific camera cone mapping combinations and
report bugs/suggestions to me (jt@jolyon.co.uk)

Instructions:
''''''''''''''''''''''''''''''''''''''''
See the included user guide for a full overview. There are loads of supported options.

A .mspec file is generated alongside the RAW files. These files need to be kept together
in the same folder for the .mspec configuration file to link to the RAW files correctly.

_________________________________________________________________________
*/

requires("1.49");

// DCRAW import linear:
//run("DCRaw Reader...", "open=[/media/jolyon/NIKON D70001/2 grey temp/IMG_3146.CR2] use_temporary_directory white_balance=None do_not_automatically_brighten output_colorspace=raw read_as=[16-bit linear] interpolation=[High-speed, low-quality bilinear]");


// LOAD PREVIOUSLY USED VALUES

settingsFilePath = getDirectory("plugins") + "Multispectral Imaging/importSettings.txt";
if(File.exists(settingsFilePath) == 1){
	settingsString=File.openAsString(settingsFilePath);	// open txt data file
	defaultSettings=split(settingsString, "\n");
} else defaultSettings = newArray(
"Visible & UV",	// settings choice
"Same photo",	// grey loaction
"0",	// estimate black
"20,80", 	// grey levels
"0", 	// customise RGB levels
"0", 	// standards move
"1",	// images sequential
"Auto-Align",	// align
"16",	// offset
"4",	// loops
"0.005",	// scale step size
//"0.95",	// proportion
"1",	// custom zone
"1",	// use non-linear function - previously save config file
"Aligned Normalised 32-bit", // image output
"",	// default name
"0"); // rename RAW files


//  USER OPTIONS

	infoPath = getDirectory("plugins")+"Multispectral Imaging/cameras";
	infoList=getFileList(infoPath);
	infoNames = newArray(infoList.length);

		for(a=0; a<infoList.length; a++)
			infoNames[a] = replace(infoList[a], ".txt","");

	greyChoice = newArray("Same photo", "Separate photos");
	offsetOptions = newArray("4","8","16","32","64","128","256","512","1024");
	outputOptions = newArray( "Aligned Normalised 32-bit", "Aligned Linear 32-bit", "Visual 32-bit", "Pseudo UV 32-bit", "Config file only");
	//outputOptions = newArray("Config file only", "Unaligned Linear 16-bit", "Aligned Linear 32-bit", "Aligned Linear 16-bit", "Aligned Linear 8-bit", "Aligned Normalised 32-bit", "Aligned Normalised 16-bit", "Aligned Normalised 8-bit", "Visual 32-bit", "Pseudo UV 32-bit");
	//lineariseOptions = newArray("Linearise Only", "Linearise & Normalise");
	alignOptions = newArray("None", "Auto-Align", "Manual Align");

	//helpPage = "http://www.jolyon.co.uk";

	Dialog.create("Multispectral Image Compositioning");
		//Dialog.addMessage("Camera & Filter configuration");
		Dialog.addChoice("Settings", infoNames, defaultSettings[0]); // change the last value here to change the default
		Dialog.addCheckbox("Non-linear Image (e.g. JPG, TIFF, non-RAW format)", defaultSettings[12]);
		Dialog.addMessage("This requires making a linearisation model first");

		Dialog.addMessage("_________________Grey Standards_________________");
		Dialog.addChoice("Grey standards in:", greyChoice, defaultSettings[1]);
		Dialog.addCheckbox("Estimate black point (useful with one standard)", defaultSettings[2]);
		Dialog.addString("Standard reflectance(s)", defaultSettings[3], 20);
		//Dialog.addMessage("Separate values with a comma, e.g. 20% & 80%\nwould be \"20,80\" ");
		Dialog.addCheckbox("Customise standard levels", defaultSettings[4]);
		//Dialog.addMessage("e.g. use when you know the standard does not\nhave perfectly uniform specral reflectance");
		Dialog.addCheckbox("Standards move between photos", defaultSettings[5]);
		//Dialog.addMessage("Use when the locations of the standards change\nbetween photos (more than just mis-alignment)");

		Dialog.addMessage("___________________Image Location________________ ");
		Dialog.addCheckbox("Images sequential (alphabetically) in directory", defaultSettings[6]);
		//Dialog.addMessage("Tick if the images are correctly alphabetically\nordered to save time");

		Dialog.addMessage("________________Alignment & Scaling______________ ");
		//Dialog.addCheckbox("Auto-align slices", defaultSettings[7]);
		Dialog.addChoice("Alignment", alignOptions, defaultSettings[7]);
		Dialog.addChoice("Offset", offsetOptions, defaultSettings[8]);
		Dialog.addNumber("Scaling loops (1=off)", defaultSettings[9]);
		Dialog.addNumber("Scale_step_size",defaultSettings[10]);
		//Dialog.addSlider("Proportion", 0, 0.99, defaultSettings[11]);
		Dialog.addCheckbox("Custom alignment zone", defaultSettings[11]);

		Dialog.addMessage("___________________Output_________________ ");
		Dialog.addChoice("Image output", outputOptions, defaultSettings[13]);
		Dialog.addString("Image Name", defaultSettings[14], 20);
		Dialog.addCheckbox("Rename Image files", defaultSettings[15]);
 		//Dialog.addHelp(helpPage);

	Dialog.show();

	settingsChoice = Dialog.getChoice();
	nonLin = Dialog.getCheckbox();
	greyLocation = Dialog.getChoice();
	estimateBlack = Dialog.getCheckbox();
	standardString = Dialog.getString();
	customiseLevels = Dialog.getCheckbox();
	customiseLocation = Dialog.getCheckbox();
	imagesSequential = Dialog.getCheckbox();

	//autoAlignOption = Dialog.getCheckbox();
	autoAlignOption = Dialog.getChoice();
	autoAlignOffset = Dialog.getChoice();
	autoAlignLoops = Dialog.getNumber();
	autoAlignScaleStepSize = Dialog.getNumber();
	//autoAlignProportion = Dialog.getNumber();
	autoAlignProportion = 1-(2*autoAlignScaleStepSize);

	autoAlignCustomZone = Dialog.getCheckbox();

	//saveConfig = Dialog.getCheckbox();
	imageOutput = Dialog.getChoice();
	imageName = Dialog.getString();
	renameRAWs = Dialog.getCheckbox();

	if(greyLocation == "Separate photos")
		imagesSequential = 0; // this would make life more complicated...

	imageName = replace(imageName," ", "_"); // remove spaces as DCRAW doens't like them

// SAVE PREVIOUSLY USED SETTINGS
dataFile = File.open(settingsFilePath);

	print(dataFile, settingsChoice);
	print(dataFile, greyLocation);
	print(dataFile, estimateBlack);
	print(dataFile, standardString);
	print(dataFile, customiseLevels);
	print(dataFile, customiseLocation);
	print(dataFile, imagesSequential);
	print(dataFile, autoAlignOption);
	print(dataFile, autoAlignOffset);
	print(dataFile, autoAlignLoops);
	print(dataFile, autoAlignScaleStepSize);
	//print(dataFile, autoAlignProportion);
	print(dataFile, autoAlignCustomZone);
	//print(dataFile, saveConfig);
	print(dataFile, nonLin);
	print(dataFile, imageOutput);
	print(dataFile, imageName);
	print(dataFile, renameRAWs);

File.close(dataFile);

// LOAD CAMERA CONFIGURATION SETTINGS

	settingsPath = infoPath+"/"+settingsChoice+".txt";

	settingsString=File.openAsString(settingsPath);
	settingsString=split(settingsString, "\n"); // split settings into rows

	// Calculate number of slices required
	stackSize = 0;
	for(i=1; i<(settingsString.length); i++){
		settingsTemp = split(settingsString[i], "\t");
		for(j=1; j<=3; j++)
			if(parseInt(settingsTemp[j]) > stackSize)
				stackSize = parseInt(settingsTemp[j]);
	}

	nPhotos = settingsString.length-1;
	saveSliceLabels = newArray(stackSize);
	photoNames = newArray(nPhotos);


// NON-LINEAR IMAGE SETTINGS

	linCameraChoice = newArray(nPhotos);
	linCameraSettings = newArray(nPhotos);

	nonLinSettingsPath = getDirectory("plugins")+"Multispectral Imaging/Linearisation Models";
	nonLinList=getFileList(nonLinSettingsPath);
	nonLinNames = newArray(nonLinList.length);

		for(a=0; a<nonLinList.length; a++)
			nonLinNames[a] = replace(nonLinList[a], ".txt","");



// Standard reflectance values

	standardString = replace(standardString, " ", ""); // remove any spaces
	standardString = split(standardString, ",");

	standardLevels = newArray(standardString.length);
	for(i=0; i<standardString.length; i++)
		standardLevels[i] = parseFloat(standardString[i]);

// Create Array of slices to check for alignment

	alignCheckSlices = newArray();



// CLEAR ROI MANAGER
while(roiManager("count")>0){
	roiManager("select", 0);
	roiManager("Delete");
}


// work out directory of firstPath & subsequent image numbers (if sequential)


// OPEN FIRST IMAGE IF ALPHABETICALLY ORDERED

if(imagesSequential == 1){

	firstPath=File.openDialog("Select first photo"); // get file locations
	firstPhotoString = split(firstPath, "/");
	if(firstPhotoString.length == 1) // windows
		firstPhotoString = split(firstPath, "\\");

	seqDirectory = replace(firstPath, firstPhotoString[firstPhotoString.length-1], "");
	seqDirectoryFullList = getFileList(seqDirectory);
	seqDirectoryList = newArray();

for(i=0; i<seqDirectoryFullList.length; i++)
	if( endsWith(seqDirectoryFullList[i], ".pp3") == 0) // filter out the RAWTherapee .pp3 files
		seqDirectoryList = Array.concat(seqDirectoryList, seqDirectoryFullList[i]);

for(i=0; i<seqDirectoryList.length; i++)
	if(seqDirectoryList[i] == firstPhotoString[firstPhotoString.length-1])
		firstIndex = i;

for(i=0; i<nPhotos; i++)
	photoNames[i] = seqDirectoryList[firstIndex+i];


} // images sequential




// OPEN IMAGES & MEASURE STANDARD(s)

channelNames = newArray("R","G","B");
firstFlag = 1;

for(j=0; j<nPhotos; j++){

	photoSettings = split(settingsString[j+1], "\t"); // settings for current photo

	if(imagesSequential == 1){
		nonLinString = seqDirectory + photoNames[j];
		dcrawString = "open=[" + seqDirectory + photoNames[j] + "] use_temporary_directory white_balance=None do_not_automatically_brighten output_colorspace=raw read_as=[16-bit linear] interpolation=[High-speed, low-quality bilinear] do_not_rotate" ;
	} else {
		imagePath=File.openDialog("Select " + photoSettings[0] +  " photo containing standard" ); // get file locations
		imagePathTemp = split(imagePath, "/");
		if(imagePathTemp.length == 1) // windows
			imagePathTemp = split(imagePath, "\\");

		photoNames[j] = imagePathTemp[imagePathTemp.length-1];
		seqDirectory = replace(imagePath, imagePathTemp[imagePathTemp.length-1], ""); // used later for config file
		dcrawString = "open=[" + imagePath + "] use_temporary_directory white_balance=None do_not_automatically_brighten output_colorspace=raw read_as=[16-bit linear] interpolation=[High-speed, low-quality bilinear] do_not_rotate" ;
		nonLinString = seqDirectory + photoNames[j];
	}
	
	//-------------------OPEN RAW OR NON-LINEAR IMAGE-----------------
	if(nonLin == 0)
		run("DCRaw Reader...", dcrawString);
	else {
		open(nonLinString);
		if(bitDepth == 24)
			run("RGB Stack");
		if(bitDepth != 32)
			run("32-bit");

		Dialog.create("Linearity Model");
			Dialog.addChoice("Linearity model for " + photoSettings[0], nonLinNames);
		Dialog.show();

		
		linCameraChoice[j] = Dialog.getChoice();

		nonLinSettingsString=File.openAsString(nonLinSettingsPath + "/" + linCameraChoice[j] + ".txt");
		linCameraSettings[j] = nonLinSettingsString;
		nonLinSettingsString=split(nonLinSettingsString, ","); // split settings

		if(nonLinSettingsString.length != nSlices)
			exit("The chosen linearity model has a different number of channels than the selected image");

		for(a=0; a<nSlices; a++) // linearise image
			run("Linearisation Function", nonLinSettingsString[a]);

		run("Enhance Contrast", "saturated=0.35");
	}

	photoID = getImageID();

	if(j==0){
		iw = getWidth();
		ih = getHeight();
	} else {
		w = getWidth();
		h = getHeight();

		if(h!=ih){ // Ensure all images are landscape, as canon pics are auto-rotated
			run("Rotate 90 Degrees Right");
		}

	}

	alignInfo = newArray("0", "0", "1"); // x off, y off, scale

	// IMAGE ALIGNMENT
	// Align all subsequent images to the first
	// alignment x,y and scale are saved after slice name, e.g. visible:R:3:5:0.9876,grey values...

	if(autoAlignOption != "None" && autoAlignCustomZone == 1 && j ==0 && greyLocation == "Same photo" && customiseLocation == 0){
		//setTool("rectangle");
		run("Rounded Rect Tool...", "stroke=1 corner=2 color=blue fill=none");
		run("Rounded Rect Tool...", "stroke=1 corner=1 color=blue fill=none");
		setTool("roundrect");
		setBatchMode("show");
		waitForUser("Custom Alignment Zone", "Draw a box over the area to use for alignment");
		getSelectionBounds(xAlign, yAlign, wAlign, hAlign);
	}


	setBatchMode(true);

	if(j > 0 && autoAlignOption != "None" && greyLocation == "Same photo" && customiseLocation == 0){
		selectImage(newStack);
		setSlice(photoSettings[4]); // the reference slice
		alignCheckSlices = Array.concat(alignCheckSlices, parseInt(photoSettings[4]));
		alignCheckSlices = Array.concat(alignCheckSlices, parseInt(photoSettings[parseInt(photoSettings[5])])); // work out what position this slice will have

		if(autoAlignCustomZone == 1)
			makeRectangle(xAlign, yAlign, wAlign, hAlign);
		else
			run("Select All");

		run("Copy");
		run("Internal Clipboard");
		rename("align1");
		
		selectImage(photoID);
		setSlice(parseInt(photoSettings[5])); // the slice to be aligned to the reference, specified in the script

		if(autoAlignCustomZone == 1)
			makeRectangle(xAlign, yAlign, wAlign, hAlign);
		else
			run("Select All");

		run("Copy");
		run("Internal Clipboard");
		rename("align2");
	
		if(autoAlignOption == "Auto-Align"){
			alignString =  "offset=" + autoAlignOffset + " loops=" + autoAlignLoops +" scale_step_size=" + autoAlignScaleStepSize + " proportion=" + autoAlignProportion;
			run("Auto Align", alignString);
		}
		if(autoAlignOption == "Manual Align"){
			selectImage(newStack);
			setBatchMode("show");
			selectImage(photoID);
			setBatchMode("show");
			selectImage("align1");
			setBatchMode("show");
			selectImage("align2");
			setBatchMode("show");
			setBatchMode(false);
			run("Manual Align");
			//waitForUser("Select the \"Manual Align\" image, then use\nW, A, S, Z, keys to shift and align the image");
			setBatchMode(true);
			selectImage("ManualAlign");
			close();
		}



		selectImage("align1");
		close();
		selectImage("align2");
		close();

		// extract alignment info
		selectWindow("Alignment Results");
		alignInfo = getInfo("window.contents");
		alignInfo = split(alignInfo, "\n"); // split rows
		alignInfo = split(alignInfo[1], "\t"); // split second row into data
		run("Close");
		
		scaleShift = parseFloat(alignInfo[2]);

		if(autoAlignCustomZone == 1 && scaleShift != 1){ // coords need updating if a custom zone was used and the scale was changed
			w = getWidth();
			h = getHeight();
			xImageShift = (w-(w*scaleShift))/2;
			yImageShift = (h-(h*scaleShift))/2;
			xZoneShift = (wAlign-(wAlign*scaleShift))/2;
			yZoneShift = (hAlign-(hAlign*scaleShift))/2;
			xShiftDiff = xZoneShift - xImageShift;
			yShiftDiff = yZoneShift - yImageShift;
		
			alignInfo[0] = round(parseFloat(alignInfo[0])+xShiftDiff);
			alignInfo[1] =round( parseFloat(alignInfo[1])+yShiftDiff);
		}

	}


	rPxs = newArray(standardLevels.length);
	gPxs = newArray(standardLevels.length);
	bPxs = newArray(standardLevels.length);

	rGreys = newArray(standardLevels.length);
	gGreys = newArray(standardLevels.length);
	bGreys = newArray(standardLevels.length);


for(i=0; i<standardLevels.length; i++){

	if(j != 0) // not the first image, so select pre-drawn area
		roiManager("select", i);

	if(j == 0) // first image only
		run("Select None");

	if( customiseLocation == 1 || j == 0 || greyLocation == "Separate photos"){ // first image, or custom location
		//setBatchMode(false);
		setBatchMode("show");
		waitForUser("Select " + standardLevels[i] + "% standard");
		setBatchMode("hide");
		//setBatchMode(true);
	}

	if(j == 0){ // first image only
		roiManager("Add");
		roiManager("select", roiManager("count")-1);
		roiManager("Rename", standardString[i] );
	}
	

	if(customiseLevels == 1){
		Dialog.create("Customise " + standardLevels[i] + "% Standard Levels");
			Dialog.addNumber("Red reflectance %", standardLevels[i]);
			Dialog.addNumber("Green reflectance %", standardLevels[i]);
			Dialog.addNumber("Blue reflectance %", standardLevels[i]);
		Dialog.show();

		rGreys[i] = Dialog.getNumber();
		gGreys[i] = Dialog.getNumber();
		bGreys[i]= Dialog.getNumber();

	} else{
		rGreys[i] = standardLevels[i];
		gGreys[i]  = standardLevels[i];
		bGreys[i]  = standardLevels[i];
	}

	// MEASURE GREY STANDARDS - only from channels that are to be used


	if(j > 0 && autoAlignOption != "None" && greyLocation == "Same photo" && customiseLocation == 0){ // control for alignment of grey standard selection
		getSelectionCoordinates(xCoords, yCoords);
		for(k = 0; k<xCoords.length; k++){
			xCoords[k] = xCoords[k] + parseInt(alignInfo[0]);
			yCoords[k] = yCoords[k] + parseInt(alignInfo[1]);
		}//k

		makeSelection("Polygon", xCoords, yCoords); // make aligned grey standard selection
		//waitForUser("waiting");
	}


	for(k=1; k<=3; k++){
		if(parseInt(photoSettings[k]) > 0){ // channel is to be added
			setSlice(k);


			getStatistics(area, mean, min, max, std);

			if(mean + (std*3) > 65000 || max > 65530)
				waitForUser("Exposure Warning", "This standard appears over-exposed");

			if(k == 1) // red
				rPxs[i] = mean;
			if(k == 2) // green
				gPxs[i] = mean;
			if(k == 3) // blue
				bPxs[i] = mean;
		}
	}//k



} // i


// GREY STANDARD IN SEPARATE PHOTO:

if(greyLocation == "Separate photos"){
	selectImage(photoID);
	close(); // close measured photo & open photo to process
	imagePath=File.openDialog("Select " + photoSettings[0] +  " photo without standard" ); // get file locations

		imagePathTemp2 = split(imagePath, "/");
		if(imagePathTemp2.length == 1) // windows
			imagePathTemp2 = split(imagePath, "\\");

	seqDirectory = replace(imagePath, imagePathTemp2[imagePathTemp2.length-1], ""); // used later for config file
	dcrawString = "open=[" + imagePath + "] use_temporary_directory white_balance=None do_not_automatically_brighten output_colorspace=raw read_as=[16-bit linear] interpolation=[High-speed, low-quality bilinear] do_not_rotate" ;


	//-------------------OPEN RAW OR NON-LINEAR IMAGE-----------------
	if(nonLin == 0)
		run("DCRaw Reader...", dcrawString);
	else {
		open(imagePath);
		if(bitDepth == 24)
			run("RGB Stack");
		if(bitDepth != 32)
			run("32-bit");

		//Dialog.create("Linearity Model");
		//	Dialog.addChoice("Linearity model for " + photoSettings[0], nonLinNames);
		//Dialog.show();
		//linCameraChoice[j] = Dialog.getChoice();

		//nonLinSettingsString=File.openAsString(nonLinSettingsPath + "/" + linCameraChoice[j] + ".txt");
		//linCameraSettings[j] = nonLinSettingsString;
		//nonLinSettingsString=split(nonLinSettingsString, ","); // split settings

		if(nonLinSettingsString.length != nSlices)
			exit("The chosen linearity model has a different number of channels than the selected image");

		for(a=0; a<nSlices; a++) // linearise image
			run("Linearisation Function", nonLinSettingsString[a]);

		run("Enhance Contrast", "saturated=0.35");
	}

	photoID = getImageID();

	if(j==0){
		iw = getWidth();
		ih = getHeight();
	} else {
		w = getWidth();
		h = getHeight();

		if(h!=ih){ // Ensure all images are landscape, as canon pics are auto-rotated
			run("Rotate 90 Degrees Right");
		}

	}

	imagePathTemp = split(imagePath, "/");
	if(imagePathTemp.length == 1) // windows
		imagePathTemp = split(imagePath, "\\");
	photoNames[j] = imagePathTemp[imagePathTemp.length-1];
}

if(greyLocation == "Separate photos" || customiseLocation == 1){

	if(autoAlignOption != "None" && autoAlignCustomZone == 1 && j ==0){
		setBatchMode("show");
		//setTool("rectangle");
		run("Rounded Rect Tool...", "stroke=1 corner=2 color=blue fill=none");
		run("Rounded Rect Tool...", "stroke=1 corner=1 color=blue fill=none");
		setTool("roundrect");
		waitForUser("Custom Alignment Zone", "Draw a box over the area to use for alignment");
		getSelectionBounds(xAlign, yAlign, wAlign, hAlign);
		setBatchMode("hide");
	}



	if(j > 0 && autoAlignOption != "None"){
		selectImage(newStack);
		setSlice(photoSettings[4]); // the reference slice

		if(autoAlignCustomZone == 1)
			makeRectangle(xAlign, yAlign, wAlign, hAlign);
		else
			run("Select All");

		run("Copy");
		run("Internal Clipboard");
		rename("align1");
		
		selectImage(photoID);
		setSlice(parseInt(photoSettings[5])); // the slice to be aligned to the reference, specified in the script

		if(autoAlignCustomZone == 1)
			makeRectangle(xAlign, yAlign, wAlign, hAlign);
		else
			run("Select All");

		run("Copy");
		run("Internal Clipboard");
		rename("align2");
	
		if(autoAlignOption == "Auto-Align"){
			alignString =  "offset=" + autoAlignOffset + " loops=" + autoAlignLoops +" scale_step_size=" + autoAlignScaleStepSize + " proportion=" + autoAlignProportion;
			run("Auto Align", alignString);
		}
		if(autoAlignOption == "Manual Align"){
			selectImage(newStack);
			setBatchMode("show");
			selectImage(photoID);
			setBatchMode("show");
			selectImage("align1");
			setBatchMode("show");
			selectImage("align2");
			setBatchMode("show");
			setBatchMode(false);
			run("Manual Align");
			//waitForUser("Select the \"Manual Align\" image, then use\nW, A, S, Z, keys to shift and align the image");
			setBatchMode(true);
			selectImage("ManualAlign");
			close();
		}

		selectImage("align1");
		close();
		selectImage("align2");
		close();

		// extract alignment info
		selectWindow("Alignment Results");
		alignInfo = getInfo("window.contents");
		alignInfo = split(alignInfo, "\n"); // split rows
		alignInfo = split(alignInfo[1], "\t"); // split second rown into data
		run("Close");

		scaleShift = parseFloat(alignInfo[2]);

		if(autoAlignCustomZone == 1 && scaleShift != 1){ // coords need updating if a custom zone was used and the scale was changed
			w = getWidth();
			h = getHeight();
			xImageShift = (w-(w*scaleShift))/2;
			yImageShift = (h-(h*scaleShift))/2;
			xZoneShift = (wAlign-(wAlign*scaleShift))/2;
			yZoneShift = (hAlign-(hAlign*scaleShift))/2;
			xShiftDiff = xZoneShift - xImageShift;
			yShiftDiff = yZoneShift - yImageShift;
		
			alignInfo[0] = round(parseFloat(alignInfo[0])+xShiftDiff);
			alignInfo[1] =round( parseFloat(alignInfo[1])+yShiftDiff);
		}

	}
}



// use camera configuration file to assign slices to the right place in the composite image


//Array.print(photoSettings);


for(i=1; i<=3; i++){
	if(parseInt(photoSettings[i]) > 0){ // channel is to be added

		selectImage(photoID);
		setSlice(i);
			
		if(firstFlag == 1){ // first photo - set up new image
			run("Select All");
			run("Copy");
			if(imageName != "")
				newImageName = imageName;
			else newImageName = "Multispectral Composite";
			newImage(newImageName, "32-bit black", getWidth(), getHeight(), stackSize);
			//run("Internal Clipboard");
			newStack = getImageID();
			setSlice(parseInt( photoSettings[i]) );
			run("Paste");
			//setBatchMode("show");
			firstFlag = 0;
	
		} else { // subsequent photo - add new slice
			run("Select All");
			run("Copy");
			selectImage(newStack);
			setSlice(parseInt( photoSettings[i]) );
			run("Paste");
		}



		if(estimateBlack == 1){ // add a 0.05% dark point
			run("Select All");
			getStatistics(area, mean);
			getHistogram(values, counts, 65535, 0, 65535);

			pxThreshold = 0.001*area; // low pixel value threshold
			pxSum = 0;
			k = 0;
			while(k<65535){
				pxSum = pxSum + counts[k];
				if(pxSum >= pxThreshold){
					lowObs = values[k];
					k=65535;
				} else k++;
			}

		} // estimate black point


		// create label that stores all the relevant linearisation, normalisation, alignment & scale data

		labelString = "label=" + photoSettings[0] + ":" + channelNames[i-1] + ":" + alignInfo[0] + ":" + alignInfo[1] + ":" + alignInfo[2];

		if(estimateBlack == 1) // add a 0.05% dark point
			labelString = labelString + ",0.05:" + lowObs;


		if(i == 1) // copy grey & pixel values to slice label
			for(k=0; k<standardLevels.length; k++)
				labelString = labelString + ","+ rGreys[k] + ":" + rPxs[k];
		if(i == 2)
			for(k=0; k<standardLevels.length; k++)
				labelString = labelString + ","+ gGreys[k] + ":" + gPxs[k];
		if(i == 3)
			for(k=0; k<standardLevels.length; k++)
				labelString = labelString + ","+ bGreys[k] + ":" + bPxs[k];

		saveSliceLabels[parseInt( photoSettings[i])-1] = labelString; // save slice data for config file
		run("Set Label...", labelString);

			
	}
}//i

selectImage(photoID);
close();

} // j

// SAVE CONFIGURATION FILE

configFilePath =  seqDirectory + imageName + ".mspec";
while(File.exists(configFilePath) == 1){
	//showMessageWithCancel("Overwrite?", "A .mspec configuration file with that name\nalready exists, should it be overwritten?");

	overwriteChoice = getBoolean("A .mspec configuration file with that name\nalready exists, should it be overwritten?\n \nSelect \"No\" to rename this file");

	if(overwriteChoice == 1) // overwrite
		File.delete(configFilePath);

	if(overwriteChoice == 0){ // rename
		Dialog.create("Rename Configuration file");
		Dialog.addString("New name", "", 20);
		Dialog.show();

		imageName = Dialog.getString();
		configFilePath =  seqDirectory + imageName + ".mspec";
	}//rename
}

//if(saveConfig == 1){

if(renameRAWs ==1){

	photoNamesString = imageName + photoNames[0];

	for(i=1; i<photoNames.length; i++)
		photoNamesString = photoNamesString + "\t" + imageName + photoNames[i];
} else {
	photoNamesString = photoNames[0];

	for(i=1; i<photoNames.length; i++)
		photoNamesString = photoNamesString + "\t" + photoNames[i];
}


saveSlicelabelsString = saveSliceLabels[0];
for(i=1; i<stackSize; i++)
	saveSlicelabelsString = saveSlicelabelsString + "\t" + saveSliceLabels[i];

if(nonLin == 1){
	linString = linCameraSettings[0];
	for(i=1; i<linCameraSettings.length; i++)
		linString = linString + "\t" + linCameraSettings[i];

	linString = replace(linString, "\n", ""); // ensure there are no line breaks
}

configFile = File.open(configFilePath);

	print(configFile, settingsChoice);
	print(configFile, photoNamesString);
	print(configFile, saveSlicelabelsString);
	if(nonLin == 1)
		print(configFile, linString);

File.close(configFile);

// RENAME FILES

if(renameRAWs ==1)
	for(i=0; i<photoNames.length; i++)
		File.rename(seqDirectory + photoNames[i], seqDirectory + imageName + photoNames[i]);

//}// save config


// OUTPUT options: "Config file only", "Unaligned Linear 16-bit", "Aligned Linear 16-bit", "Aligned 32-bit", "Aligned 16-bit", "Aligned 8-bit"

transformInfo = "";


if(imageOutput == "Config file only")
	close();

if(imageOutput == "Unaligned Linear 16-bit"){
	setMinAndMax(0, 65535);
	setBatchMode(false);
	setSlice(1);
}

if(imageOutput == "Aligned Linear 32-bit"){
	run("Normalise & Align Multispectral Stack", "curve=[Straight Line] align_only");
	setMinAndMax(0, 65535);
	setBatchMode(false);
	setSlice(1);

	if(settingsChoice == "Visible & UV"){
	for(i=0; i<5; i++){
		colourSwitch = 1;
		for(j=0; j<alignCheckSlices.length; j++){
			setSlice(alignCheckSlices[j]);
			Overlay.remove;
			if(colourSwitch == 1)
				setColor(200, 0, 0);
			else	setColor(0, 0, 200);
			colourSwitch = colourSwitch * -1;
			setFont("SansSerif", getHeight()*0.04);
			Overlay.drawString("Check the alignment is ok", getWidth()*0.1, getHeight()*0.1);
			Overlay.show;
			wait(800);
		}
	}
	Overlay.remove;
	}
	setMinAndMax(0, 65535);
}

if(imageOutput == "Aligned Linear 16-bit"){
	run("Normalise & Align Multispectral Stack", "curve=[Straight Line] align_only");
	setMinAndMax(0, 65535);
	run("16-bit");
	setBatchMode(false);
	setSlice(1);
}

if(imageOutput == "Aligned Linear 8-bit"){
	run("Normalise & Align Multispectral Stack", "curve=[Straight Line] align_only");
	run("Divide...", "value=256 stack");
	setMinAndMax(0, 255);
	run("8-bit");
	setBatchMode(false);
	setSlice(1);
}

if(imageOutput == "Aligned Normalised 32-bit"){
	run("Normalise & Align Multispectral Stack", "curve=[Straight Line]");
	setBatchMode(false);

	if(settingsChoice == "Visible & UV"){
	for(i=0; i<5; i++){
		colourSwitch = 1;
		for(j=0; j<alignCheckSlices.length; j++){
			setSlice(alignCheckSlices[j]);
			Overlay.remove;
			if(colourSwitch == 1)
				setColor(200, 0, 0);
			else	setColor(0, 0, 200);
			colourSwitch = colourSwitch * -1;
			setFont("SansSerif", getHeight()*0.04);
			Overlay.drawString("Check the alignment is ok", getWidth()*0.1, getHeight()*0.1);
			Overlay.show;
			wait(800);
		}
	}
	Overlay.remove;
	}
	setMinAndMax(0, 65535);

}

if(imageOutput == "Aligned Normalised 16-bit"){
	run("Normalise & Align Multispectral Stack", "curve=[Straight Line]");
	setMinAndMax(0, 65535);
	run("16-bit");
	setBatchMode(false);
	setSlice(1);
}

if(imageOutput == "Aligned Normalised 8-bit"){
	run("Normalise & Align Multispectral Stack", "curve=[Straight Line]");
	run("Divide...", "value=256 stack");
	setMinAndMax(0, 255);
	run("8-bit");
	setBatchMode(false);
	setSlice(1);
}

if(imageOutput == "Visual 32-bit"){

	run("Normalise & Align Multispectral Stack", "curve=[Straight Line]");
	while(nSlices>3){
		setSlice(4);
		run("Delete Slice");
	}

	run("Square Root", "stack");
	setMinAndMax(0, 255);
	run("Make Composite", "display=Composite");
	setSlice(3);
	setMinAndMax(0, 255);
	setSlice(2);
	setMinAndMax(0, 255);
	setSlice(1);
	setMinAndMax(0, 255);
	setBatchMode(false);

	setColor(200, 0, 0);
	colourSwitch = colourSwitch * -1;
	setFont("SansSerif", getHeight()*0.04);


	setFont("SansSerif", getHeight()*0.02);
	setColor(200, 0, 0);
	Overlay.drawString("Do not measure this image. Use it for selecting regions.", getWidth()*0.05, getHeight()*0.05);
	Overlay.show;

}

if(imageOutput == "Pseudo UV 32-bit"){

	run("Normalise & Align Multispectral Stack", "curve=[Straight Line]");
	if(nSlices<5){
		exit("Pseudo-UV shows the visible Green and Blue\nand UV Red channels as a composite. This image\ndoes not have enough channels");
		setBatchMode(false);
		setSlice(1);
	}

	run("Normalise & Align Multispectral Stack", "curve=[Straight Line]");

	while(nSlices>5){
		setSlice(6);
		run("Delete Slice");
	}

	setSlice(4);
	run("Delete Slice"); // delete uvB

	setSlice(1);
	run("Delete Slice"); // delete visR


	run("Square Root", "stack");
	setMinAndMax(0, 255);
	run("Make Composite", "display=Composite");
	setSlice(3);
	setMinAndMax(0, 255);
	setSlice(2);
	setMinAndMax(0, 255);
	setSlice(1);
	setMinAndMax(0, 255);

	setFont("SansSerif", getHeight()*0.02);
	setColor(200, 0, 0);
	Overlay.drawString("Do not measure this image. Use it for selecting regions.", getWidth()*0.05, getHeight()*0.05);
	Overlay.show;


	transformInfo = "________________________________________\nThis is a false-colour image, shifting the\nchannels to show visible green, visible\nblue and uv red. Use this image to judge\nthe alignment and select ROIs, but don't\nmeasure it directly. Once you've selected\nROIs use the batch script"; 

	setBatchMode(false);
}

print("\\Clear");

print("__________Config file saved to:__________");
print(configFilePath);


if(imageOutput != "Config file only"){
	print("________________________________________");
	print("Select regions of interest and press any");
	print("key to add them to the ROI manager.\n ");
	print("Draw a line along the scale bar and press");
	print("\"S\" if you're planning to measure pattern.\n ");
	print("To measure eggs and save their coordinates");
	print("press \"E\". Make sure a scale bar is selected\nbeforehand. Place a point on the tip and base\nof the egg, then three more down each side.\n ");
	print("Press \"0\" to save your selections linked");
	print("to the image. Leave this log window open");
	print("while adding selections without needing");
	print("to use the save dialog.");

	print("________________________________________");

	print(transformInfo);

	while(roiManager("count") > 0){
		roiManager("select", 0);
		roiManager("Delete");	
	}
	run("Select None");
	run("Save ROIs");
	setSlice(1);
}

setOption("Changes", false);// reset changes flag so (hopefully) the save image dialog won't come up
showProgress(1); // clear progress bar (it seems to stick)
showStatus("Finished creating multispectral image");

